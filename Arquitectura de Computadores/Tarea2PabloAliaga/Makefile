# Instrucciones de uso:
#
# + Interprete de bytecode para calcular el mcd de 2 numeros.
#   El programa se encuentra en mcd-bytecode.c.
#   Compilar:    % make mcd-bytecode
#   Ejecutar:    % ./mcd-bytecode 12 15
#
# + Interprete de bytecode para calcular los primeros n numeros primos.
#   El programa se encuentra en sieve-bytecode.c.
#   Compilar:    % make sieve-bytecode
#   Ejecutar:    % ./sieve-bytecode 100
#
# + Codigo threaded para calcular el mcd de 2 numeros.
#   Archivos:
#     - interp-threaded0.s (interprete de codigo threaded)
#     - mcd-threaded.s     (codigo threaded para calcular mcd)
#     - test-mcd-threaded.c (programa de prueba)
#   Compilar:    % make test-mcd-threaded
#   Ejecutar:    % ./test-mcd-threaded 12 15
#
# + Codigo threaded para calcular los primeros n numeros primos.
#   Archivos:
#     - interp-threaded0.s (interprete de codigo threaded)
#     - sieve-threaded.s   (codigo threaded para calcular sieve)
#     - test-sieve-threaded.c (programa de prueba)
#   Compilar:    % make test-sieve-threaded
#   Ejecutar:    % ./test-sieve-threaded 100
#
# + Codigo threaded para realizar una busqueda binaria.
#   Archivos:
#     - interp-threaded.s (*falta*, implementelo a partir de interp-threaded0.s)
#     - search-threaded.s (codigo threaded de la busqueda binaria)
#     - test-search-threaded.c (programa de prueba)
#   Compilar:    % make test-search-threaded
#   Ejecutar:    % ./test-search-threaded 100
#
CFLAGS= -g -m32
LDFLAGS= -g -m32
ASFLAGS= --32

all: mcd-bytecode sieve-bytecode test-mcd-threaded \
     test-sieve-threaded test-search-threaded

mcd-bytecode: mcd-bytecode.o

sieve-bytecode: sieve-bytecode.o

test-mcd-threaded: mcd-threaded.o test-mcd-threaded.o interp-threaded0.o

test-sieve-threaded: sieve-threaded.o test-sieve-threaded.o interp-threaded0.o verifica-threaded.o

#	gcc -m32 -o test-sieve-threaded interp-threaded0.o sieve-threaded.o test-sieve-threaded.o verifica-threaded.o

test-search-threaded: search-threaded.o test-search-threaded.o interp-threaded.o verifica-threaded.o

#	gcc -m32 -o test-search-threaded interp-threaded.o search-threaded.o test-search-threaded.o verifica-threaded.o

tgz:
	tar zcvf t2.tgz Makefile mcd-bytecode.c sieve-bytecode.c \
		interp-threaded0.s mcd-threaded.s test-mcd-threaded.c \
		sieve-threaded.s test-sieve-threaded.c verifica-threaded.s \
    search-threaded.s test-search-threaded.c t2-2006.pdf

clean:
	rm -f *.o
	rm -f mcd-bytecode sieve-bytecode t2.tgz
	rm -f test-mcd-threaded test-sieve-threaded test-search-threaded
