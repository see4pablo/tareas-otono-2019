        .text
        .align 32  # por razones de eficiencia se alinea en borde
                   # de linea en memoria cache

# Este codigo hace el mejor esfuerzo por verificar que haya implementado
# correctamente las instrucciones.  Con mala suerte, algunos errores
# pueden escaparse.
        .globl codigo_verifica   # Para que se vea desde test-sieve-threaded.c
codigo_verifica:
  # Verifica que funciona los LOCALx
        .long PUSH, 1 
        .long PUSH, 2 
        .long PUSH, 3 
        .long PUSH, 4 

        .long LOCAL0 
        .long PUSH, 1 
        .long JMPEQ, 3 
        .long PUSH, -1  # No funciona LOCAL0
        .long HALT 

        .long LOCAL1 
        .long PUSH, 2 
        .long JMPEQ, 3 
        .long PUSH, -2  # No funciona LOCAL1
        .long HALT 

        .long LOCAL2 
        .long PUSH, 3 
        .long JMPEQ, 3 
        .long PUSH, -3  # No funciona LOCAL2
        .long HALT 

        .long LOCAL3 
        .long PUSH, 4 
        .long JMPEQ, 3 
        .long PUSH, -4  # No funciona LOCAL3
        .long HALT 

  # Verifica que funcionan los ST_LOCALx
        .long PUSH, 10 
        .long ST_LOCAL0 
        .long PUSH, 10 
        .long LOCAL0 
        .long JMPEQ, 3 
        .long PUSH, -10  # No funciona ST_LOCAL0
        .long HALT 

        .long PUSH, 20 
        .long ST_LOCAL1 
        .long PUSH, 20 
        .long LOCAL1 
        .long JMPEQ, 3 
        .long PUSH, -11  # No funciona ST_LOCAL1
        .long HALT 

        .long PUSH, 30 
        .long ST_LOCAL2 
        .long PUSH, 30 
        .long LOCAL2 
        .long JMPEQ, 3 
        .long PUSH, -12  # No funciona ST_LOCAL2
        .long HALT 

        .long PUSH, 40 
        .long ST_LOCAL3 
        .long PUSH, 40   # Se vuelve a chequear al final del programa!
        .long LOCAL3 
        .long JMPEQ, 3 
        .long PUSH, -13  # No funciona ST_LOCAL3
        .long HALT 

  # Verifica que funcione ARRAY y ST_ARRAY
        .long ARG0 
        .long PUSH, 5 
        .long PUSH, -123 
        .long ST_ARRAY 
        .long ARG0 
        .long PUSH, 5 
        .long ARRAY 
        .long PUSH, -123 
        .long JMPEQ, 3 
        .long PUSH, -20  # No funciona ARRAY o ST_ARRAY
        .long HALT 

  # Verifica que funcione ADD
        .long PUSH, 5 
        .long PUSH, 15 
        .long ADD 
        .long PUSH, 20 
        .long JMPEQ, 3 
        .long PUSH, -30  /* No funciona ADD */
        .long HALT

  # Verifica que funcione JMPNE

        .long PUSH, 1
        .long PUSH, 2 
        .long JMPNE, 3 
        .long PUSH, -40  # No funciona JMPNE: no salto cuando es menor
        .long HALT 

        .long PUSH, 2 
        .long PUSH, 1 
        .long JMPNE, 3 
        .long PUSH, -41  # No funciona JMPNE: no salto cuando es mayor
        .long HALT 

        .long PUSH, 10 
        .long PUSH, 10 
        .long JMPNE, 2 
        .long JMP, 3 
        .long PUSH, -42  # No funciona JMPNE: salta cuando hay igualdad
        .long HALT 

  # Verifica que funcione JMPGT

        .long PUSH, 5 
        .long PUSH, 2 
        .long JMPGT, 3 
        .long PUSH, -50  # No funciona JMPGT: no salta cuando deberia
        .long HALT 

        .long PUSH, 10 
        .long PUSH, 10 
        .long JMPGT, 2 
        .long JMP, 3 
        .long PUSH, -51  # No funciona JMPGT: salta cuando hay igualdad
        .long HALT 

        .long PUSH, 10 
        .long PUSH, 15 
        .long JMPGT, 2 
        .long JMP, 3 
        .long PUSH, -52  # No funciona JMPGT: salta cuando es menor
        .long HALT 

        .long PUSH, 40 
        .long JMPEQ, 3 
        .long PUSH, -60  # Los movimientos del sp son incorrectos:
        .long HALT    # A estas alturas, deberia apuntar hacia la 4ta. variable
                         # local, que contiene 40

        .long PUSH, 0    # La instrucciones parecen funcionar ok
        .long HALT
