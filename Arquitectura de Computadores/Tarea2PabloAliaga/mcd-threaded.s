        .text
        .align 32  # por razones de eficiencia se alinea en borde
                   # de linea en memoria cache
# Bytecode del programa que calcula el mcd
# int mcd(int x, int y) {
#   while (x!=y) {
#     if (x<y) y= y-x;
#     else     x= x-y;
#   }
#   return x;
# }
# Observe que el codigo se guarda como datos: estos no tiene nada
# que ver con assembler x86
# Cada operacion es una etiqueta en el interprete de threaded-code.
# Esto significa que se almacena directamente la direccion del
# codigo que ejecuta la operacion.  No hay necesidad de hacer
# switch y por lo tanto es mas eficiente.

        .globl codigo  # Hace que interprete sea visible desde
                       # otros archivos.  De otro modo las etiquetas
                       # son solo visibles en el archivo que las define.
        .align  4  # por razones de eficiencia se alinea en borde de palabra
codigo:
        .long	ARG0        # push x
        .long	ARG1        # push y
        .long	JMPEQ, 16   # b= pop  a= pop  if (a==b) pc= pc+16
        .long	ARG0        # push x
        .long	ARG1        # push y
        .long	JMPGE, 6    # b= pop  a= pop  if (a>=b) pc= pc+6
        .long	ARG1        # push y
        .long	ARG0        # push x
        .long	SUB         # b= pop  a= pop  push a-b
        .long	ST_ARG1     # y= pop
        .long	JMP, -14    # pc= pc - 14
        .long	ARG0        # push x
        .long	ARG1        # push y
        .long	SUB         # b= pop  a= pop  push a-b
        .long	ST_ARG0     # x= pop
        .long	JMP, -20    # pc= pc - 20
        .long	ARG0        # push x
        .long	HALT

