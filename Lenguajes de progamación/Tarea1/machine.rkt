#lang play

;; ADT STACK



#|
<Stack> :: = <EmptyStack>
        | {Stacked <val><Stack>}
|#

(deftype Stack
  (Stacked value next)
  (EmptyStack))

;; stack-init :: -> Stack
;; Retorna un Stack vacio
(define (stack-init)
  (EmptyStack))


;; stack-pop :: Stack -> Stack
;; Retorna el stack luego de haber retirado el ultimo elemento. Error si esta vacio
(define (stack-pop s)
  (match s
    [(Stacked v n) n]
    [(EmptyStack) (error "stack-pop to an EmptyStack")]))



;; stack-peek :: Stack -> V
;;Retorna el valor que esta en el tope del stack, Error si esta vacio
(define (stack-peek s)
  (match s
    [(Stacked v n) v]
    [(EmptyStack) (error "stack-peek to an EmptyStack")]))


;; stack-push :: Stack, V -> Stack
;Retorna el stack despues de agregar el nuevo valor
(define (stack-push s v)
  (Stacked v s))

;; stack-empty :: Stack -> Boolean
;;Retorna true si el stack esta vacio, falso en otro caso
(define (stack-empty? s)
  (match s
    [(EmptyStack) #t]
    [(Stacked v n) #f]))


;; stack-size :: Stack -> Int
;;Retorna cuantos elementos hay en el stack
(define (stack-size s)
  (letrec ([sstr (λ(s c)
                   (match s
                     [(EmptyStack) c]
                     [(Stacked v n) (sstr n (+ 1 c))]))])
    (sstr s 0)))


;; stack->list :: Stack -> List[V]
;;Transforma un Stack en una lista. El primer elemento de la lista es el tope del stack
(define (stack->list stack)
  (match stack
    [(EmptyStack) '()]
    [(Stacked v next) (cons v (stack->list next))]))



;; list->stack :: List[V] -> Stack
;;Transforma una lista en un stack. El primer elemento de la lista es el que queda en el tope del stack
(define (list->stack list)
  (match list
    ['() (EmptyStack)]
    [(cons h t) (Stacked h (list->stack t))]))


;; stack-debug :: Stack -> void
(define (stack-debug stack)
  (letrec ([collectString (λ(s)
                            (match s
                              [(EmptyStack) ""]
                              [(Stacked v next) (string-append (~v v) " ] " (collectString next))]))])
    (display (collectString stack))))


;;;;;;;;;;;;;;;;;;;;;;;
;; Machine definition
;;;;;;;;;;;;;;;;;;;;;;;
#|
Instructions
|#
(deftype Instruction
  (INT-CONST n)
  (BOOL-CONST b)  
  (ADD)
  (SUB)
  (LESS)
  (EQ)
  (AND)
  (OR)
  (NOT)
  (ACCESS n)
  (APPLY)
  (RETURN)
  (IF tb fb)
  (CLOSURE ins))


;; values
(deftype Val
  (closureV body env))

;; run :: List[Instruction], Stack[Instructions], List -> CONST
;; ejecuta la lista de instrucciones con el stack y el ambiente dados
(define (run ins-list stack env)
  ;(debug-run ins-list stack)
  (if (> (stack-size stack) 100)
      (error "STACK_OVERFLOW")
      (match ins-list
        ['() (if (= 1 (stack-size stack))
                 (match (stack-peek stack)
                   [(INT-CONST n) n]
                   [(BOOL-CONST b) b]
                   [(closureV ins env) (closureV ins env)]
                   [e "CORRUPT_ENDING_STATE"])
                 (error "CORRUPT_ENDING_STATE")
                 ;stack
                 )]
        [_ (let ([non-local-exn? (λ(ex) (and (not (string=? (exn-message ex)
                                                            "CORRUPT_ENDING_STATE"))
                                             (not (string=? (exn-message ex)
                                                            "STACK_OVERFLOW"))))]
                 [fault (λ(ex)
                          (error "SEGFAULT")
                          )])
             (with-handlers ([non-local-exn? fault])
               (match ins-list
                 [(list (INT-CONST n) tail ...)
                  (run tail (stack-push stack (INT-CONST n)) env )]

                 [(list (BOOL-CONST n) tail ...)
                  (run tail (stack-push stack (BOOL-CONST n)) env )]

                 [(list (ADD) tail ...) (def (INT-CONST n1) (stack-peek stack))
                                        (def (INT-CONST n2) (stack-peek (stack-pop stack)))
                                        (def new-stack (stack-pop (stack-pop stack)))
                                        (run tail (stack-push new-stack (INT-CONST (+ n2 n1))) env )]
                 [(list (SUB) tail ...) (def (INT-CONST n1) (stack-peek stack))
                                        (def (INT-CONST n2) (stack-peek (stack-pop stack)))
                                        (def new-stack (stack-pop (stack-pop stack)))
                                        (run tail (stack-push new-stack (INT-CONST (- n1 n2))) env )]
                 [(list (ACCESS n) tail ...) (run tail
                                                  (stack-push stack (list-ref env n))
                                                  env
                                                  )]

                 [(list (IF tb fb) tail ...) (def (BOOL-CONST b) (stack-peek stack))
                                             (if b
                                                 (run (append tb tail)
                                                      (stack-pop stack)
                                                      env
                                                      )
                                                 (run (append fb tail)
                                                      (stack-pop stack)
                                                      env
                                                      ))]
                 [(list (LESS) tail ...)(def (INT-CONST n1) (stack-peek stack))
                                        (def (INT-CONST n2) (stack-peek (stack-pop stack)))
                                        (def new-stack (stack-pop (stack-pop stack)))
                                        (run tail (stack-push new-stack (BOOL-CONST (< n1 n2))) env )]

                 [(list (EQ) tail ...) (def (INT-CONST n1) (stack-peek stack))
                                       (def (INT-CONST n2) (stack-peek (stack-pop stack)))
                                       (def new-stack (stack-pop (stack-pop stack)))
                                       (run tail (stack-push new-stack (BOOL-CONST (eq? n1 n2))) env )]

                 [(list (AND) tail ...) (def (BOOL-CONST n1) (stack-peek stack))
                                        (def (BOOL-CONST n2) (stack-peek (stack-pop stack)))
                                        (def new-stack (stack-pop (stack-pop stack)))
                                        (run tail (stack-push new-stack (BOOL-CONST (and n2 n1))) env )]

                 [(list (OR) tail ...) (def (BOOL-CONST n1) (stack-peek stack))
                                       (def (BOOL-CONST n2) (stack-peek (stack-pop stack)))
                                       (def new-stack (stack-pop (stack-pop stack)))
                                       (run tail (stack-push new-stack (BOOL-CONST (or n2 n1))) env )]

                 [(list (NOT) tail ...) (def (BOOL-CONST n1) (stack-peek stack))
                                        (def new-stack (stack-pop stack))
                                        (run tail (stack-push new-stack (BOOL-CONST (not n1))) env )]

                 [(list (CLOSURE ins) tail ...) (run tail (stack-push stack (closureV ins env)) env )]

                 [(list (APPLY) tail ...)
                  (def (closureV ins envc) (stack-peek stack))
                  (def arg (stack-peek (stack-pop stack)))
                  (def new-stack (stack-pop (stack-pop stack)))
                  (run ins (stack-push (stack-push new-stack env) tail) (cons arg envc))
                  ]

                 [(list (RETURN) tail ...)(def return (stack-peek stack))
                                          (def oins (stack-peek (stack-pop stack)))
                                          (def oenv (stack-peek (stack-pop (stack-pop stack))))
                                          (def new-stack (stack-pop (stack-pop (stack-pop stack))))
                                          (run oins (stack-push new-stack return) oenv)]



                 )))])))


;; debug-run :: List[Instruction], Stack -> void
;; Debug function for the machine
(define (debug-run ins-list stack)
  (begin
    (display "\ninstructions: ")
    (print ins-list)
    (display "\nstack: ")
    (stack-debug stack)
    (display "\n")))

;machine
;; machine :: List[Instruction] -> Expr
;; ejecuta la lista de instrucciones en una maquina con stack y ambiente vacios
(define (exec-machine ins-list)
  (run ins-list (stack-init) '()))