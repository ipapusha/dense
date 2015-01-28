%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "parse.h"
	/*
	IDENT properties (set in parse.py)
	----------------------------------
	G global
	A function argument
	F function return value
	I for-loop iteration index

	IDENT properties (set in resolve.py)
	------------------------------------
	R ref    =...a  or  =...a(b) 
	D def    a=...  or   [a,b,c]=...
	U update a(b)=...  or  [a(b) c(d)]=...
	*/
%}

%union {
	struct ast *a;
	struct symbol *s;   /* which symbol */
	double d;
	int fn;
}

%token IDENT NUMBER 
%token LBRACKET RBRACKET
%token SEMI

%right EQ
%left COMMA
%left PLUS MINUS
%left MUL DIV DOTMUL DOTDIV BACKSLASH
%right UMINUS
%right TRANSPOSE
%right EXP DOTEXP
%nonassoc LPAREN RPAREN

%type <a> expr matrix

%% /* grammar rules */

/* EXPR and concat */
expr_list : expr
		  | expr_list COMMA expr
		  ;
concat_list : expr_list SEMI expr_list
            | concat_list SEMI expr_list
			;
/* EXPR */
expr : IDENT
     | NUMBER
     | matrix
     | expr2
     | expr1
	 | LPAREN expr RPAREN
	 | expr TRANSPOSE
	 | expr LPAREN expr_list RPAREN 
     | expr LPAREN RPAREN
	 ;
matrix : LBRACKET RBRACKET
       | LBRACKET concat_list RBRACKET
       | LBRACKET concat_list SEMI RBRACKET
       | LBRACKET expr_list RBRACKET
       | LBRACKET expr_list SEMI RBRACKET
	   ;
expr2 : expr BACKSLASH expr
      | expr DIV expr
      | expr DOTDIV expr
      | expr DOTEXP expr
      | expr DOTMUL expr
      | expr EXP expr
      | expr MINUS expr
      | expr MUL expr
      | expr PLUS expr
      | expr EQ expr
	  ;
expr1 : MINUS expr %prec UMINUS
      | PLUS expr %prec UMINUS
	  ;

%%
