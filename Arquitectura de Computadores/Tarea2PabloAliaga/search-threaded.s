# Threaded-code de la busqueda binaria
# 
# int binsearch(int x, int* a, int i, int j) {
#   int k;
#   if (i>j)
#     return -1;
#   k= (i+j)/2;
#   if (a[k]==x)
#     return k;
#   else if (a[k]<x)
#     return binsearch(x, a, k+1, j);
#   else
#     return binsearch(x, a, i, k-1);
# }
#

        .globl codigo_binsearch # Para que se vea desde test-sieve-threaded.c
codigo_binsearch:
        # if (i<j) return -1;
        .long ARG2            #  i
        .long ARG3            #  j, i
        .long JMPLE,(L1-L0)/4 #  if (i<=j) goto L1
L0:
        .long PUSH, -1        #  -1
        .long RET             #  return -1
        # k= (i+j)/2;
L1:
        .long ARG2            #  i
        .long ARG3            #  j, i
        .long ADD             #  i+j
        .long PUSH, 2         #  2, i+j
        .long DIV             #  k=(i+j)/2 (LOCAL0)
        # if (a[k]==x) return k;
        .long ARG1            #  a
        .long LOCAL0          #  k, a
        .long ARRAY           #  a[k]
        .long ARG0            #  x, a[k]
        .long JMPNE,(L3-L2)/4 #  if (a[k]!=x) goto L3
L2:
        .long LOCAL0          #  k
        .long RET             #  return k
        # else if (a[k]<x)
L3:
        .long ARG1            #  a
        .long LOCAL0          #  k, a
        .long ARRAY           #  a[k]
        .long ARG0            #  x, a[k]
        .long JMPGE,(L5-L4)/4 #  if (a[k]>=x) goto L5
L4:
        # return binsearch(x, a, k+1, j);
        .long ARG3            #  j
        .long LOCAL0          #  k, j
        .long PUSH, 1         #  1, k, j
        .long ADD             #  k+1, j
        .long ARG1            #  a, k+1, j
        .long ARG0            #  x, a, k+1, j
        .long CALL, codigo_binsearch
        .long ST_LOCAL0       #  tmp= codigo_binsearch(x, a, k+1, j)
        .long POP, 4          #  desapila 3 elemento de la pila
        .long RET             #  LOCAL0 esta en el tope del stack, return tmp
        # return binsearch(x, a, i, k-1);
L5:
        .long LOCAL0          #  k
        .long PUSH, 1         #  1, k
        .long SUB             #  k-1
        .long ARG2            #  i, k-1
        .long ARG1            #  a, i, k-1
        .long ARG0            #  x, a, i, k-1
        .long CALL, codigo_binsearch
        .long ST_LOCAL0       #  tmp= codigo_binsearch(x, a, i, k-1)
        .long POP, 4          #  desapila 3 elemento de la pila
        .long RET             #  LOCAL0 esta en el tope del stack, return tmp

