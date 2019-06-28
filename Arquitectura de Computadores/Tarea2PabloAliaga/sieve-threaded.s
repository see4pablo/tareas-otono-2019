# Threaded-code del programa que calcula el sieve
# 
# int sieve(int* flags, int size) {
#   int i=0, prime, k, count= 0;
# 
#   while (i<=size) {
#     flags[i]=1;
#     i++;
#   }
#   i=0;
#   while (i<=size) {
#     if(flags[i]==1) {
#       prime=i+i+3; printf("%d ", prime);
#       k=i+prime;
#       while (k<=size) {
#         flags[k]=0;
#         k+=prime;
#       }
#       count++;
#     }
#     i++;
#   }
#   return count;
# }

        .globl codigo_sieve   # Para que se vea desde test-sieve-threaded.c
codigo_sieve:
        .long PUSH, 0         #  i= 0     (LOCAL0)
        .long PUSH, 0         #  prime    (LOCAL1)
        .long PUSH, 0         #  k        (LOCAL2)
        .long PUSH, 0         #  count= 0 (LOCAL3)

  #  while (i<=size)
  #  etiqueta INI
        .long LOCAL0          #  push i
        .long ARG1            #  push size
        .long JMPGT, 12       #  if (i>size) goto CALC

  #  flags[i]= 1
        .long ARG0            #  push flags
        .long LOCAL0          #  push i
        .long PUSH, 1         #  push 1
        .long ST_ARRAY        #  v= pop  i= pop  a= pop  a[i]= v

  #  i++ */
        .long LOCAL0          #  push i
        .long PUSH, 1         #  push 1
        .long ADD             #  y=pop  x= pop  push x+y
        .long ST_LOCAL0       #  i= pop
        .long JMP, -16        #  goto INI

  #  etiqueta CALC
  /* i=0; */
        .long PUSH, 0         #  push 0
        .long ST_LOCAL0       #  i= pop

  #  etiqueta CICLOI
  #  while (i<=size)
        .long LOCAL0          #  push i
        .long ARG1            #  push size
        .long JMPGT, 45       #  if (i>size) goto RETORNAR

  #    if(flags[i]==1)
        .long ARG0            #  push flags
        .long LOCAL0          #  push i
        .long ARRAY           #  a= pop  i= pop  push a[i]
        .long PUSH, 1         #  push 1
        .long JMPNE, 31       #  if (flags[i]!=1) goto INCI

  #  prime= i+i+3
        .long LOCAL0          #  push i
        .long LOCAL0          #  push i
        .long ADD             #  y= pop  x= pop  push x+y
        .long PUSH, 3         #  push 3
        .long ADD             #  y= pop  x= pop  push x+y
        .long ST_LOCAL1       #  prime= pop

  #  k=i+prime; */
        .long LOCAL0           #  push i
        .long LOCAL1           #  push prime
        .long ADD              #  y= pop  x= pop  push x+y
        .long ST_LOCAL2        #  k= pop

  #  etiqueta CICLOK
  #  while (k<=size)
        .long LOCAL2           #  push k
        .long ARG1             #  push size
        .long JMPGT, 11        #  y= pop  x= pop  if (x>y) goto INC_COUNT

  #  flags[k]=0;
        .long ARG0             #  push flags
        .long LOCAL2           #  push k
        .long PUSH, 0          #  push 0
        .long ST_ARRAY         #  v= pop  idx=pop  a= pop  a[idx]= v
  #  k+= prime
        .long LOCAL2           #  push k
        .long LOCAL1           #  push prime
        .long ADD              #  y= pop  x= pop  push x+y
        .long ST_LOCAL2        #  k= pop
        .long JMP, -15         #  goto CICLOK

  #  etiqueta INC_COUNT
  #  count++; */
        .long LOCAL3           #  push count
        .long PUSH, 1          #  push 1
        .long ADD              #  y= pop  x= pop  push x+y
        .long ST_LOCAL3        #  count= pop

  #  etiqueta INCI */
  #  i++ */
        .long LOCAL0           #  push i
        .long PUSH, 1          #  push 1
        .long ADD              #  y= pop  x= pop  push x+y
        .long ST_LOCAL0        #  i= pop
        .long JMP, -49         #  goto CALC

  #  etiqueta RETORNAR
        .long LOCAL3 
        .long HALT
