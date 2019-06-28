#include <stdio.h>
#include <stdlib.h>

/* Este programa calcula los numeros primos hasta 2*n+3 mediante
 * una version C compilada en forma nativa y una version en bytecode
 * interpretado.  Uso:
 *    % sieve-bytecode 20
 *    ... traza del bytecode interpretado ...
 *    primos interpretado: 3 5 7 11 13 17 19 23 29 31 37 41 43
 *    total= 13
 *    primos en C: 3 5 7 11 13 17 19 23 29 31 37 41 43
 *    total= 13
 *    bien!
 *    %
 */

/* El set de instrucciones del interprete */

int interprete(char *code, int *sp);

/* instrucciones necesarias para mcd */

#define ARG0    0  /* apila 1er. argumento */
#define ARG1    1  /* apila 2do. argumento */
#define ST_ARG0 2  /* guarda 1er. argumento */
#define ST_ARG1 3  /* guarda 2do. argumento */
#define JMP     4  /* salto incondicional en un cierto desplazamiento */
#define JMPEQ   5  /* salta si los 2 elem. del tope de la pila son == */
#define JMPGE   6  /* salta si el 2do. elem. es >= que el 1er. elem. */
#define RET     7  /* retorna del interprete */
#define SUB     8  /* calcula 2do. elem. - 1er. elem. y lo deja en la pila */

/* instrucciones necesarias para sieve */

#define LOCAL0  9  /* apila 1era. variable local */
#define LOCAL1  10 /* apila 2da. variable local */
#define LOCAL2  11 /* apila 3era. variable local */
#define LOCAL3  12 /* apila 4ta. variable local */
#define ST_LOCAL0 13 /* guarda 1era. variable local */
#define ST_LOCAL1 14 /* guarda 2da. variable local */
#define ST_LOCAL2 15 /* guarda 3era. variable local */
#define ST_LOCAL3 16 /* guarda 4ta. variable local */

#define ARRAY     17 /* apila un elemento de un arreglo */
#define ST_ARRAY  18 /* guarda un elemento de un arreglo */

#define ADD     19 /* calcula 2do. elem. + 1er. elem. y lo deja en la pila */

#define JMPNE   20 /* salta si los 2 elem. del tope de la pila son != */
#define JMPGT   21 /* salta si el 2do. elem. es > que el 1er. elem. */

#define PUSH    22 /* apila una constante */

/* Los nombres de las intrucciones para poder hacer debugging */
char *names[]= {
  "ARG0", "ARG1", "ST_ARG0", "ST_ARG1",
  "JMP", "JMPEQ", "JMPGE",
  "RET",
  "SUB",

  "LOCAL0", "LOCAL1", "LOCAL2", "LOCAL3",
  "ST_LOCAL0", "ST_LOCAL1", "ST_LOCAL2", "ST_LOCAL3",
  "ARRAY", "ST_ARRAY",
  "ADD",
  "JMPNE", "JMPGT",
  "PUSH"
};

/* Bytecode que verifica el buen funcionamiento del las nuevas
 * instrucciones.  Supone que funciona PUSH y JMPEQ.
 * Cuando se detecta una inconsistencia, se ejecuta:
 *    PUSH, ... codigo de error ...,
 *    RET,
 * Si su solicion no funciona y arroja un codigo de error, compare
 * el codigo de error con los numeros negativos que aparecen en las
 * instrucciones PUSH.  La explicacion que aparece al lado indica que
 * instruccion fallo.
 */

