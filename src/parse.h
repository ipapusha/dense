#ifndef _PARSE_H
#define _PARSE_H 

#include <stdarg.h>
#include "cs.h"

/* interface to lexer */
extern int yylineno;			/* from lexer */
void yyerror(char *s, ...);

/* grammar */
struct prog {
	struct stmt_list *sl;
};
struct stmt_list {
	struct stmt *s;
	struct stmt_list *next;
};
typedef enum { sASSIGN, sEXPR } stmt_e;
struct stmt {
	stmt_e type;
	union {
		struct assign_stmt *as;
		struct expr_stmt *es;
	};
};
struct assign_stmt {
	struct ident *id;
	struct expr *e;
};
struct expr_stmt {
	struct expr *e;
};
struct expr_list {				/* expr separated by commas */
	struct expr *e;
	struct expr_list *next;
};
struct concat_list {			/* expr lists separated by semicolons */
	struct expr_list *el;
	struct concat_list *next;
};
typedef enum { idVAR, idFUNC } ident_e;
struct ident {					/* identifier */
	ident_e type;				/* TODO: add idPARAMVAR */
	char *name;
	struct expr_list *el;		/* optional arguments list */
};
typedef enum { mCL, mEL, mMV } matrix_e;
struct matrix {					/* abstract matrix type */
	matrix_e type;
	union {
		struct concat_list *cl;	/* vertical concatenation */
		struct expr_list *el;	/* horizontal concatenation */
		cs *mv;					/* resolved matrix value */
	};
};
typedef enum { e2BACKSLASH, e2DIV, e2DOTDIV, e2DOTEXP, e2DOTMUL, e2EXP,
				e2MINUS, e2MUL, e2PLUS } expr2_e;
struct expr2 {					/* binary expression */
	expr2_e type;
	struct expr *l;
	struct expr *r;
};
typedef enum { e1MINUS, e1PLUS } expr1_e;
struct expr1 {					/* unary expression */
	expr1_e type;
	struct expr *e;
};

typedef enum { eIDENT, eNUMBER, eMATRIX, eEXPR2, eEXPR1, eTRANSPOSE, eFUNCALL }
				expr_e;
struct expr {					/* general expression */
	expr_e type;
	union {
		struct ident *id;		/* identifier */
		double sv;				/* scalar number value */
		struct matrix *m;		/* abstract matrix */
		struct expr2 *e2;		/* binary expression */
		struct expr1 *e1;		/* unary expression */
		struct expr *et;		/* expr to transpose */
	};
};

/* build an AST */
struct prog *newprog (struct stmt_list *sl);
struct stmt_list *newstmt_list (struct stmt *s, struct stmt_list *next);
struct stmt *newstmt (stmt_e type, struct assign_stmt *as, 
		struct expr_stmt *es);
struct assign_stmt *newassign_stmt (struct ident *id, struct expr *e);
struct expr_stmt *newexpr_stmt (struct expr *e);
struct expr_list *newexpr_list (struct expr *e, struct expr_list *next);
struct concat_list *newconcat_list (struct expr_list *el, 
		struct concat_list *next);
struct ident *newident (ident_e type, char *name, struct expr_list *el);
struct matrix *newmatrix (matrix_e type, struct concat_list *cl, 
		struct expr_list *el, cs *mv);
struct expr2 *newexpr2 (expr2_e type, struct expr *l, struct expr *r);
struct expr1 *newexpr1 (expr1_e type, struct expr *e);
struct expr *newexpr (expr_e type, struct ident *id, double sv, 
		struct matrix *m, struct expr2 *e2, struct expr1 *e1, struct expr *et);

/* print AST */
void printprog(struct prog *);
void printstmt_list(struct stmt_list *);
void printstmt(struct stmt *);
void printassign_stmt(struct assign_stmt *);
void printexpr_stmt(struct expr_stmt *);
void printexpr_list(struct expr_list *);
void printconcat_list(struct concat_list *);
void printident(struct ident *);
void printmatrix(struct matrix *);
void printexpr2(struct expr2 *);
void printexpr1(struct expr1 *);
void printexpr(struct expr *);

/* clean up AST */
void delprog(struct prog *);
void delstmt_list(struct stmt_list *);
void delstmt(struct stmt *);
void delassign_stmt(struct assign_stmt *);
void delexpr_stmt(struct expr_stmt *);
void delexpr_list(struct expr_list *);
void delconcat_list(struct concat_list *);
void delident(struct ident *);
void delmatrix(struct matrix *);
void delexpr2(struct expr2 *);
void delexpr1(struct expr1 *);
void delexpr(struct expr *);

/* simple symtab of fixed size */
#define M13 8191
#ifndef NHASH
#define NHASH M13
#endif
/*
struct symtablist {
	struct symbol *s;
	struct symtablist *next;
};
struct symtablist symtab[NHASH];
struct symbol *symlookup(char *name);
void symadd(struct symbol *s);
void symdel(struct symbol *s);
*/

#endif
