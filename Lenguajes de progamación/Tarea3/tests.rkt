#lang play
(require "main.rkt")
(print-only-errors)

;Author: Pablo Aliaga
;implementación lenguaje orientado a objetos utilizando Scheme como base

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                 TESTS BASE                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(test (run-val '(+ 1 2)) 3)
(test (run-val '(< 1 2)) #t)
(test (run-val '(- 2 1)) 1)
(test (run-val '(* 2 3)) 6)
(test (run-val '(= (+ 2 1) (- 4 1))) #t)
(test (run-val '(and #t #f)) #f)
(test (run-val '(or #t #f)) #t)
(test (run-val '(not (not #t))) #t)
(test (run-val '(if (not #f) (+ 2 1) 4)) 3)
(test (run-val '(local ([define x 5])
              (seqn {+ x 1}
                    x))) 5)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                  SUS TESTS                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Objetos y clases como valores (primer orden)
(test (run-val '(local
                  [(define A (class))]
                  A)) "<Class>")

(test (run-val '(local
                  [(define A (class))]
                  (new A))) "<Object>")

;Objects and Classes respect lexical scoping
(test/exn (run-val '(seqn (local
                  [(define A
                     (class
                         (field x 2) 
                       (method m () (get this x))))]
                  10)
                (new A)))
"env-lookup: free identifier: A")

;This y super solo se pueden usar dentro de los métodos de un objeto
(test/exn (run-val '(+ this 2)) "This is a reserved word for objects")
(test/exn (run-val '(+ super 2)) "Super is a reserved word for objects")



;Clases y objetos, básicos

;Tests de metodo que no existe en objeto
(test/exn (run-val '(local
                  [(define A (class)) (define a (new A))]
                  (send a e))) "Object class don't have method:")
(test/exn (run-val '(local
                  [(define A (class (method x () 0))) (define a (new A))]
                  (send a e))) "Object class don't have method:")


;Tests con objetos de prueba, con metodos como suma o otro básicos
(test (run-val '(local
            [(define x 10)
             (define A
               (class (method m (y) (+ x y))))
             (define o (new A))] (send o m 1))) 11)

(test (run-val '(local
             [(define c (class
                            (field x 1)
                          (field y 2)
                          (method sum (z) (+ (get this x) (+ (get this y) z)))
                          (method set-x (val) (set this x val))))
              (define o (new c))]
             (seqn
              (send o set-x (+ 1 3))
              (+ (send o sum 3) (get o y)))))
11)
(test (run-val '(local
              [(define A
                 (class
                     (method apply (c)
                             (send (new c) m))))
               (define o (new A))]
              (send o apply (class
                                (field x 2) 
                                (method m () (get this x))))))
2)

; Test seller, comprueba los llamados internos a metodos del mismo objeto
(test (run-val
       '(local
          [(define seller (class
                              (method unit () 1)
                            (method price () (* (send this unit) 100))
                            ))
           (define S (new seller))]
          (send S price))) 100)

; Test de broker seller del apunte, comprueba los llamados a this
(test (run-val
       '(local
          [(define seller (class
                              (method unit () 1)
                            (method price () (* (send this unit) 100))
                            ))
           (define broker (class <: seller
                              (method unit () 2)))
           (define B (new broker))
           ]
          (send B price)
          )) 200)

; Tests de crear dos instancias de una clase Point
; Verificar que el set de p1 funciona
(test (run-val '(local
                  [(define Point (class (field x 0) (method move (n) (set this x (+ (get this x) n)))))
                   (define p1 (new Point))
                   (define p2 (new Point))]
                  (seqn
                   (send p1 move 10)
                   (get p1 x)))) 10)

; Verificar que el set de p1 no afecta la instancia p2
(test (run-val '(local
                  [(define Point (class (field x 0) (method move (n) (set this x (+ (get this x) n)))))
                   (define p1 (new Point))
                   (define p2 (new Point))]
                  (seqn
                   (send p1 move 10)
                   (get p2 x)))) 0)

;; herencia simple

(test (run-val '(local
              [(define c1 (class
                              (method f (z) (< z 7))))
               (define c (class <: c1))
               (define o (new c))]
              (send o f 20)))
#f)

;; Test de herencia de methodos,
;; el objeto B parte buscando sus métodos desde su clase padre
(test (run-val '(local
                  [(define A (class (method foo () 0) (method bar () 1)))
                   (define B (class <: A (method bar () 2)))
                   (define b (new B))]
                  (send b foo))) 0)

(test (run-val '(local
                  [(define A (class (method foo () 0) (method bar () 1)))
                   (define B (class <: A (method bar () 2)))
                   (define b (new B))]
                  (send b bar))) 2)

;; soporte para super

(test (run-val '(local
          [(define c2 (class
                          (method h (x) (+ x 1))))
           (define c1 (class <: c2
                        (method f () #f)))
           (define c (class <: c1                       
                       (method g () (super h 10))))
           (define o (new c))]
          (send o g)))
11)

; Ejemplo del apunte, uso del super para definir métodos de clase hija
; Point y colorPoint
; También se verifica field shadowing

(test (run-val '(local [(define Point (class (field x 1) (method number () (get this x))))
                        (define ColorPoint (class <: Point (field y 2) (method number () (+ (get this y) (super number)))))
                        (define cp (new ColorPoint))] (send cp number))) 3)

; Ejemplo del apunte, uso del super para verificar que se realiza el lookup desde la clase padre de la clase de donde se encuentra el método
(test (run-val '(local [(define A (class (method m () 4)))
                        (define B (class <: A (method m () (+ 3 (super m)))))
                        (define C (class <: B))
                        (define c (new C))]
                  (send c m))) 7)

;;field shadowing

; field shadowing con get solamente
(test (run-val '(local
              [(define A (class 
                           [field x 1]
                           [field y 0]
                           [method ax () (get this x)]))
               (define B (class <: A
                           [field x 2]
                           [method bx () (get this x)]))
               (define b (new B))]
              (send b ax)))
1)

; field shadowing con get y set, utilizando tambien dos fields con el mismo nombre del objeto
(test (run-val '(local
              [(define A (class 
                           [field x 1]
                           [field y 0]
                           [method ax1 (val) (set this x val)]
                           [method ax2 () (get this x)]))
               (define B (class <: A
                           [field x 2]
                           [method bx () (get this x)]))
               (define b (new B))]
              (seqn (send b ax1 5)
                    (+ (send b ax2) (send b bx))))) 7)



;; lambdas with objects ;;

;identity lambda
(test (run-val '(local
              [(define f (fun (x) x))]
                  (f 1234))) 1234)
;double a number
(test (run-val '(local
              [(define f (fun (x) (+ x x)))]
                  (f 5))) 10)
;lambda that uses a value of env 'l'
(test (run-val '(local
                  [(define l 0)
                   (define s (fun () l))]
                  (+ (s) 0))) 0)
;addition lambda
(test (run-val '(local
                  [(define f (fun (a b) (+ a b)))]
                  (f 2 3))) 5)
;composition of lambdas
(test (run-val '(local
                  [(define f (fun (a b) (+ a b)))
                   (define g (fun (a b c) (+ a (f b c))))]
                  (g 2 3 5))) 10)
;lambdas as object values (first order)
(test (run-val '(local [(define f (fun () 0))]
                  f)) "<Object>")