char code_verifica[]= {
  /* Verifica que funciona los LOCALx */
  PUSH, 1,
  PUSH, 2,
  PUSH, 3,
  PUSH, 4,

  LOCAL0,
  PUSH, 1,
  JMPEQ, 3,
  PUSH, -1, /* No funciona LOCAL0 */
  RET,

  LOCAL1,
  PUSH, 2,
  JMPEQ, 3,
  PUSH, -2, /* No funciona LOCAL1 */
  RET,

  LOCAL2,
  PUSH, 3,
  JMPEQ, 3,
  PUSH, -3, /* No funciona LOCAL2 */
  RET,

  LOCAL3,
  PUSH, 4,
  JMPEQ, 3,
  PUSH, -4, /* No funciona LOCAL3 */
  RET,

  /* Verifica que funcionan los ST_LOCALx */
  PUSH, 10,
  ST_LOCAL0,
  PUSH, 10,
  LOCAL0,
  JMPEQ, 3,
  PUSH, -10, /* No funciona ST_LOCAL0 */
  RET,

  PUSH, 20,
  ST_LOCAL1,
  PUSH, 20,
  LOCAL1,
  JMPEQ, 3,
  PUSH, -11, /* No funciona ST_LOCAL1 */
  RET,

  PUSH, 30,
  ST_LOCAL2,
  PUSH, 30,
  LOCAL2,
  JMPEQ, 3,
  PUSH, -12, /* No funciona ST_LOCAL2 */
  RET,

  PUSH, 40,
  ST_LOCAL3,
  PUSH, 40,  /* Se vuelve a chequear al final del programa! */
  LOCAL3,
  JMPEQ, 3,
  PUSH, -13, /* No funciona ST_LOCAL3 */
  RET,

  /* Verifica que funcione ARRAY y ST_ARRAY */
  ARG0,
  PUSH, 5,
  PUSH, -123,
  ST_ARRAY,
  ARG0,
  PUSH, 5,
  ARRAY,
  PUSH, -123,
  JMPEQ, 3,
  PUSH, -20, /* No funciona ARRAY o ST_ARRAY */
  RET,

  /* Verifica que funcione ADD */
  PUSH, 5,
  PUSH, 15,
  ADD,
  PUSH, 20,
  JMPEQ, 3,
  PUSH, -30, /* No funciona ADD */
  RET,

  /* Verifica que funcione JMPNE */

  PUSH, 1,
  PUSH, 2,
  JMPNE, 3,
  PUSH, -40, /* No funciona JMPNE: no salto cuando es menor */
  RET,

  PUSH, 2,
  PUSH, 1,
  JMPNE, 3,
  PUSH, -41, /* No funciona JMPNE: no salto cuando es mayor */
  RET,

  PUSH, 10,
  PUSH, 10,
  JMPNE, 2,
  JMP, 3,
  PUSH, -42, /* No funciona JMPNE: salta cuando hay igualdad */
  RET,

  /* Verifica que funcione JMPGT */

  PUSH, 5,
  PUSH, 2,
  JMPGT, 3,
  PUSH, -50, /* No funciona JMPGT: no salta cuando deberia */
  RET,

  PUSH, 10,
  PUSH, 10,
  JMPGT, 2,
  JMP, 3,
  PUSH, -51, /* No funciona JMPGT: salta cuando hay igualdad */
  RET,

  PUSH, 10,
  PUSH, 15,
  JMPGT, 2,
  JMP, 3,
  PUSH, -52, /* No funciona JMPGT: salta cuando es menor */
  RET,

  PUSH, 40,
  JMPEQ, 3,
  PUSH, -60, /* Los movimientos del puntero de la pila son incorrectos: */
  RET,       /* A estas alturas, deberia apuntar hacia la 4ta. variable */
             /* local, que contiene 40 */

  PUSH, 0,   /* La instrucciones parecen funcionar ok */
  RET
};

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

/* programa en bytecode para calcular sieve(totiter, flags, size) */

