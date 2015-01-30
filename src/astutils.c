#include <assert.h>
#include "astutils.h"

#define REVERSE_LINKEDLIST_METHODBODY(node_t, head) {		\
			node_t *n1, *n2;								\
			if (!(head) || !((head)->next)) return (head);	\
			n1 = (head)->next;								\
			(head)->next = NULL;							\
			while (n1) {									\
				n2 = n1->next;								\
				n1->next = (head);							\
				(head) = n1;								\
				n1 = n2;									\
			}												\
			return (head);									\
		}

/* assumes no cycles */
struct stmt_list *reversestmt_list(struct stmt_list *head) {
	REVERSE_LINKEDLIST_METHODBODY(struct stmt_list, head);
}
struct expr_list *reverseexpr_list(struct expr_list *head) {
	REVERSE_LINKEDLIST_METHODBODY(struct expr_list, head);
}
struct concat_list *reverseconcat_list(struct concat_list *head) {
	REVERSE_LINKEDLIST_METHODBODY(struct concat_list, head);
}
