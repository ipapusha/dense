#ifndef _PARSE_H
#define _PARSE_H 

#include "cs.h"

/* interface to lexer */
extern int yylineno;		/* from lexer */
void yyerror(char *s, ...);

/* AST node structures */
enum nodetype {
	nPLUS, nMINUS, nTIMES, nDOTTIMES, nDIV, nDOTDIV,
	nHLIST, nVLIST,
	nSCALARVAL,
	nMATRIXVAL,
	nSYMREF,
	nSYMASGN
};
struct symbol {
	char *name;				/* a variable name */
	struct ast *a;			/* value of symbol */
};
struct astpair {
	struct ast *l;			/* left branch */
	struct ast *r;			/* right branch */ 
}; 
struct astlist {
	struct ast *a;			/* linked list */
	struct astlist *next;
};
struct ast {
	enum nodetype type;
	union {
		double sv;			/* scalar value */
		cs *mv;				/* matrix value */
		struct symbol *s;	/* symbol ref */
		struct astpair *ap;	/* contains: l and r */
		struct astlist *al;	/* contains: a and next */
	} op;
};

/* build an AST */
struct ast *newpair(enum nodetype type, struct ast *l, struct ast *r);
struct ast *newlist(enum nodetype type, struct astlist *al);
struct ast *newscalarval(double sv);
struct ast *newmatrixval(cs *mv);
struct ast *newsymref(struct symbol *s);
struct ast *newsymasgn(struct symbol *s, struct ast *v);

/* simple symtab of fixed size */
#define M13 8191
#ifndef NHASH
#define NHASH M13
#endif
struct symtablist {
	struct symbol *s;
	struct symtablist *next;
};
struct symtablist symtab[NHASH];
struct symbol *symlookup(char *name);
void symadd(struct symbol *s);
void symdel(struct symbol *s);

/* evaluate and clean up an AST */
void eval(struct ast *);
void treefree(struct ast *);

#endif
