%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "parse.h"

	int yylex();	/* non reentrant parser */
%}

%union {
	struct prog			*pr;
	struct stmt_list	*sl;
	struct stmt			*s;
	struct assign_stmt	*as;
	struct expr_stmt	*es;
	struct expr_list	*el;
	struct concat_list	*cl;
	struct ident		*id;
	struct matrix		*m;
	struct expr2		*e2;
	struct expr1		*e1;
	struct expr			*e;
	char *str;
	double d;
}

%token <str> IDENT 
%token <d> NUMBER 
%token LBRACKET RBRACKET
%token SEMI
%token EOL

%right EQ
%left COMMA
%left PLUS MINUS
%left MUL DIV DOTMUL DOTDIV BACKSLASH
%right UMINUS
%right TRANSPOSE
%right EXP DOTEXP
%nonassoc LPAREN RPAREN

%type <pr> prog
%type <sl> stmt_list
%type <s> stmt
%type <as> assign_stmt
%type <es> expr_stmt
%type <el> expr_list
%type <cl> concat_list
%type <id> ident
%type <m> matrix
%type <e2> expr2
%type <e1> expr1
%type <e> expr

%% /* grammar rules */

prog: stmt_list						{ $$ = newprog($1); }
	;
stmt_list: stmt						{ $$ = newstmt_list($1, NULL); }
		 | stmt_list stmt			{ $$ = newstmt_list($2, $1); }	/* TODO: reverse */
		 ;
stmt: assign_stmt					{ $$ = newstmt(sASSIGN, $1, NULL); }
	| expr_stmt						{ $$ = newstmt(sEXPR, NULL, $1); }
	;
assign_stmt: ident EQ expr SEMI		{ $$ = newassign_stmt($1, $3); }
		   ;
expr_stmt: expr SEMI				{ $$ = newexpr_stmt($1); }
		 ;
/* expr and concat lists */
expr_list : expr					{ $$ = newexpr_list($1, NULL); }
		  | expr_list COMMA expr	{ $$ = newexpr_list($3, $1); }	/* TODO: reverse */
		  ;
concat_list : expr_list SEMI expr_list		{ $$ = newconcat_list($3, newconcat_list($1, NULL)); }	/* TODO: reverse */
            | concat_list SEMI expr_list	{ $$ = newconcat_list($3, $1); }	/* TODO: reverse */
			;
/* EXPR */
expr : ident				{ $$ = newexpr(eIDENT, $1, 0, NULL, NULL, NULL, NULL); }
     | NUMBER				{ $$ = newexpr(eNUMBER, NULL, $1, NULL, NULL, NULL, NULL); }	/* TODO: is this correct? */
     | matrix				{ $$ = newexpr(eMATRIX, NULL, 0, $1, NULL, NULL, NULL); }
     | expr2				{ $$ = newexpr(eEXPR2, NULL, 0, NULL, $1, NULL, NULL); }
     | expr1				{ $$ = newexpr(eEXPR1, NULL, 0, NULL, NULL, $1, NULL); }
	 | LPAREN expr RPAREN	{ $$ = $2; }
	 | expr TRANSPOSE		{ $$ = newexpr(eTRANSPOSE, NULL, 0, NULL, NULL, NULL, $1); }
	 | ident LPAREN expr_list RPAREN	{ $$ = newexpr(eFUNCALL, $1, 0, NULL, NULL, NULL, NULL); } /* TODO: is this correct? */
     | ident LPAREN RPAREN				{ $$ = newexpr(eFUNCALL, $1, 0, NULL, NULL, NULL, NULL); }
	 ;
ident: IDENT	{ $$ = newident(idVAR, $1, NULL); } /* TODO: lookup identifier here */
	 ;
matrix : LBRACKET RBRACKET						{ $$ = newmatrix(mMV, NULL, NULL, NULL); }
       | LBRACKET concat_list RBRACKET			{ $$ = newmatrix(mCL, $2, NULL, NULL); }
       | LBRACKET concat_list SEMI RBRACKET		{ $$ = newmatrix(mCL, $2, NULL, NULL); }
       | LBRACKET expr_list RBRACKET			{ $$ = newmatrix(mEL, NULL, $2, NULL); }
       | LBRACKET expr_list SEMI RBRACKET		{ $$ = newmatrix(mEL, NULL, $2, NULL); }
	   ;
expr2 : expr BACKSLASH expr		{ $$ = newexpr2(e2BACKSLASH, $1, $3); }
      | expr DIV expr			{ $$ = newexpr2(e2DIV, $1, $3); }
      | expr DOTDIV expr		{ $$ = newexpr2(e2DOTDIV, $1, $3); }
      | expr DOTEXP expr		{ $$ = newexpr2(e2DOTEXP, $1, $3); }
      | expr DOTMUL expr		{ $$ = newexpr2(e2DOTMUL, $1, $3); }
      | expr EXP expr			{ $$ = newexpr2(e2EXP, $1, $3); }
      | expr MINUS expr			{ $$ = newexpr2(e2MINUS, $1, $3); }
      | expr MUL expr			{ $$ = newexpr2(e2MUL, $1, $3); }
      | expr PLUS expr			{ $$ = newexpr2(e2PLUS, $1, $3); }
	  ;
expr1 : MINUS expr %prec UMINUS	{ $$ = newexpr1(e1MINUS, $2); }
      | PLUS expr %prec UMINUS	{ $$ = newexpr1(e1PLUS, $2); }
	  ;
