# El interprete de threaded-code
# int interprete(int *codigo, int *sp)
# Asi queda la pila despues de inicializar %ebp, ver (*):
#                  +-----------+
#                  |    sp     |
#                  +-----------+
#              +8  |  codigo   |
#                  +-----------+
#              +4  | dir. ret. |
#                  +-----------+
# %ebp, %esp->     | %ebp ant. |
#                  +-----------+
        .globl interprete  # Hace que interprete sea visible desde
                           # otros archivos
        .globl ARG0, ST_ARG0, ARG1, ST_ARG1, ARG2, ARG3
        .globl LOCAL0, LOCAL1, LOCAL2, LOCAL3
        .globl ST_LOCAL0, ST_LOCAL1, ST_LOCAL2, ST_LOCAL3
        .globl PUSH
        .globl SUB, ADD,
        .globl JMP, JMPGE, JMPEQ, JMPNE, JMPGT,
        .globl ARRAY, ST_ARRAY, 
        .globl HALT
        .globl POP, RET, CALL, DIV, JMPLE

        .align  4  # por razones de eficiencia se alinea en borde de palabra
interprete:
        pushl   %ebp
        movl    %esp, %ebp      # %ebp inicializado (*)
        pushl   %edi            # resguarda registros del llamador
        pushl   %esi
        pushl   %ebx
        # Inicializacion de sp, pc y fp del interprete de bytecode.
        # No confundir con %esp, %eip y %ebp que son los registros
        # del procesador.
        movl    12(%ebp), %ecx  # %ecx = sp (puntero a la pila)
        movl    8(%ebp), %ebx   # %ebx = pc (inicialmente = &codigo)

        # La partida:
        #       +---------------+
        # pc->  | dir. cod. op.-+----+  direccion del codigo de la operacion
        #       +---------------+    |
        #       |               |    |
        #       +---------------+    |
        #       |               |    |
        #       +---------------+    |
        #       | inst. 1       |<---+  Instrucciones que ejecutan la operacion
        #       +---------------+
        #       | inst. 2       |
        #       +---------------+
        #       | ...           |

        subl    $8, %ecx        # sp -= 2
        movl    %ecx, %edi      # %edi = fp (puntero a los parametros)
        movl    $HALTRET, 4(%ecx) # sp[1]= HALTRET (dir. de retorno inicial)
        movl    $0, 0(%ecx)     # sp[0]= 0 (fp de retorno)
        movl    (%ebx), %eax    # %eax= *pc
        jmp     *%eax           # jmp a la direccion contenida en %eax

HALTRET:
        .long   HALT

# apilar primer argumento
        .align  4
ARG0:
        subl    $4, %ecx        # --sp
        movl    8(%edi), %eax   # parm0= fp[2]      (primer parametro)
        movl    %eax, (%ecx)    # sp[0]= parm0

        addl    $4, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion

# apilar 2do. argumento
        .align  4
ST_ARG0:
        movl    (%ecx), %eax    # val= sp[0]
        movl    %eax, 8(%edi)   # fp[2]= val
        addl    $4, %ecx        # sp++

        addl    $4, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion

# guardar primer argumento
       .align  4
ARG1:
        subl    $4, %ecx        # --sp
        movl    12(%edi), %eax  # parm1= fp[3]
        movl    %eax, (%ecx)    # sp[0]= parm1

        addl    $4, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion

# guardar 2do. argumento
        .align  4
ST_ARG1:
        movl    (%ecx), %eax    # val= sp[0]
        movl    %eax, 12(%edi)  # fp[3]= val
        addl    $4, %ecx        # sp++

        addl    $4, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion

# apilar 3er. argumento
ARG2:
        subl    $4, %ecx        # --sp
        movl    16(%edi), %eax  # parm1= fp[4]
        movl    %eax, (%ecx)    # sp[0]= parm1

        addl    $4, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion

# apilar 4to. argumento
ARG3:
        subl    $4, %ecx        # --sp
        movl    20(%edi), %eax  # parm1= fp[5]
        movl    %eax, (%ecx)    # sp[0]= parm1

        addl    $4, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion

# la resta
        .align  4
SUB:
        movl    (%ecx), %edx    # y= sp[0]
        addl    $4, %ecx        # sp++
        movl    (%ecx), %eax    # x= sp[0]
        subl    %edx, %eax      # z= x-y
        movl    %eax, (%ecx)    # sp[0]= z

        addl    $4, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion

# salto incondicional
        .align  4
