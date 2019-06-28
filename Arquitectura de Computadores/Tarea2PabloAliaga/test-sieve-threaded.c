#include <stdlib.h>
#include <stdio.h>

/* Este programa calcula los numeros primos hasta 2*n+3 mediante
 * una version C compilada en forma nativa y una version en bytecode
 * interpretado.  Uso:
 *    % test-sieve-threaded 20
 *    primos interpretado: 3 5 7 11 13 17 19 23 29 31 37 41 43
 *    total= 13
 *    primos en C: 3 5 7 11 13 17 19 23 29 31 37 41 43
 *    total= 13
 *    bien!
 *    %
 */

/* Estos simbolos deben ser definidos en sieve-threaded.s como .globl */
int interprete(int *code, int *sp);
extern int codigo_verifica[10];  /* Da lo mismo el tamaño del arreglo */
extern int codigo_sieve[10];     /* % */

/* programa en C para calcular sieve */

int sieve(int* flags, int size) {
  int i=0, prime, k, count= 0;

  while (i<=size) {
    flags[i]=1;
    i++;
  }
  i=0;
  while (i<=size) {
    if(flags[i]==1) {
      prime=i+i+3; printf("%d ", prime);
      k=i+prime;
      while (k<=size) {
        flags[k]=0;
        k+=prime;
      }
      count++;
    }
    i++;
  }
  return count;
}

/* El stack */

#define STACK_SIZE 4096
int stack[STACK_SIZE];

/* programa principal a modo de ejemplo */

int main(int argc, char **argv) {
  int *sp= &stack[STACK_SIZE];
  int retC, retI, retV, i;
  int size= atoi(argv[1]);
  int *flags= (int*)malloc((size+1)*sizeof(int));
  int array_verif[6];

  /* primero verificamos que el interprete ande bien */
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

  sp[-1]= size;
  sp[-2]= (int) flags;
  retI= interprete(codigo_sieve, &sp[-2]); 
  printf("primos interpretado: ");
  for (i=0; i<=size; i++)
    if (flags[i]==1) printf("%d ", i+i+3);
  printf("\ntotal= %d\n", retI);
  printf("primos en C: ");
  retC= sieve(flags, size);
  printf("\ntotal= %d\n", retC);
  if (retC!=retI)
    printf("error, los valores no coinciden\n");
  else
    printf("bien!\n");
  return 0;
}

