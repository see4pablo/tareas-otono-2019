#lang play

;Author: Pablo Aliaga
;implementación lenguaje orientado a objetos utilizando Scheme como base

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
  (call obj id values) ; se usa luego de que se realiza un send
  (this) ; reserved words, lookup in the object class ; also refered to the object
  (super) ; reserved words, lookup in the parent class of method ; also refered to the object
  (fun) ; reserved words
  )

;;member
(deftype Member
  (field id expr)
  (method id ins body))

;;method
(deftype Application
  (methodV ins body)) ;;este value es util para guardar los métodos en el env
; sin embargo no son valores como tal, no se pueden retornar, pero se usan en el send

;; values
(deftype Val
  (numV n)
  (boolV b)
  (classV parent fields methods env) ;;class-env can have methods and fields, also has the env in which was created
  (objectV class values) ;;object-env only doesn't have methods, only fields
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


#|
method-lookup:: Sym Env -> MethodV
Busca un símbolo en el ambiente de métodos, retornando su método asociado.
En caso de no encontrarlo lanza un #f para que el interprete busque en la clase padre de la actual
|#
(define (method-lookup x env)
  (match env
    [(mtEnv) (error 'method-lookup "Object class don't have method: ~a" x)]
    [(aEnv hash rest)
     (if (hash-has-key? hash x)
         (hash-ref hash x)
         #f)]))

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
Este método se usara para los setters de los objetos;
Extend-frame-env NO actualiza keys que ya existan, por esto fue creado esta función
|#
(define (update-frame-env! id val env)
  (match env
    [(mtEnv) (aEnv (make-hash (list (cons id val))) env)]
    [(aEnv h rEnv) (hash-set! h id val)]))

#|
copy-env:: Env -> Env
Crea una nueva estructura de aEnv que es copia de el env entregado, pero que no comparte direcciones de memoria,
 es decir, no se afecta por la mutación de su copia
|#
(define (copy-env env)
  (match env
    [(mtEnv) (mtEnv)]
    [(aEnv hash rest) (aEnv (hash-copy hash) (copy-env rest))])
  )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; parse :: s-expr -> Expr
(define (parse s-expr)
  (match s-expr
    ['this (this)]
    ['super (super)]
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
    [(list 'super m vals ...) (send (super) (parse m) (map parse vals))] ; super call
    [(list 'fun (list ins ...) body) (new
                                      (class Object (list (method (id (fun)) (map parse ins) (parse body)))))] ; lambda implementation with objects
    [(list idFun vals ...) (send (parse idFun) (id (fun)) (map parse vals))] ; lambda aplication
    ))

;; Root Object
(define Object (classV (None) empty-env empty-env empty-env))


;; parse-def :: s-expr -> Def
(define (parse-def s-expr)
  (match s-expr
    [(list 'define id b) (my-def id (parse b))]))

;; interp :: Expr Env -> Val
;; Este interprete se usa cuando NO estamos interpretando un método de un objeto,
;; por eso luego de interpretar un send, se usa interp-obj en vez de este
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
    
    [(this) (error "This is a reserved word for objects")]
    [(super) (error "Super is a reserved word for objects")]
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
                            [new-expr (call obj m args)]
                            [fields (objectV-values obj)]
                            [methods (classV-methods (objectV-class obj))])
                        (interp-obj new-expr obj fields methods env)) ;; inicializa el llamado dentro de un objeto
                       ]
                     
                           
    [(new c) (let ([origin-class (interp c env)])
               (objectV origin-class (copy-env (classV-fields origin-class))))]
    [(get o id) (let* ([obj (interp o env)]
                       [fields (objectV-values obj)]
                       [methods (classV-methods (objectV-class obj))])
                  (interp-obj (get obj id) obj fields methods env))]
    [(set o id val) (let* ([obj (interp o env)]
                       [fields (objectV-values obj)]
                       [methods (classV-methods (objectV-class obj))])
                      (interp-obj (set obj id val) obj fields methods env))]
    ))


#|
interp-object :: Expr ObjectV Env[Fields] Env[Methods] Env -> Val
Interprete exclusivo para metodos o llamados a objetos. Se utiliza luego de un llamado send.
Rste mantiene en sus argumentos siempre los fields y metodos del objeto y la clase respectivamente,
de esta forma se puede manejar de manera sencilla , los llamados a this, la busqueda de fields con sus métodos respectivos (respetando field shadowing)
y los llamados a super.
|#
(define (interp-obj expr this-obj fields methods env)
  (match expr
    [(num n) (numV n)]    
    [(bool b) (boolV b)]    
    [(binop f l r) (make-val (f (open-val (interp-obj l this-obj fields methods env))
                                (open-val (interp-obj r this-obj fields methods env))))]
    [(unop f s) (make-val (f (open-val (interp-obj s this-obj fields methods env))))]
    [(my-if c t f)
     (def (boolV cnd) (interp-obj c this-obj fields methods env))
     (if cnd
         (interp-obj t this-obj fields methods env)
         (interp-obj f this-obj fields methods env))]
    [(id x) (env-lookup x env)]        
    [(seqn expr1 expr2) (begin 
                          (interp-obj expr1 this-obj fields methods env)
                          (interp-obj expr2 this-obj fields methods env))]
    [(lcal defs body)
     (let* ([new-env (multi-extend-env '() '() env)])
       (for-each (λ(x)
                   (let ([in-def (interp-def-obj x this-obj fields methods new-env)])
                     (extend-frame-env! (car in-def) (cdr in-def) new-env)
                     #t)) defs)       
       (interp-obj body this-obj fields methods new-env))     
     ]
    
    ;; class related stuffs!
    
    [(this) this-obj]
    [(super) this-obj]
    [(classV parent fields methods class-env) expr] ; Already interpreted classV
    [(objectV class values) expr] ;Already interpreted objectV
    [(class parent members) (let* ([fields (filter field? members)] ;se filtran los members que sean fields
                                   [methods (filter method? members)] ; se filtran los members que sean methods
                                   [id-fields (map (λ (v) (id-s (field-id v))) fields)]
                                   [values-fields (map (λ (v) (interp-class-member-obj v this-obj fields methods env)) fields)]
                                   [id-methods (map (λ (v) (id-s (method-id v))) methods)]
                                   [values-methods (map (λ (v) (interp-class-member-obj v this-obj fields methods env)) methods)]
                                   [parent (interp-obj parent this-obj fields methods env)] ; se interpreta parent
                                   [field-env (multi-extend-env id-fields values-fields (classV-fields parent))]
                                   ; se crea el Env[Field] de la clase, este es un (aEnv hash env), 
                                   ; que crea un hash con los fields nuevos y guarda el field-env del padre
                                   [method-env (multi-extend-env id-methods values-methods (classV-methods parent))])
                                   ; se crea el Env[Method] de la clase, este es un (aEnv hash env), 
                                   ; que crea un hash con los methods nuevos y guarda el method-env del padre
                              (classV parent field-env method-env env))]

    [(send o m args) (let* ([obj (interp-obj o this-obj fields methods env)]
                            [new-expr (call obj m args)]
                            [new-fields (objectV-values obj)]
                            [new-methods (classV-methods (objectV-class obj))])
                        (if (super? o)
                            (interp-obj new-expr obj (aEnv-env fields) (aEnv-env methods) env) ;; caso de llamado a super
                            (interp-obj new-expr obj new-fields new-methods env)) ;; inicializa el llamado dentro de un objeto
                            )]
                        

      ;; Es en call donde se busca por "Capas" los metodos del objeto, si no se encuentra el metodo en la capa de metodos actuales
      ;; se busca en la siguiente, y con ello también se pasa a la siguiente capa de fields (field shadowing)
    [(call o m args) (let* ([obj (interp-obj o this-obj fields methods env)]
                            [methodR (method-lookup (id-s m) methods)])
                       (if methodR
                           (let* ([id-args (map id-s (methodV-ins methodR))] ;;agregar args al ambiente
                                  [values-args (map (λ (arg) (interp-obj arg this-obj fields methods env)) args)]
                                  [new-env (multi-extend-env id-args values-args env)])
                             (begin
                               (extend-frame-env! (this) obj new-env) ;;agregar this al ambiente
                               (interp-obj (methodV-body methodR) this-obj fields methods new-env)))
                           
                           (interp-obj (call o m args) this-obj (aEnv-env fields) (aEnv-env methods) env) ;; Caso en que no encuentre el método
                           ))]
                     
                           
    [(new c) (let ([origin-class (interp-obj c this-obj fields methods env)])
               (objectV origin-class (copy-env (classV-fields origin-class))))] ;; Aca es importante que se usa copy-env, para que dos objetos de una misma clase
    [(get o id) (interp-obj id this-obj fields methods fields)]                 ;; no compartan sus values
    [(set o id val)
     (update-frame-env! (id-s id) (interp-obj val this-obj fields methods env) fields)]
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

;; interp-def-obj :: Def, Env -> Expr
;; interp-def para el caso en que estemos dentro del cuerpo de un objeto
(define (interp-def-obj a-def this fields methods env)
  (match a-def
    [(my-def id body) (cons id (interp-obj body this fields methods env))]))

;; interp-class-members-obj :: member -> Value
;; Toma un member y lo deja como valores , en el caso de los metodos como methodV
;; caso en el que estemos interpretando dentro de los métodos de un objeto
(define (interp-class-member-obj member this fields methods env)
  (match member
    [(field id val) (interp-obj val this fields methods env)]
    [(method id ins body) (methodV ins body)]
    [else (error "not valid member of class")] ))

;; run :: s-expr -> Val
(define (run s-expr)
  (interp (parse s-expr) empty-env))

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
    [(classV parent fields methods env) "<Class>"] ;Esto es para poder mostrar las clases al retornarlas como valor
    [(objectV class values) "<Object>"] ;Esto es para poder mostrar los objetos al retornarlos como valor
    [x x]))