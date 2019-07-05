#lang play
(require "main.rkt")
(print-only-errors)

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

(test/exn (run-val '(seqn (local
                  [(define A
                     (class
                         (field x 2) 
                       (method m () (get this x))))]
                  10)
                (new A)))
"env-lookup: free identifier: A")

(test (run-val '(local
            [(define x 10)
             (define A
               (class
                   (method m (y) (+ x y))))
             (define o (new A))]
            (send o m 1)))
11)

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

;; herencia simple

(test (run-val '(local
              [(define c1 (class
                              (method f (z) (< z 7))))
               (define c (class <: c1))
               (define o (new c))]
              (send o f 20)))
#f)

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

;;field shadowing

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

