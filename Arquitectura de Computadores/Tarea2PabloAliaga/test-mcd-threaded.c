#include <stdio.h>
#include <stdlib.h>

/* Este programa calcula el maximo común divisor de 2 numeros mediante
 * una version C compilada en forma nativa y una version en bytecode
 * interpretado.  Uso:
 *    % test-mcd-threaded 12 15
 *    mcd interpretado=3
 *    mcd en C= 3
 *    bien!
 *    %
 */

int interprete(int *codigo, int *sp);

/* programa en C para calcular mcd */

int mcd(int x, int y) {
  while (x!=y) {
    if (x<y) y= y-x;
    else     x= x-y;
  }
  return x;
}

/* programa en bytecode para calcular mcd */

/* El stack */

#define STACK_SIZE 4096
int stack[STACK_SIZE];
extern int codigo[10];

/* programa principal que verifica el interprete de threaded code */

int main(int argc, char **argv) {
  int *sp= &stack[STACK_SIZE];
  int x= atoi(argv[1]);
  int y= atoi(argv[2]);
  int retC, retI;
  *--sp= y; /* push y */
  *--sp= x; /* push x */
  retI= interprete(codigo, sp);
  printf("mcd interpretado=%d\n", retI);
  retC= mcd(x, y);
  printf("mcd en C= %d\n", retC);
  if (retC!=retI)
    printf("error, los valores no coinciden\n");
  else
    printf("bien!\n");
  return 0;
}