JMP:
        movl    4(%ebx), %eax   # disp= pc[1]
        leal    (%ebx,%eax,4), %eax  # nuevopc= pc+disp (load effective address)
        leal    8(%eax), %ebx   # pc= nuevopc+2
        movl    8(%eax), %eax   # operacion= *nuevopc
        jmp     *%eax           # jmp *operacion

# salta si >=
        .align  4
JMPGE:
        movl    (%ecx), %edx    # y= sp[0]
        movl    4(%ebx), %esi   # disp= pc[1]
        addl    $4, %ecx        # sp++
        addl    $8, %ebx        # pc= pc+2
        movl    (%ecx), %eax    # x= sp[0]
        addl    $4, %ecx        # sp++
        cmpl    %edx, %eax
        jl      JMPGE_FALSE     # if (x<y) goto JMPGE_FALSE
        leal    (%ebx,%esi,4), %ebx # pc= pc+disp (load effective address)
JMPGE_FALSE:
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # goto *operacion

# salta si ==
        .align  4
JMPEQ:
        movl    (%ecx), %edx    # y= sp[0]
        movl    4(%ebx), %esi   # disp= pc[1]
        addl    $4, %ecx        # sp++
        addl    $8, %ebx        # pc= pc+2
        movl    (%ecx), %eax    # x= sp[0]
        addl    $4, %ecx        # sp++
        cmpl    %edx, %eax
        jne     JMPEQ_FALSE     # if (x!=y) goto JMPEQ_FALSE
        leal    (%ebx,%esi,4), %ebx # pc= pc+disp (load effective address)
JMPEQ_FALSE:
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # goto *operacion

# retorna al llamador
        .align  4
HALT:
        movl    (%ecx), %eax    # x= sp[2] (valor de retorno)
        popl    %ebx            # restaura los registros del llamador
        popl    %esi
        popl    %edi
        popl    %ebp
        ret                     # retorna al llamador

# Implemente el resto de las instrucciones aca ...
# apilar primer argumento
        .align  4
LOCAL0:
        subl    $4, %ecx        # --sp
        movl    -4(%edi), %eax  # parm0= fp[-1]
        movl    %eax, (%ecx)    # sp[0]= parm0

        addl    $4, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion


# apilar primer argumento
        .align  4
LOCAL1:
        subl    $4, %ecx        # --sp
        movl    -8(%edi), %eax  # parm0= fp[-2]
        movl    %eax, (%ecx)    # sp[0]= parm0

        addl    $4, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion

# apilar primer argumento
        .align  4
LOCAL2:
        subl    $4, %ecx        # --sp
        movl    -12(%edi), %eax # parm0= fp[-3]
        movl    %eax, (%ecx)    # sp[0]= parm0

        addl    $4, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion

# apilar primer argumento
        .align  4
LOCAL3:
        subl    $4, %ecx        # --sp
        movl    -16(%edi), %eax # parm0= fp[-4]
        movl    %eax, (%ecx)    # sp[0]= parm0

        addl    $4, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion

# guardar variable local 0
        .align  4
ST_LOCAL0:
        movl    (%ecx), %eax    # val= sp[0]
        movl    %eax, -4(%edi)  # fp[-1]= val
        addl    $4, %ecx        # sp++

        addl    $4, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion

# guardar variable local 0
        .align  4
ST_LOCAL1:
        movl    (%ecx), %eax    # val= sp[0]
        movl    %eax, -8(%edi)  # fp[-1]= val
        addl    $4, %ecx        # sp++

        addl    $4, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion

ST_LOCAL2:
        movl    (%ecx), %eax    # val= sp[0]
        movl    %eax, -12(%edi) # fp[-2]= val
        addl    $4, %ecx        # sp++

        addl    $4, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion

# guardar variable local 0
        .align  4
ST_LOCAL3:
        movl    (%ecx), %eax    # val= sp[0]
        movl    %eax, -16(%edi) # fp[-3]= val
        addl    $4, %ecx        # sp++

        addl    $4, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion

# push
        .align  4
PUSH:
        subl    $4, %ecx        # --sp
        movl    4(%ebx), %eax   # parm0= pc[1]
        movl    %eax, (%ecx)    # sp[0]= parm0
        
        addl    $8, %ebx        # pc+=2
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion

# salta si !=
        .align  4
