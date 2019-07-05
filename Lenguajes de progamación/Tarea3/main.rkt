#lang play

#|
<expr> ::= <num>
         | <id>
         | <bool>
         | (if <expr> <expr> <expr>)
         | (+ <expr> <expr>)
         | '< <expr> <expr>)
         | (* <expr> <expr>)
         | (= <expr> <expr>)
         | (- <expr> <expr>)
         | (and <expr> <expr>)
         | (or <expr> <expr>)
         | (not <expr> <expr>)         
         | (seqn <expr> <expr>)
         | (local { <def>*} <expr>)

<def>    ::= (define <id> <expr>)


;EXTENSION PARA CLASE Y OBJETOS
<expr> ::= ... (expresiones del lenguage entregado) ...
        | (class <member>*)
        | (new <expr>)
        | (get <expr> <id>)
        | (set <expr> <id> <expr>)
        | (send <expr> <id> <expr>*)
        | this
        | (class <: <expr> <member>* )
        | (super <id> <expr>*
 
<member>  ::= (field <id> <expr>)
         | (method <id> (<id>*) <expr>)
|#


(deftype Expr
  (num n)
  (bool b)
  (id s)   
  (binop f l r)
  (unop f s)
  (my-if c tb fb)  
  (seqn expr1 expr2)  
  (lcal defs body)
  
  ;;added by me, class related stuffs

  (class parent members)
  (new c)
  (get obj id)
  (set obj id val)
  (send obj id values)
  (this)
  )

;;member
(deftype Member
  (field id expr)
  (method id ins body))

;; values
(deftype Val
  (numV n)
  (boolV b)
  (classV parent fields methods env) ;;class-env can have methods and fields
  (objectV class values) ;;object-env only doesn't have methods, only fields
  (methodV ins body)
  (None))

(deftype Def
  (my-def id expr))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#|
Environment abstract data type
 
empty-env        :: Env
env-lookup       :: Sym Env -> Val
multi-extend-env :: List<Sym> List<Val> Env -> Env
extend-frame-env! :: Sym Val Env -> Env 


representation BNF:
<env> ::= (mtEnv)
        | (aEnv <id> <val> <env>)
|#

(deftype Env
  (mtEnv)
  (aEnv hash env)) 

(def empty-env (mtEnv))

#|
env-lookup:: Sym Env -> Val
Busca un símbolo en el ambiente, retornando su valor asociado.
|#
(define (env-lookup x env)
  (match env
    [(mtEnv) (error 'env-lookup "free identifier: ~a" x)]
    [(aEnv hash rest)
     (if (hash-has-key? hash x)
         (hash-ref hash x)
         (env-lookup x rest))]))



;;method-lookup datatype,
;;básicamente entrega el metodo encontrado y su posición relativa en los frames de metodos
(deftype MethodResponse
  (method-response m p)
  )

#|
method-lookup:: Sym Env -> MethodV
Busca un símbolo en el ambiente de métodos, retornando su método asociado.
|#
(define (method-lookup x env [counter 0])
  (match env
    [(mtEnv) (error 'method-lookup "Object class don't have method: ~a" x)]
    [(aEnv hash rest)
     (if (hash-has-key? hash x)
         (method-response (hash-ref hash x) counter)
         (method-lookup x rest (add1 counter)))]))

#|
multi-extend-env:: List(Sym) List(Expr) Env -> Env
Crea un nuevo ambiente asociando los símbolos a sus valores.
|#
(define (multi-extend-env ids exprs env)
  (if (= (length ids) (length exprs))
      (aEnv (make-hash (map cons ids exprs)) env)
      (error "wrong_input, mismatched lengths")))

#|
extend-frame-env!:: Sym Val Env -> Void
Agrega un nuevo par (Sym, Val) al ambiente usando mutación.
Este método no crea un nuevo ambiente.
|#
(define (extend-frame-env! id val env)
  (match env
    [(mtEnv) (aEnv (make-hash (list (cons id val))) env)]
    [(aEnv h rEnv) (let* ([l (hash->list h)]
                          [la (cons (cons id val) l)])
                     (set-aEnv-hash! env (make-hash la)))]))

#|
update-frame-env!:: Sym Val Env -> Void
Actualiza un hash-value del ambiente usando mutación
Este método se usara para los setters de los objetos
|#
(define (update-frame-env! id val env)
  (match env
    [(mtEnv) (aEnv (make-hash (list (cons id val))) env)]
    [(aEnv h rEnv) (hash-set! h id val)]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; parse :: s-expr -> Expr
(define (parse s-expr)
  (match s-expr
    ['this (this)]
    [(? number?) (num s-expr)]
    [(? symbol?) (id s-expr)]    
    [(? boolean?) (bool s-expr)]
    [(list '* l r) (binop * (parse l) (parse r))]
    [(list '+ l r) (binop + (parse l) (parse r))]
    [(list '- l r) (binop - (parse l) (parse r))]
    [(list '< l r) (binop < (parse l) (parse r))]
    [(list '= l r) (binop = (parse l) (parse r))]    
    [(list 'or l r) (binop (λ (i d) (or i d)) (parse l) (parse r))]
    [(list 'and l r) (binop (λ (i d) (and i d)) (parse l) (parse r))]
    [(list 'not b) (unop not (parse b))]
    [(list 'if c t f) (my-if (parse c)
                             (parse t)
                             (parse f))]
    [(list 'seqn e1 e2) (seqn (parse e1) (parse e2))]    
    [(list 'local (list e ...)  b)
     (lcal (map parse-def e) (parse b))]
    
    ;;class related stuffs

    [(list 'class '<: parent members ...) (class (parse parent) (map parse members))]
    [(list 'class members ...) (class Object (map parse members))]
    [(list 'method id (list args ...) body) (method (parse id) (map parse args) (parse body))]
    [(list 'field id val) (field (parse id) (parse val))]
    [(list 'new c) (new (parse c))]
    [(list 'get o id) (get (parse o) (parse id))]
    [(list 'set o id val) (set (parse o) (parse id) (parse val))]
    [(list 'send o m vals ...) (send (parse o) (parse m) (map parse vals))]
    ))

;; Root Object
(define Object (classV (None) empty-env empty-env empty-env))


;; parse-def :: s-expr -> Def
(define (parse-def s-expr)
  (match s-expr
    [(list 'define id b) (my-def id (parse b))]))

;; interp :: Expr Env -> Val
(define (interp expr env)
  (match expr
    [(num n) (numV n)]    
    [(bool b) (boolV b)]    
    [(binop f l r) (make-val (f (open-val (interp l env))
                                (open-val (interp r env))))]
    [(unop f s) (make-val (f (open-val (interp s env))))]
    [(my-if c t f)
     (def (boolV cnd) (interp c env))
     (if cnd
         (interp t env)
         (interp f env))]
    [(id x) (env-lookup x env)]        
    [(seqn expr1 expr2) (begin 
                          (interp expr1 env)
                          (interp expr2 env))]
    [(lcal defs body)
     (let* ([new-env (multi-extend-env '() '() env)])
       (for-each (λ(x)
                   (let ([in-def (interp-def x new-env)])
                     (extend-frame-env! (car in-def) (cdr in-def) new-env)
                     #t)) defs)       
       (interp body new-env))     
     ]
    
    ;; class related stuffs!
    
    [(this) (env-lookup (this) env)]
    [(classV parent fields methods class-env) expr] ; Already interpreted classV
    [(objectV class values) expr] ;Already interpreted objectV
    [(class parent members) (let* ([fields (filter field? members)]
                                   [methods (filter method? members)]
                                   [id-fields (map (λ (v) (id-s (field-id v))) fields)]
                                   [values-fields (map (λ (v) (interp-class-member v env)) fields)]
                                   [id-methods (map (λ (v) (id-s (method-id v))) methods)]
                                   [values-methods (map (λ (v) (interp-class-member v env)) methods)]
                                   [interp-parent (interp parent env)]
                                   [field-env (multi-extend-env id-fields values-fields (classV-fields interp-parent))]
                                   [method-env (multi-extend-env id-methods values-methods (classV-methods interp-parent))])
                              (classV interp-parent field-env method-env env))]
    
    [(send o m args) (let* ([obj (interp o env)]
                            [methodR (method-lookup (id-s m) (classV-methods (objectV-class obj)))]
                            [m (method-response-m methodR)] ;; método en sí
                            [p (method-response-p methodR)] ;; posición de la clase a la que pertenece el método
                            [id-args (map id-s (methodV-ins m))] ;;agregar args al ambiente
                            [values-args (map (λ (arg) (interp arg env)) args)]
                            [new-env (multi-extend-env id-args values-args env)])
                       
                       (begin
                         (extend-frame-env! (this) obj new-env) ;;agregar this al ambiente
                         (interp (methodV-body m) new-env))
                       )]
                     
                           
    [(new c) (let ([origin-class (interp c env)])
               (objectV origin-class (classV-fields origin-class)))]
    [(get o id) (let ([obj (interp o env)])
                    (interp id (objectV-values obj))
                    )]
    [(set o id val) (let ([obj (interp o env)])
                        (update-frame-env! (id-s id) (interp val env) (objectV-values obj))
                      )]
    ))
  

;; interp-class-members :: member -> Value
;; Toma un member y lo deja como valores , en el caso de los metodos como methodV
(define (interp-class-member member env)
  (match member
    [(field id val) (interp val env)]
    [(method id ins body) (methodV ins body)]
    [else (error "not valid member of class")] ))


;; open-val :: Val -> Scheme Value
(define (open-val v)
  (match v
    [(numV n) n]
    [(boolV b) b]
    ))

;; make-val :: Scheme Value -> Val
(define (make-val v)
  (match v
    [(? number?) (numV v)]
    [(? boolean?) (boolV v)]
    ))

;; interp-def :: Def, Env -> Expr
(define (interp-def a-def env)
  (match a-def
    [(my-def id body) (cons id (interp body env))]))

;; run :: s-expr -> Val
(define (run s-expr)
  (interp (parse s-expr) empty-env))
3
#|
run-val:: s-expr -> Scheme-Val + Val
Versión alternativa de run, que retorna valores de scheme para primitivas y
valores de MiniScheme para clases y objetos
|#
(define (run-val s-expr)
  (define val (interp (parse s-expr) empty-env))
  (match val
    [(numV n) n]
    [(boolV b) b]
    [x x]))