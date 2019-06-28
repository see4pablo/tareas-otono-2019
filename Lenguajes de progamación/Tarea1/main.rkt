#lang play
(require "machine.rkt")
(print-only-errors #t)

;;;;;;;;;;;;;;;;;;;;;;;
;; Language definition
;;;;;;;;;;;;;;;;;;;;;;;
;para futuras definiciones s-expr, es una seudo expresión,
;aún no parseada que contiene una lista y símbolos básicos del lenguaje
      
#|
<Expr> ::= <num>
         | <id>
         | {+ <Expr> <Expr>}
         | {- <Expr> <Expr>}
         | {with {<Expr> : <type> <Expr>} <Expr>}
         | {fun {<id>  : <Expr>} [: <type>] <expr>}
         | {<expr> <expr>}   |#
(deftype Expr
  (num n)
  (add l r)
  (sub l r)
  (id s) 
  (fun id targ body tbody)
  (fun-db body)
  (acc n) ;Se usa para la pregunta 3
  (app fun-id arg-expr))

#|
<Type> ::= <Num>
        | {<Type> -> <Type>}}
|#

(deftype Type
  (TNum)
  (TFun arg ret))

; ADT:
; deftype Env
; empty-env: Env
; extend-env: Id Val Env -> Env


(deftype Env
  (mtEnv)
  (aEnv id val next))

(define empty-env (mtEnv))

(define extend-env aEnv)

; lookup-typeEnv: <id> -> Type
; Busca una variable en una lista y entrega su tipo
; Se usará en el typeof para buscar tipos de variables
(define (lookup-typeEnv x env)
  (match env
    [(mtEnv) (error "Type error: free identifier:"x)]
    [(aEnv id val next)
     (if (equal? id x)
         val
         (lookup-typeEnv x next))]))

; lookup-accEnv: <id> -> Int
; Busca una variable en una lista y entrega su índice de Bruijn respecto al ambiente
(define (lookup-accEnv x env)
  (match env
    [(mtEnv) (error "Free identifier:"x)]
    [(aEnv id val next)
     (if (equal? id x)
         val
         (lookup-accEnv x next))]))

; A partir de una variable nueva, actualiza el ambiente anterior con los indices para cada variable aumentados,
; se elimina una variable con el mismo id
; addBruijn: <env> <id> -> <env>
(define (addBruijn id env)
  (match env
    [(mtEnv) (mtEnv)]
    [(aEnv idEnv val next)
     (if (equal? id idEnv)
         next
         (aEnv idEnv (add1 val) (addBruijn id next))   ;else
         )]
    )
  )


