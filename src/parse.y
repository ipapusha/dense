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
%token LBRACKET RBRACKET

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

%start stmtlist

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

stmtlist: /* nothing */
	| exp SEMICOLON stmtlist
	;
