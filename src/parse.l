/* recognize tokens for the calculator */
%option noyywrap nodefault yylineno
%{
#include "parse.h"
#include "parse.tab.h"
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
[a-zA-Z][a-zA-Z0-9]*	{ yylval.str = yytext; return IDENT; }
[0-9]+"."[0-9]*{EXP}? | 
"."?[0-9]+{EXP}?		{ yylval.d = atof(yytext); return NUMBER; }

"//".*	{ /* ignore comment */ }
"#".*	{ /* ignore comment */ }
"%".*	{ /* ignore comment */ }
[ \t]	{ /* ignore whitespace */ }
\\\n	{ /* ignore line continuation */ }

\n		{ return EOL; }
.		{ yyerror("Unknown character %c\n", *yytext); }
%%
