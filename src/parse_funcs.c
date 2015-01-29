#define _XOPEN_SOURCE 700
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>	/* strdup, which requires _XOPEN_SOURCE>=500 above */
#include "parse.h"

static inline void fail_ifnull(void *ptr) {
	if (!ptr) {
		yyerror("failed to allocate AST space");
		exit(0);
	}
}

/* build an AST */
struct prog *newprog (struct stmt_list *sl) {
	struct prog *pr = malloc(sizeof(struct prog));
	fail_ifnull(pr);
	pr->sl = sl;
	return pr;
}
struct stmt_list *newstmt_list (struct stmt *s, struct stmt_list *next) {
	struct stmt_list *sl = malloc(sizeof(struct stmt_list));
	fail_ifnull(sl);
	sl->s = s;
	sl->next = next;
	return sl;
}
struct stmt *newstmt (stmt_e type, struct assign_stmt *as, 
		struct expr_stmt *es) {
	struct stmt *s = malloc(sizeof(struct stmt));
	fail_ifnull(s);
	s->type = type;
	switch (type) {
		case sASSIGN: s->as = as; break;
		case sEXPR: s->es = es; break;
		default: yyerror("bad type %d", type); exit(0); break;
	}
	return s;
}
struct assign_stmt *newassign_stmt (struct ident *id, struct expr *e) {
	struct assign_stmt *as = malloc(sizeof(struct assign_stmt));
	fail_ifnull(as);
	as->id = id;
	as->e = e;
	return as;
}
struct expr_stmt *newexpr_stmt (struct expr *e) {
	struct expr_stmt *es = malloc(sizeof(struct expr_stmt));
	fail_ifnull(es);
	es->e = e;
	return es;
}
struct expr_list *newexpr_list (struct expr *e, struct expr_list *next) {
	struct expr_list *el = malloc(sizeof(struct expr_list));
	fail_ifnull(el);
	el->e = e;
	el->next = next;
	return el;
}
struct concat_list *newconcat_list (struct expr_list *el, 
		struct concat_list *next) {
	struct concat_list *cl = malloc(sizeof(struct concat_list));
	fail_ifnull(cl);
	cl->el = el;
	cl->next = next;
	return cl;
}
struct ident *newident (ident_e type, char *name, struct expr_list *el) {
	struct ident *id = malloc(sizeof(struct ident));
	fail_ifnull(id);
	id->type = type;
	id->name = strdup(name);	/* TODO: do we really need to copy here? */
	fail_ifnull(id->name);
	id->el = el;
	return id;
}
struct matrix *newmatrix (matrix_e type, struct concat_list *cl, 
		struct expr_list *el, cs *mv) {
	struct matrix *m = malloc(sizeof(struct matrix));
	fail_ifnull(m);
	m->type = type;
	switch (type) {
		case mCL: m->cl = cl; break;
		case mEL: m->el = el; break;
		case mMV: m->mv = mv; break;
		default: yyerror("bad type %d", type); exit(0); break;
	}
	return m;
}
struct expr2 *newexpr2 (expr2_e type, struct expr *l, struct expr *r) {
	struct expr2 *e2 = malloc(sizeof(struct expr2));
	fail_ifnull(e2);
	e2->type = type;
	e2->l = l;
	e2->r = r;
	return e2;
}
struct expr1 *newexpr1 (expr1_e type, struct expr *e) {
	struct expr1 *e1 = malloc(sizeof(struct expr1));
	fail_ifnull(e1);
	e1->type = type;
	e1->e = e;
	return e1;
}
struct expr *newexpr (expr_e type, struct ident *id, double sv, 
		struct matrix *m, struct expr2 *e2, struct expr1 *e1, struct expr *et) {
	struct expr *e = malloc(sizeof(struct expr));
	fail_ifnull(e);
	e->type = type;
	switch (type) {
		case eIDENT: e->id = id; break;
		case eNUMBER: e->sv = sv; break;
		case eMATRIX: e->m = m; break;
		case eEXPR2: e->e2 = e2; break;
		case eEXPR1: e->e1 = e1; break;
		case eTRANSPOSE: e->et = et; break;
		case eFUNCALL: /* TODO: eFUNCALL fails here */
		default: yyerror("bad type %d", type); exit(0); break;
	}
	return e;
}

/* clean up AST */
void delprog(struct prog *pr) {
	if (pr) {
		delstmt_list(pr->sl);
		free(pr);
	}
}
void delstmt_list(struct stmt_list *sl) {
	struct stmt_list *sl0;
	while (sl) {
		sl0 = sl;
		sl = sl->next;
		delstmt(sl0->s);
		free(sl0);
	}
}
void delstmt(struct stmt *s) {
	if (s) {
		switch (s->type) {
			case sASSIGN: delassign_stmt(s->as); break;
			case sEXPR: delexpr_stmt(s->es); break;
			default: yyerror("bad type %d", s->type); exit(0); break;
		}
		free(s);
	}
}
void delassign_stmt(struct assign_stmt *as) {
	if (as) {
		delident(as->id);
		delexpr(as->e);
		free(as);
	}
}
void delexpr_stmt(struct expr_stmt *es) {
	if (es) {
		delexpr(es->e);
		free(es);
	}
}
void delexpr_list(struct expr_list *el) {
	struct expr_list *el0;
	while (el) {
		el0 = el;
		el = el->next;
		delexpr(el0->e);
		free(el0);
	}
}
void delconcat_list(struct concat_list *cl) {
	struct concat_list *cl0;
	while (cl) {
		cl0 = cl;
		cl = cl->next;
		delexpr_list(cl0->el);
		free(cl0);
	}
}
void delident(struct ident *id) {
	if (id) {
		free(id->name);			/* XXX: unsafe if id->name is on the stack */
		delexpr_list(id->el);
		free(id);
	}
}
void delmatrix(struct matrix *m) {
	if (m) {
		switch (m->type) {
			case mCL: delconcat_list(m->cl); break;
			case mEL: delexpr_list(m->el); break;
			case mMV: cs_spfree(m->mv); break;
			default: yyerror("bad type %d", m->type); exit(0); break;
		}
		free(m);
	}
}
void delexpr2(struct expr2 *e2) {
	if (e2) {
		delexpr(e2->l);
		delexpr(e2->r);
		free(e2);
	}
}
void delexpr1(struct expr1 *e1) {
	if (e1) {
		delexpr(e1->e);
		free(e1);
	}
}
void delexpr(struct expr *e) {
	if (e) {
		switch (e->type) {
			case eIDENT: delident(e->id); break;
			case eNUMBER: /* nothing to free */ break;
			case eMATRIX: delmatrix(e->m); break;
			case eEXPR2: delexpr2(e->e2); break;
			case eEXPR1: delexpr1(e->e1); break;
			case eTRANSPOSE: delexpr(e->et); break;
			case eFUNCALL: /* TODO: eFUNCALL fails here */
			default: yyerror("bad type %d", e->type); exit(0); break;
		}
		free(e);
	}
}

void yyerror(char *s, ...) {
	va_list ap;
	va_start(ap, s);

	fprintf(stderr, "%d: error: ", yylineno);
	vfprintf(stderr, s, ap);
	fprintf(stderr, "\n");
}

/*
int main(int argc, char *argv[]) {
	printf("> ");
	return yyparse();
}
*/
