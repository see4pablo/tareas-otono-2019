#include <stdio.h>
#include <stdlib.h>

/* Este programa calcula el maximo común divisor de 2 numeros mediante
 * una version C compilada en forma nativa y una version en bytecode
 * interpretado.  Uso:
 *    % mcd-bytecode 12 15
 *    ... traza del bytecode interpretado ...
 *    mcd interpretado=3
 *    mcd en C= 3
 *    bien!
 *    %
 */

/* El set de instrucciones del interprete */

int interprete(char *code, int *sp);

#define ARG0    0  /* carga 1er. argumento */
#define ARG1    1  /* carga 2do. argumento */
#define ST_ARG0 2  /* guarda 1er. argumento */
#define ST_ARG1 3  /* guarda 2do. argumento */
#define JMP     4  /* salto incondicional en un cierto desplazamiento */
#define JMPEQ   5  /* salta si los 2 elem. del tope de la pila son == */
#define JMPGE   6  /* salta si el 2do. elem. es >= que el 1er. elem. */
#define RET     7  /* retorna del interprete */
#define SUB     8  /* calcula 2do. elem. - 1er. elem. y lo deja en la pila */

/* Los nombres de las intrucciones para poder hacer debugging */
char *names[]= {
  "ARG0", "ARG1", "ST_ARG0", "ST_ARG1",
  "JMP", "JMPEQ", "JMPGE",
  "RET",
  "SUB"
};

/* programa en C para calcular mcd */

int mcd(int x, int y) {
  while (x!=y) {
    if (x<y) y= y-x;
    else     x= x-y;
  }
  return x;
}

/* programa en bytecode para calcular mcd */

char code[] = { 
  /* while (x!=y) */
  ARG0,           /* push x */
  ARG1,           /* push y */
  /* etiqueta WHILE */
  JMPEQ, 16,      /* b= pop  a= pop  if (a==b) pc= pc+16 */

  /* if (x<y) */
  ARG0,           /* push x */
  ARG1,           /* push y */
  JMPGE, 6,       /* b= pop  a= pop  if (a>=b) pc= pc+6 */

  /* y= y-x */
  ARG1,           /* push y */
  ARG0,           /* push x */
  SUB,            /* b= pop  a= pop  push a-b */
  ST_ARG1,        /* y= pop */
  JMP, -14,       /* pc= pc - 14 */

  /* etiqueta ELSE */
  /* x= x-y */
  ARG0,           /* push x */
  ARG1,           /* push y */
  SUB,            /* b= pop  a= pop  push a-b */
  ST_ARG0,        /* x= pop */
  JMP, -20,       /* pc= pc - 20 */

  /* etiqueta RET */
  /* return x */
  ARG0,           /* push x */
  RET
};

/* El stack */

#define STACK_SIZE 4096
int stack[STACK_SIZE];

/* programa principal a modo de ejemplo */

int main(int argc, char **argv) {
  int *sp= &stack[STACK_SIZE];
  int x= atoi(argv[1]);
  int y= atoi(argv[2]);
  int retC, retI;
  *--sp= y; /* push y */
  *--sp= x; /* push x */
  retI= interprete(code, sp); 
  printf("mcd interpretado=%d\n", retI);
  retC= mcd(x, y);
  printf("mcd en C= %d\n", retC);
  if (retC!=retI)
    printf("error, los valores no coinciden\n");
  else
    printf("bien!\n");
  return 0;
}

int interprete(char *code, int *sp) {
  int *fp= sp; /* frame pointer es el puntero a los parametros */
  char *pc= code;
  for(;;) {
    /* Para fines de debugging se despliega una linea con:
     * el contador de programa, el puntero a la pila,
     * 1er., 2do. y 3er. elemento de la pila,
     * codigo de instruccion a ejecutar
     */
    printf("pc=%3d sp=%4d sp[0]=%d sp[1]=%d sp[2]=%d inst=%s\n",
            pc-code, sp-fp, sp[0], sp[1], sp[2], names[*pc]);

    /* el contador de programa pc, apunta al un byte que contiene
     * el codigo de la instruccion que se debe ejecutar.
     */
    switch(*pc++) {
      /* las instrucciones operan con el stack.  El tope de la pila
       * es apuntado por sp.
       * Para apilar un valor:         *--sp= ... valor ...
       * Para obtener y sacar
       * el valor del tope del stack:  ... *sp++ ...
       * El 1er. y 2do parametro se encuentran en fp[0] y fp[1].
       */
      case ARG0: {      /* apilar primer argumento */
        *--sp= fp[0];
        break;
      }
      case ARG1: {      /* apilar 2do. argumento */
        *--sp= fp[1];
        break;
      }
      case ST_ARG0: {   /* guardar primer argumento */
        fp[0]= *sp++;
        break;
      }
      case ST_ARG1: {   /* guardar 2do. argumento */
        fp[1]= *sp++;
        break;
      }
      case SUB: {       /* la resta */
        int y= *sp++, x= *sp++;
        *--sp= x-y;
        break;
      }
      case JMP: {       /* salto incondicional */
        int disp= *pc++;
        pc+= disp;
        break;
      }
      case JMPEQ: {     /* salta si == */
        int disp= *pc++;
        int y= *sp++, x= *sp++;
        if (x==y)
          pc+= disp;
        break;
      }
      case JMPGE: {     /* salta si >= */
        int disp= *pc++;
        int y= *sp++, x= *sp++;
        if (x>=y)
          pc+= disp;
        break;
      }
      case RET: {       /* retornar del interprete */
        int ret= *sp++; /* pop del valor a retornar */
        return ret;
      }
      default:
        fprintf(stderr, "codigo de instruccion desconocido: %d\n", pc[-1]);
        exit(1);
    }
  }
}