char code[] = { 
  PUSH, 0,        /* i= 0     (LOCAL0) */
  PUSH, 0,        /* prime    (LOCAL1) */
  PUSH, 0,        /* k        (LOCAL2) */
  PUSH, 0,        /* count= 0 (LOCAL3) */

  /* while (i<=size) ... */
  /* etiqueta INI */
  LOCAL0,         /* push i */
  ARG1,           /* push size */
  JMPGT, 12,       /* if (i>size) goto CALC */

  /* flags[i]= 1 */
  ARG0,           /* push flags */
  LOCAL0,         /* push i */
  PUSH, 1,        /* push 1 */
  ST_ARRAY,       /* v= pop  i= pop  a= pop  a[i]= v */

  /* i++ */
  LOCAL0,         /* push i */
  PUSH, 1,        /* push 1 */
  ADD,            /* y=pop  x= pop  push x+y */
  ST_LOCAL0,      /* i= pop */
  JMP, -16,       /* goto INI */

  /* etiqueta CALC */
  /* i=0; */
  PUSH, 0,        /* push 0 */
  ST_LOCAL0,      /* i= pop */

  /* etiqueta CICLOI */
  /* while (i<=size) */
  LOCAL0,         /* push i */
  ARG1,           /* push size */
  JMPGT, 45,       /* if (i>size) goto RETORNAR */

  /*   if(flags[i]==1) */
  ARG0,           /* push flags */
  LOCAL0,         /* push i */
  ARRAY,          /* a= pop  i= pop  push a[i] */
  PUSH, 1,        /* push 1 */
  JMPNE, 31,       /* if (flags[i]!=1) goto INCI */

  /* prime= i+i+3 */
  LOCAL0,         /* push i */
  LOCAL0,         /* push i */
  ADD,            /* y= pop  x= pop  push x+y */
  PUSH, 3,        /* push 3 */
  ADD,            /* y= pop  x= pop  push x+y */
  ST_LOCAL1,      /* prime= pop */

  /* k=i+prime; */
  LOCAL0,          /* push i */
  LOCAL1,          /* push prime */
  ADD,             /* y= pop  x= pop  push x+y */
  ST_LOCAL2,       /* k= pop */

  /* etiqueta CICLOK */
  /* while (k<=size) */
  LOCAL2,          /* push k */
  ARG1,            /* push size */
  JMPGT, 11,        /* y= pop  x= pop  if (x>y) goto INC_COUNT */

  /* flags[k]=0; */
  ARG0,            /* push flags */
  LOCAL2,          /* push k */
  PUSH, 0,         /* push 0 */
  ST_ARRAY,        /* v= pop  idx=pop  a= pop  a[idx]= v */
  /* k+= prime */
  LOCAL2,          /* push k */
  LOCAL1,          /* push prime */
  ADD,             /* y= pop  x= pop  push x+y */
  ST_LOCAL2,       /* k= pop */
  JMP, -15,        /* goto CICLOK */

  /* etiqueta INC_COUNT */
  /* count++; */
  LOCAL3,          /* push count */
  PUSH, 1,         /* push 1 */
  ADD,             /* y= pop  x= pop  push x+y */
  ST_LOCAL3,       /* count= pop */

  /* etiqueta INCI */
  /* i++ */
  LOCAL0,           /* push i */
  PUSH, 1,          /* push 1 */
  ADD,              /* y= pop  x= pop  push x+y */
  ST_LOCAL0,        /* i= pop */
  JMP, -49,          /* goto CALC */

  /* etiqueta RETORNAR */
  LOCAL3,
  RET
};

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
  retV= interprete(code_verifica, &sp[-1]);
  if (retV!=0) {
    printf("Alguna de las nuevas intrucciones no funciona bien.\n");
    printf("El codigo de error es %d.  Vea en sieve-bytecode que\n", retV);
    printf("instruccion es la que falla, en la declaracion de\n");
    printf("code_verifica.\n");
    exit(1);
  }
  if (array_verif[5]!=-123) {
    printf("ST_ARRAY no funciona, no guardo -123 en el indice 5\n");
    exit(1);
  }

  sp[-1]= size;
  sp[-2]= (int) flags;
  retI= interprete(code, &sp[-2]); 
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
    switch(*pc++) {
      case PUSH: {
        *--sp= *pc;
        pc++;
        break;
      }
      case ARG0: {
        *--sp= fp[0];
        break;
      }
      case ST_ARG0: {
        fp[0]= *sp++;
        break;
      }
      case ARG1: {
        *--sp= fp[1];
        break;
      }
      case ST_ARG1: {
        fp[1]= *sp++;
        break;
      }
      case LOCAL0: {
        *--sp= fp[-1];
        break;
      }
      case ST_LOCAL0: {
        fp[-1]= *sp++;
        break;
      }
      case LOCAL1: {
        *--sp= fp[-2];
        break;
      }
      case ST_LOCAL1: {
        fp[-2]= *sp++;
        break;
      }
      case LOCAL2: {
        *--sp= fp[-3];
        break;
      }
      case ST_LOCAL2: {
        fp[-3]= *sp++;
        break;
      }
      case LOCAL3: {
        *--sp= fp[-4];
        break;
      }
      case ST_LOCAL3: {
        fp[-4]= *sp++;
        break;
      }
      case ARRAY: {
        int i= *sp++;
        int *a= (int*)(*sp++);
        *--sp= a[i];
        break;
      }
      case ST_ARRAY: {
        int v= *sp++;
        int i= *sp++;
        int *a= (int*)(*sp++);
        a[i]= v;
        break;
      }
      case ADD: {
        int y= *sp++, x= *sp++;
        *--sp= x+y;
        break;
      }
      case SUB: {
        int y= *sp++, x= *sp++;
        *--sp= x-y;
        break;
      }
      case JMP: {
        int disp= *pc++;
        pc+= disp;
        break;
      }
      case JMPEQ: {
        int disp= *pc++;
        int y= *sp++, x= *sp++;
        if (x==y)
          pc+= disp;
        break;
      }
      case JMPNE: {
        int disp= *pc++;
        int y= *sp++, x= *sp++;
        if (x!=y)
          pc+= disp;
        break;
      }
      case JMPGE: {
        int disp= *pc++;
        int y= *sp++, x= *sp++;
        if (x>=y)
          pc+= disp;
        break;
      }
      case JMPGT: {
        int disp= *pc++;
        int y= *sp++, x= *sp++;
        if (x>y)
          pc+= disp;
        break;
      }
      case RET: {
        int ret= *sp++; /* pop del valor a retornar */
        return ret;
      }
      default:
        fprintf(stderr, "codigo de instruccion desconocido: %d\n", pc[-1]);
        exit(1);
    }
  }
}