#|
<s-expr> ::= <Tnum>
          | (list <s-expr> '-> <s-expr>)
; Parses a s-expr into a 'Type' type
; parse-type: s-expr -> Type
|#
(define (parse-type s-expr)
  (match s-expr
    ['Num (TNum)]
    [(list s1 '-> s2) (TFun (parse-type s1) (parse-type s2))]
    [_ (error "Parse error")])
  )

#|
<s-expr> ::= <num>
          | <id>
          | (list '+ <s-expr> <s-expr>)
          | (list '- <s-expr> <s-expr>)
          | (list 'with {list <id> ': <Type> <s-expr>} <s-expr>)
          | (list 'fun {list <id> ': <Type>} [list ': <Type>] <s-expr>) ;; '[]' means optional
          | (list <fun> <expr>) ;;this is for application of function
; Parses a s-expr into a 'Expr' type
; parse: s-expr -> Expr
|#
(define (parse s-expr)
  (match s-expr
    [(? number?) (num s-expr)]
    [(? symbol?) (id s-expr)]
    [(list '+ s1 s2) (add (parse s1) (parse s2))]
    [(list '- s1 s2) (sub (parse s1) (parse s2))]
    [(list 'with {list x ': t e} b)
     (app (fun x (parse-type t) (parse b) #f) (parse e))]
    [(list 'fun {list x ': t1} ': t2 b) (fun x (parse-type t1) (parse b) (parse-type t2))] ;esto es para cuando se define la salida
    [(list 'fun {list x ': t1} b) (fun x (parse-type t1) (parse b) #f)]
    [(list fun expr) (app (parse fun) (parse expr))]
    
    )
  )
; prettify: Type -> s-expr
; Toma un tipo y lo escribe en la sintaxis concreta, "entendible por el humano"
(define (prettify type)
  (match type
    [(TNum) 'Num]
    [(TFun tIn tOut) (list (prettify tIn) '-> (prettify tOut))] ))



; Toma una expresión y la remplaza por otra que posee índices de Bruijn, se usará (acc n) y (fun-db body) para ello
; deBrujin: Expr -> Expr
(define (deBruijn expr (env empty-env))
  (match expr
    [(num n) (num n)]
    [(add l r) (add (deBruijn l env) (deBruijn r env))]
    [(sub l r) (sub (deBruijn l env) (deBruijn r env))]
    [(id x) (acc (lookup-accEnv x env))]
    [(fun id targ body tbody) (fun-db (deBruijn body (extend-env id 0 (addBruijn id env))))]
    [(app fun-id arg-expr) (app (deBruijn fun-id env) (deBruijn arg-expr env))]
    ))

; Crea una lista a partir de elementos provenientes de listas como individuales
; create-list: (list[A] o A, list[A] o A) -> list[A])
(define (create-list A B)
  (if (list? A)
      (if (list? B)
          (append A B) ;; caso en que A y B son listas
          (append A (list B))) ;; caso en que solo A es lista
      (if (list? B)
          (append (list A) B) ;;caso en que solo B es lista
          (list A B)) ;; caso en que ninguno es lista
      ))



; Transforma una expresión (con indices de Bruijn) a código de máquina,
; es decir una lista de instrucciones
; compile: Expr -> list[Instruction]
(define (compile expr)
  (match expr
    [(num n) (INT-CONST n)]
    [(acc n) (ACCESS n)]
    [(add l r) (list (compile r) (compile l) (ADD))]
    [(sub l r) (list (compile r) (compile l) (SUB))]
    [(app fun-id arg-expr) (create-list (create-list (compile arg-expr) (compile fun-id)) (APPLY))]
    [(fun-db body) (CLOSURE (create-list (compile body) (RETURN)))]
    ))


; Retorna el tipo de una expresión,
; también verifica que todos los tipos de datos dentro de ella esten sintácticamente correctos
; typeof: Expr -> Type
(define (typeof expr (env empty-env))
  (match expr
    [(num n) (TNum)]
    [(id x) (lookup-typeEnv x env)]
    [(fun id targ body tbody) (if tbody
    (if (equal? tbody (typeof body (extend-env id targ env))) ;Caso función con tipo de cuerpo definido
               (TFun targ tbody) ;Caso exitoso
               (error "Type error in expression fun position 1: expected"(prettify tbody) 'found  (prettify (typeof body env)))) ;Caso error
    (TFun targ (typeof body (extend-env id targ env)))) ;Caso función sin tipo de cuerpo definido 
        ]
    [(app fun-id arg-expr) (match (typeof fun-id env)
       [(TFun tin tout) (if (equal? tin (typeof arg-expr env)) ;Casos para tipo correcto de funcion
                            tout ;Caso en que el tipo enunciado en la funcion de entrada es igual al tipo de el argumento entregado
                            (error "Type error in expression app position 2: expected"(prettify tin) 'found (prettify (typeof arg-expr env))) ;Caso de error
                            )] 
       [else (error "Type error in expression app position 1: expected (T -> S) found"(prettify (typeof fun-id env)))] ; error
                             )]
    [(add l r) (if (not (equal? (TNum) (typeof l env)))
     (error "Type error in expression + position 1: expected"(prettify (TNum)) 'found (prettify (typeof l env))) ;Caso que el operador 1 no es TNum
               (if (not (equal? (TNum) (typeof r env)))
     (error "Type error in expression + position 2: expected"(prettify (TNum)) 'found (prettify (typeof r env))) ;Caso en que el operador 2 no es TNum
     (TNum) ;Caso exitoso
     ))]
    [(sub l r) (if (not (equal? (TNum) (typeof l env)))
     (error "Type error in expression - position 1: expected"(prettify (TNum)) 'found (prettify (typeof l env))) ;Caso que el operador 1 no es TNum
               (if (not (equal? (TNum) (typeof r env)))
     (error "Type error in expression - position 2: expected"(prettify (TNum)) 'found (prettify (typeof r env))) ;Caso en que el operador 2 no es TNum
     (TNum) ;Caso exitoso
     ))]
    )
  )
; Retorna el tipo de una expresión (aun no parseada) en un formato legible
; typecheck: s-expr -> Type
(define (typecheck s-expr) (prettify (typeof (parse s-expr))))

; Realiza todo el proceso de generación de código de maquina desde un programa
; Parsing, validación de tipos, transformación a deBruijn y finalmente compilar
; typed-compile: <s-expr> -> list[Instruction]
(define (typed-compile s-expr)
  (let ([parsed (parse s-expr)])
    (typeof parsed)
  (compile (deBruijn parsed)))
  )