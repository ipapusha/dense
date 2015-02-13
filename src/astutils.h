#ifndef _ASTUTILS_H
#define _ASTUTILS_H

#include "parse.h"

/* common manipulations */
#define reverse_list(head) _Generic((head), \
		struct stmt_list *: reversestmt_list, \
		struct expr_list *: reverseexpr_list, \
		struct concat_list *: reverseconcat_list, \
		default: reversestmt_list)(head)

struct stmt_list *reversestmt_list(struct stmt_list *head);
struct expr_list *reverseexpr_list(struct expr_list *head);
struct concat_list *reverseconcat_list(struct concat_list *head);


/* offline resolution */
void resolve_matrix(struct matrix *m);


#endif
