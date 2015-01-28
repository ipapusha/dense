#include <stdio.h>
#include "cs.h"

void sample(const cs *B2, const cs *f, 
			cs **G, cs **H, cs **J) {
	/* constants */
	int Ap[]    = { 0,       3,      6};
	int Ai[]    = { 0, 1, 2, 0, 1, 2 };
	double Ax[] = { 1, 2, 3, 4, 5, 6 };
	cs A = { sizeof(Ax)/sizeof(Ax[0]), 3, 2, Ap, Ai, Ax, -1};
	
	int Bp[]    = { 0, 1,   3};
	int Bi[]    = { 0, 0, 1 };
	double Bx[] = { 7, 1, 2 };
	cs B = { sizeof(Bx)/sizeof(Bx[0]), 2, 2, Bp, Bi, Bx, -1};

	int A2p[]    = { 0,       3, 4 };
	int A2i[]    = { 0, 1, 2, 1 };
	double A2x[] = { 7, 8, 9, 1 };
	cs A2 = { sizeof(A2x)/sizeof(A2x[0]), 3, 2, A2p, A2i, A2x, -1};

	/* temporaries */
	cs *G2;

	printf("A\n");
	cs_print(&A, 1);
	
	printf("B\n");
	cs_print(&B, 1);

	printf("A2\n");
	cs_print(&A2, 1);
	
	printf("B2\n");
	cs_print(B2, 1);

	/* perform operations */
	*G = cs_multiply(&A, &B);
	G2 = cs_multiply(&A2, B2);
	//*H = cs_multiply(*G, f);
	*H = cs_add(*G, *G, (f->x)[0], 0);
	*J = cs_add(G2, &A2, 1, 1);

	printf("G2:\n");
	cs_print(G2, 1);

	/* clean up temporaries */
	cs_free(G2);
}



int main(int argc, char *argv[]) {
	
	/* parameters */
	int B2p[]    = { 0,      2,     4 };
	int B2i[]    = { 0,  1,  0,  1  };
	double B2x[] = { 10, 12, 11, 13 };
	const cs B2 = { sizeof(B2x)/sizeof(B2x[0]), 2, 2, B2p, B2i, B2x, -1};
	
	int fp[]    = { 0, 1 };
	int fi[]    = { 0 };
	double fx[] = { 14 };
	const cs f = { sizeof(fx)/sizeof(fx[0]), 1, 1, fp, fi, fx, -1};

	cs *G, *H, *J;	 /* answers from routine */

	sample(&B2, &f, &G, &H, &J);

	printf("B2:\n");
	cs_print(&B2, 1);

	printf("f:\n");
	cs_print(&f, 1);

	printf("G:\n");
	cs_print(G, 1);

	printf("H:\n");
	cs_print(H, 1);

	printf("J:\n");
	cs_print(J, 1);

	return 0;
}
