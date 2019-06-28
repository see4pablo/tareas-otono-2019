#include <stdlib.h>
#include <stdio.h>

/* Este programa busca x en un arreglo a[0], a[1], a[2], ...
 * usando busqueda binaria.
 * Se incluye una version C compilada en forma nativa y una version
 * en threaded-code.  Uso: test-search-threaded x a[0] a[1] a[2] ...
 * Ejemplo:
 *    % test-search-threaded 5    1 3 5 8 9
 *    3
 *    % test-search-threaded 7    1 3 5 8 9 15 17
 *    -1
 */

/* Estos simbolos estan definidos en archivos .s */
int interprete(int *code, int *sp); /* interp-threaded.s */
extern int codigo_verifica[10];  /* verifica-threaded.s */
extern int codigo_binsearch[10]; /* search-threaded.s */

/* Programa en C para hacer la busqueda binaria */

int binsearch(int x, int* a, int i, int j) {
  int k;
  if (i>j)
    return -1;
  k= (i+j)/2;
  if (a[k]==x)
    return k;
  else if (a[k]<x)
    return binsearch(x, a, k+1, j);
  else
    return binsearch(x, a, i, k-1);
}

/* El stack del interprete */

#define STACK_SIZE 4096
int stack[STACK_SIZE];

/* programa principal que invoca el interprete */

int main(int argc, char **argv) {

  /* Los argumentos de la linea de comandos de test-poli-threaded: */
	int x= atoi(argv[1]);
  int n= argc-2;
  int *arr= (int*)malloc(n*sizeof(int));

  int *sp= &stack[STACK_SIZE]; /* El tope del stack */
  int array_verif[6], retV;
  int valInterp, valCompil;
	int i;

  printf("tamano del arreglo: %d", n);
	for (i= 0; i<n; i++) {
	  arr[i]= atoi(argv[i+2]);
    printf(", a[%d]= %d", i, arr[i]);
	}
	printf("\n");
	fflush(stdout);

  /* primero verificamos que el interprete ande razonablemente bien */
  sp[-1]= (int)array_verif;
  retV= interprete(codigo_verifica, &sp[-1]);
  if (retV!=0) {
    printf("Alguna de las nuevas intrucciones no funciona bien.\n");
    printf("El codigo de error es %d.  Vea en sieve-bytecode que\n", retV);
    printf("instruccion es la que falla, en la declaracion de\n");
    printf("codigo_verifica.\n");
    exit(1);
  }
  if (array_verif[5]!=-123) {
    printf("ST_ARRAY no funciona, no guardo -123 en el indice 5\n");
    exit(1);
  }

	valCompil= binsearch(x, arr, 0, n-1);
  printf("busqueda binaria en C: %d\n", valCompil);
	/* Ahora interpretamos el codigo threaded para la busqueda binaria. */
	sp[-1]= n-1;          /* j */
  sp[-2]= 0;            /* i */
  sp[-3]= (int) arr;    /* a */
  sp[-4]= x;            /* x */
  valInterp= interprete(codigo_binsearch, &sp[-4]);
  printf("busqueda binaria en codigo threaded: %d\n", valInterp);
  if (valInterp!=valCompil)
    printf("error, los valores no coinciden\n");
  else
    printf("bien!\n");
  return 0;
}

