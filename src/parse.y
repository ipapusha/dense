%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "parse.h"
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

prog: stmt_list 
	;
stmt_list: stmt
		 | stmt_list stmt
		 ;
stmt: assign_stmt
	| expr_stmt
	;
assign_stmt: ident EQ expr SEMI
		   ;
expr_stmt: expr SEMI
		 ;
/* expr and concat lists */
expr_list : expr
		  | expr_list COMMA expr
		  ;
concat_list : expr_list SEMI expr_list
            | concat_list SEMI expr_list
			;
/* EXPR */
expr : ident
     | NUMBER
     | matrix
     | expr2	
     | expr1
	 | LPAREN expr RPAREN
	 | expr TRANSPOSE
	 | ident LPAREN expr_list RPAREN 
     | ident LPAREN RPAREN
	 ;
ident: IDENT
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
	  ;
expr1 : MINUS expr %prec UMINUS
      | PLUS expr %prec UMINUS
	  ;
