/* calculator with AST */
%{
#include <stdio.h>
#include <stdlib.h>
#include "parse.h"
%}

%union {
	struct ast *a;
	struct symbol *s;	/* which symbol */
	double d;
	int fn;
}

/* declare tokens */
%token <d> NUMBER
%token <s> NAME
%token <fn> FUNC
%token EOL

/* precedence */
%right EQ
%left SEMICOLON
%left COMMA
%left PLUS MINUS
%left MUL DIV DOTMUL DOTDIV
%right UMINUS
%right TRANSPOSE
%right EXP DOTEXP
%nonassoc LPAREN RPAREN

/*
 %nonassoc <fn> CMP
 %right '='
 %left '+' '-'
 %left '*' '/'
 %nonassoc '|' UMINUS
 
 %type <a> exp stmt list explist
 %type <sl> symlist
 
 %start calclist
*/

%%

/* anything that evaluates to a matrix */
exp: exp PLUS exp				{}
	| exp MINUS exp				{}
	| exp MUL exp				{}
	| exp DIV exp				{}
	| exp DOTMUL exp			{}
	| exp DOTDIV exp			{}
	| MINUS exp %prec UMINUS	{}
	| LPAREN exp RPAREN			{}
	| NUMBER					{} /* returns scalar val, compare to vlist */
	| NAME						{}
	| NAME EQ exp				{}
	| FUNC LPAREN hlist RPAREN	{} /* built-in function call, TODO: make explist by itself */
	;

hlist: exp
	| exp COMMA hlist
	| LBRACKET hlist RBRACKET
	;

vlist: hlist
	| hlist SEMICOLON vlist
	| LBRACKET hlist SEMICOLON vlist RBRACKET
	;

exp: vlist	 /* returns matrix val, compare to NUMBER */
	;

stmt:
	exp
	;

stmtlist: /* nothing */
	| stmt
	| stmt SEMICOLON stmtlist
	;

prog: stmtlist



stmt: IF exp THEN list				{ $$ = newflow('I', $2, $4, NULL); }
	| IF exp THEN list ELSE list	{ $$ = newflow('I', $2, $4, $6); }
	| WHILE exp DO list				{ $$ = newflow('W', $2, $4, NULL); }
	| exp
	;

list: /* nothing */		{ $$ = NULL; }
	| stmt ';' list		{ if ($3 == NULL) 
							$$ = $1;
						  else
							$$ = newast('L', $1, $3); }
	;

exp: exp CMP exp			{ $$ = newcmp($2, $1, $3); }
	| exp '+' exp			{ $$ = newast('+', $1, $3); }
	| exp '-' exp			{ $$ = newast('-', $1, $3); }
	| exp '*' exp			{ $$ = newast('*', $1, $3); }
	| exp '/' exp			{ $$ = newast('/', $1, $3); }
	| '|' exp				{ $$ = newast('|', $2, NULL); }
	| '(' exp ')'			{ $$ = $2; }
	| '-' exp %prec UMINUS	{ $$ = newast('M', $2, NULL); }
	| NUMBER				{ $$ = newnum($1); }		/* TODO: ensure lexer does atof() */
	| NAME					{ $$ = newref($1); }
	| NAME '=' exp			{ $$ = newasgn($1, $3); }
	| FUNC '(' explist ')'	{ $$ = newfunc($1, $3); } /* XXX: why is the first argument this? */
	| NAME '(' explist ')'	{ $$ = newcall($1, $3); }
	;

explist: exp
	| exp ',' explist		{ $$ = newast('L', $1, $3); }
	;

symlist: NAME			{ $$ = newsymlist($1, NULL); }
	| NAME ',' symlist	{ $$ = newsymlist($1, $3); }
	;

calclist: /* nothing */
	| calclist stmt EOL		{ printf("= %4.4g\n> ", eval($2));
							  treefree($2); }
	| calclist LET NAME '(' symlist ')' '=' list EOL {
			dodef($3, $5, $8);
			printf("Defined %s\n> ", $3->name);
		}
	| calclist error EOL	{ yyerrok; printf("> "); }
	;