JMPNE:
        movl    (%ecx), %edx    # y= sp[0]
        movl    4(%ebx), %esi   # disp= pc[1]
        addl    $4, %ecx        # sp++
        addl    $8, %ebx        # pc= pc+2
        movl    (%ecx), %eax    # x= sp[0]
        addl    $4, %ecx        # sp++
        cmpl    %edx, %eax
        je      JMPNE_FALSE     # if (x==y) goto JMPNE_FALSE
        leal    (%ebx,%esi,4), %ebx # pc= pc+disp (load effective address)
JMPNE_FALSE:
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # goto *operacion

# salta si >
        .align  4
JMPGT:
        movl    (%ecx), %edx    # y= sp[0]
        movl    4(%ebx), %esi   # disp= pc[1]
        addl    $4, %ecx        # sp++
        addl    $8, %ebx        # pc= pc+2
        movl    (%ecx), %eax    # x= sp[0]
        addl    $4, %ecx        # sp++
        cmpl    %edx, %eax
        jle     JMPGT_FALSE     # if (x<=y) goto JMPGE_FALSE
        leal    (%ebx,%esi,4), %ebx # pc= pc+disp (load effective address)
JMPGT_FALSE:
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # goto *operacion

# salta si >=
        .align  4
JMPLE:
        movl    (%ecx), %edx    # y= sp[0]
        movl    4(%ebx), %esi   # disp= pc[1]
        addl    $4, %ecx        # sp++
        addl    $8, %ebx        # pc= pc+2
        movl    (%ecx), %eax    # x= sp[0]
        addl    $4, %ecx        # sp++
        cmpl    %edx, %eax
        jg      JMPLE_FALSE     # if (x<y) goto JMPLE_FALSE
        leal    (%ebx,%esi,4), %ebx # pc= pc+disp (load effective address)
JMPLE_FALSE:
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # goto *operacion

# la suma
        .align  4
ADD:
        movl    (%ecx), %edx    # y= sp[0]
        addl    $4, %ecx        # sp++
        movl    (%ecx), %eax    # x= sp[0]
        addl    %edx, %eax      # z= x+y
        movl    %eax, (%ecx)    # sp[0]= z

        addl    $4, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion

ARRAY:
        movl    (%ecx), %edx    # i= sp[0]
        addl    $4, %ecx        # sp++
        movl    (%ecx), %eax    # a= sp[0]
        addl    $4, %ecx        # sp++
        subl    $4, %ecx        # --sp
        movl    (%eax,%edx,4), %eax  # parm0=a[i]
        movl    %eax, (%ecx)    # sp[0]= parm0

        addl    $4, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion

ST_ARRAY:
        movl    (%ecx), %esi    # v= sp[0]
        addl    $4, %ecx        # sp++
        movl    (%ecx), %edx    # i= sp[0]
        addl    $4, %ecx        # sp++
        movl    (%ecx), %eax    # a= sp[0]
        addl    $4, %ecx        # sp++
        movl    %esi,(%eax,%edx,4) # a[i]=v

        addl    $4, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion

        # Implemente aqui las siguientes operaciones
        # .globl CALL, RET, DIV, POP

        .align 4
CALL:
        subl    $4, %ecx        # sp--
        addl    $8, %ebx        # pc = d.ret

        movl    %ebx, (%ecx)    # esi = d.ret
        subl    $4, %ebx        # pc = dir
        subl    $4, %ecx        # sp--
        movl    %edi, (%ecx)      # sp = fp ant
        movl    %ecx, %edi
        movl    (%ebx), %ebx

        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion


        .align  4
RET:
        movl    4(%edi), %ebx   # pc = d.ret
        addl    $4, %edi        # fp = d.ret
        movl    (%ecx), %esi    # fp = val
        movl    %edi, %ecx
        movl    %esi, (%ecx)
        subl    $4, %edi        # fp -> fp ant
        movl    (%edi), %edi    # fp = fp. ant

        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion

        .align  4
DIV:
        movl    $0, %edx
        movl    4(%ecx), %eax
        idivl   (%ecx)
        addl    $4, %ecx
        movl    %eax, (%ecx)

        addl    $4, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion



# %edi = fp
# %ecx = sp
# ebx = pc
        .align  4
POP:    
        movl    4(%ebx), %eax   # eax = n
        movl    $4, %esi
        mull    %esi             # eax *= 4
        addl    %eax, %ecx    # sp += (n * 4)

        addl    $8, %ebx        # pc++
        movl    (%ebx), %eax    # operacion= *pc
        jmp     *%eax           # jmp *operacion
        
