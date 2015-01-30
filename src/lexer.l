/* recognize tokens for the calculator */
%option noyywrap nodefault yylineno 
%option nounput noinput
%{
	#include <stdio.h>
	#include <string.h> /* strdup, which requires _XOPEN_SOURCE>=500 */
	#include "parse.h"
	#include "parse.tab.h"

	extern int fileno(FILE *);
%}

/* float exponent */
EXP		([Ee][-+]?[0-9]+)

%%
 /* single character ops */
"="		{ return EQ;		}
","		{ return COMMA;		}
"+"		{ return PLUS;		}
"-"		{ return MINUS;		}
"*"		{ return MUL;		}
"/"		{ return DIV;		}
".*"	{ return DOTMUL;	}
"./"	{ return DOTDIV;	}
"\\"	{ return BACKSLASH;	}
"'"		{ return TRANSPOSE;	}
".'"	{ return TRANSPOSE;	}
"^"		{ return EXP;		}
".^"	{ return DOTEXP;	}
"("		{ return LPAREN;	}
")"		{ return RPAREN;	}
"["		{ return LBRACKET;	}
"]"		{ return RBRACKET;	}
";"		{ return SEMI;		}

 /* IDENT, NUMBER */
[a-zA-Z][a-zA-Z0-9]*	{ yylval.str = strdup(yytext); return IDENT; }
[0-9]+"."[0-9]*{EXP}? | 
"."?[0-9]+{EXP}?		{ yylval.d = atof(yytext); return NUMBER; }

"//".*	{ /* ignore comment */ }
"#".*	{ /* ignore comment */ }
"%".*	{ /* ignore comment */ }
[ \t]	{ /* ignore whitespace */ }
\\\n	{ /* ignore line continuation */ }

\n		{ /* ignore end of line */ }
<<EOF>> { return 0; }
.		{ yyerror("Unknown character %c\n", *yytext); }
%%
void initialize_lexer(FILE *inp) { yyin = inp; }
