#include <stdio.h>
#include <stdlib.h>
#include "parse.h"
#include "parse.tab.h"
#include "lexer.yy.h"

extern int yyparse();
extern void initialize_lexer(FILE *);
extern struct prog *theprog;

int main(int argc, char *argv[]) {
	FILE *input;
	int pstatus;
	//struct prog *pr;

	if (argc > 1) {
		input = fopen(argv[1], "r");
		if (!input) {
			fprintf(stderr, "Error opening input file.\n");
			exit(1);
		}
	} else {
		input = stdin;
	}
	
	//pr = NULL;
	initialize_lexer(input);
	pstatus = yyparse();
	printf("yyparse() = %d\n", pstatus);

	printprog(theprog);

	return 0;
}

