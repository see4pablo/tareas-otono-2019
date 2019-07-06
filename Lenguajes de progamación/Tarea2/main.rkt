#lang play

;Author: Pablo Aliaga
;adaptación de lenguaje MiniScheme para lazyness, pretty-printing y streams


#|
<expr> ::= <num>ASTree
         | <bool>
         | <id>
         | <string>
         | {if <expr> <expr> <expr>}
         | {fun {<id>*}}  <expr>}
         | {<expr> <expr>*}
         | {local {<def>*} <expr>}
         | {match <expr> <case>+}

<case> ::= {'case <pattern> '=> <expr>}
<pattern> ::= <num>
         | <bool>
         | <string>
         | <id>
         | (<constr-id> <attr-id>*)

<def>  ::= {define <id> <expr>}
         | {datatype <typename> <type-constructor>*}}


<type-constructor> ::= {<id> <member>*}
<constr-id> :: = <id>
<attr-id> :: = <id>
<typename> :: = <id>
<member>   :: = <id>

|#
; expresiones
(deftype Expr
  (num n)
  (bool b)
  (str s)
  (ifc c t f)
  (id s)
  (app fun-expr arg-expr-list)
  (prim-app name args)   ; aplicación de primitivas
  (fun id body)
  (lcal defs body)
  (mtch val cases))

; definiciones
(deftype Def
  (dfine name val-expr) ; define
  (datatype name variants)) ; datatype

; variantes
(deftype Variant
  (variant name params))

; estructuras de datos
(deftype Struct
  (structV name variant values))

; closure de id-values para luego diferenciar entre lazy y eager
; esto se usara en el pre-extend-env;
(deftype closureID
  (closureId expr env))

; variables lazy
(deftype Lazy
  (lazyV expr env cache))

; caso en pattern matching
(deftype Case
  (cse pattern body))

; patrón
(deftype Pattern
  (idP id) ; identificador
  (litP l) ; valor literal 
  (constrP ctr patterns)) ; constructor y sub-patrones

;; parse :: s-expr -> Expr
(define(parse s-expr)
  (match s-expr
    [(? number?) (num s-expr)]
    [(? boolean?) (bool s-expr)]
    [(? string?) (str s-expr)]
    [(? symbol?) (id s-expr)]
    [(list 'if c t f) (ifc (parse c) (parse t) (parse f))]
    [(list 'list values ...) (parse (foldr list-parser-fold '{Empty} values))] ;; pattern matching listas ('list)
    [(list 'fun xs b) (fun xs (parse b))]
    [(list 'with (list (list x e) ...) b)
     (app (fun x (parse b)) (map parse e))]
    [(list 'local defs body)
     (lcal (map parse-def defs) (parse body))] 
    [(list 'match val-expr cases ...) ; note the elipsis to match n elements
     (mtch (parse val-expr) (map parse-case cases))] ; para extender el pattern matching hay que ver en especifico el parser  parse-case
    [(list f args ...) ; same here
     (if (assq f *primitives*)
         (prim-app f (map parse args)) ; args is a list
         (app (parse f) (map parse args)))]
    ))


; parse-def :: s-expr -> Def
(define(parse-def s-expr)  
  (match s-expr
    [(list 'define id val-expr) (dfine id (parse val-expr))]
    [(list 'datatype name variants ...) (datatype name (map parse-variant variants))]))

; parse-variant :: sexpr -> Variant
(define(parse-variant v)
  (match v
    [(list name params ...) (variant name params)]))

; parse-case :: sexpr -> Case
(define(parse-case c)
  (match c
    [(list 'case pattern => body) (cse (parse-pattern  pattern) (parse body))]))

; parse-pattern :: sexpr -> Pattern
(define(parse-pattern p)  
  (match p
    [(? symbol?)  (idP p)]
    [(? number?)  (litP (num p))]
    [(? boolean?) (litP (bool p))]
    [(? string?)  (litP (str p))]
    [(list 'list values ...) (parse-pattern (foldr list-parser-fold '{Empty} values))] ;;se introduce parse de list antes de ejecutar el parse de pattern . Azucar Sintáctico
    [(list ctr patterns ...) (constrP (first p) (map parse-pattern patterns))]))

;; interp :: Expr Env -> number/boolean/procedure/Struct
(define(interp expr env)
  (match expr
    ; literals
    [(num n) n]
    [(bool b) b]
    [(str s) s]
    ; conditional
    [(ifc c t f)
     (if (strict (interp c env))
         (strict (interp t env))
         (strict (interp f env)))]
    ; identifier
    [(id x) (env-lookup x env)]

    ; interpretar una expresion cuando no es lazy 
    [(closureId expr env)(interp expr env)]
    
    ; function (notice the meta interpretation)

    ;cambios para implementar lazyevaluation
    [(fun ids body)
     (λ (arg-vals)
       (interp body (extend-env ids arg-vals env)))] ; TODO CHANGES LAZY
    ; application
    [(app fun-expr arg-expr-list) ;; TODO CHANGES, Strict para closure
     ((interp fun-expr env) 
      (map (lambda (a) (closureId a env)) arg-expr-list))] ;; CAMBIAR LAMBDA
    ; primitive application ;;TODO Stricts
    [(prim-app prim arg-expr-list)
     (apply (cadr (assq prim *primitives*))
            (map (λ (a) (strict (interp a env))) arg-expr-list))]
    ; local definitions
    [(lcal defs body)
     (def new-env (extend-env '() '() env))       
     (for-each (λ (d) (interp-def d new-env)) defs) 
     (interp body new-env)]
    ; pattern matching ;;
    [(mtch expr cases)
     (def value-matched (strict (interp expr env)))
     (def (cons alist body) (find-first-matching-case value-matched cases))
     (interp body (extend-env (map car alist) (map cdr alist) env))]))


; interp-def :: Def Env -> Void
(define(interp-def d env)
  (match d
    [(dfine id val-expr)
            (update-env! id (interp val-expr env) env)]
    [(datatype name variants)
     ;; extend environment with new definitions corresponding to the datatype
     (interp-datatype name env)
     (for-each (λ (v) (interp-variant name v env)) variants)]))

; interp-datatype :: String Env -> Void
(define(interp-datatype name env)
  ; datatype predicate, eg. Nat?
  (update-env! (string->symbol (string-append (symbol->string name) "?"))
               (λ (v) (symbol=? (structV-name (interp (first v) '())) name))
               env))

; interp-variant :: String String Env -> Void
(define(interp-variant name var env)
  ;; name of the variant or dataconstructor
  (def varname (variant-name var))  
  ;; lista de los valores que posee el variant, con sus id - lazy o normal.
  (def varlist (variant-params var))
  ;; variant data constructor, eg. Zero, Succ
  
  (update-env! varname
               (λ (args) (let ([args-interp (map (lambda (x param)
                                                 (match param
                                                   [(list 'lazy symbol) (lazyV (closureId-expr x) (closureId-env x) (box #f))]
                                                   [else (interp x '())]
                                                 ))

                                                 args varlist)])
                           (structV name varname args-interp)))
               env)
  ;; variant predicate, eg. Zero?, Succ?
  (update-env! (string->symbol (string-append (symbol->string varname) "?"))
               (λ (v) (symbol=? (structV-variant (interp (first v) '())) varname))
               env))

;;;;
;;;;; pattern matcher
(define(find-first-matching-case value cases)
  (match cases
    [(list) #f]
    [(cons (cse pattern body) cs)
     (let [(r (match-pattern-with-value pattern value))]
       (if (foldl (λ (x y)(and x y)) #t r)
           (cons r body)
           (find-first-matching-case value cs)))]))

(define(match-pattern-with-value pattern value)
  (match/values (values pattern value)
                [((idP i) v) (list (cons i v))]
                [((litP (bool v)) b)
                 (if (equal? v b) (list) (list #f))]
                [((litP (num v)) n)
                 (if (equal? v n) (list) (list #f))]
                [((constrP ctr patterns) (structV _ ctr-name str-values))
                 (if (symbol=? ctr ctr-name)
                     (apply append (map match-pattern-with-value
                                        patterns str-values))
                     (list #f))]
                [(x y) (error "Match failure")]))


;; run :: s-expr -> number/boolean/procedura/struct
;(define(run prog)
 ; (pretty-printing (interp (parse (prepare prog)) empty-env)))
(define (run prog)
  (def res (super-strict (interp (parse (prepare prog)) empty-env)))
   (if (structV? res) (pretty-printing res) res))


#|-----------------------------
Environment abstract data type
empty-env   :: Env
env-lookup  :: Sym Env -> Val 
extend-env  :: List[Sym] List[Val] Env -> Env
update-env! :: Sym Val Env -> Void
|#
(deftype Env
  (mtEnv)
  (aEnv bindings rest)) ; bindings is a list of pairs (id . val)

(def empty-env  (mtEnv))

(define(env-lookup id env)
  (match env
    [(mtEnv) (error 'env-lookup "no binding for identifier: ~a" id)]
    [(aEnv bindings rest)
     (def binding (assoc id bindings))
     (if binding
         (cdr binding)
         (env-lookup id rest))]))

(define (extend-env ids vals env)
  (aEnv (map (lambda (id val) (match id
                                [(list 'lazy sym) (cons sym (lazyV (closureId-expr val) (closureId-env val) (box #f)))]
                                [else (match val
                                        [(closureId closure-expr closure-env)(cons id (interp val '()))]
                                        [raw-val (cons id raw-val)])]))
             ids vals) ; zip to get list of pairs (id . val) ///CHANGES: se mapean las variables dependiendo si es lazy o no
        env))


;; imperative update of env, adding/overring the binding for id.
(define(update-env! id val env)
  (match id
    ;[(list 'lazy symbol) (set-aEnv-bindings! env (cons (cons symbol (lazyV (closureId-expr val) (closureId-env val) (box #f)))))] ;esto no servia para nada
    [else (set-aEnv-bindings! env (cons (cons id val) (aEnv-bindings env)))]
))
  
;;;;;;;

;;; primitives
; http://pleiad.cl/teaching/primitivas
(define *primitives*
  `((+       ,(lambda args (apply + args)))
    (-       ,(lambda args (apply - args)))
    (*       ,(lambda args (apply * args)))
    (%       ,(lambda args (apply modulo args)))             
    (odd?    ,(lambda args (apply odd? args)))
    (even?   ,(lambda args (apply even? args)))
    (/       ,(lambda args (apply / args)))
    (=       ,(lambda args (apply = args)))
    (<       ,(lambda args (apply < args)))
    (<=      ,(lambda args (apply <= args)))
    (>       ,(lambda args (apply > args)))
    (>=      ,(lambda args (apply >= args)))
    (zero?   ,(lambda args (apply zero? args)))
    (not     ,(lambda args (apply not args)))
    (and     ,(lambda args (apply (lambda (x y) (and x y)) args)))
    (or      ,(lambda args (apply (lambda (x y) (or x y)) args)))))

;; ----  FUNCIONES CREADAS POR MI -------


; pretty-printing: <struct> --> String
;                | <Cons a <Cons b ...>> --> "{list a b ...}"                           
; retorna un string con la structura vista de manera mas amigable
(define (pretty-printing expr)
  (match expr
    [(structV 'List variant values)(string-append "{list" (ciclo-pretty-list expr) "}")] ;; aca se inicializa el list y de ahi entra al "ciclo"
    [(structV name variant values) (string-append "{" (symbol->string variant)
                                                  (pretty-printing values) "}")]
    [(list values ...) (foldr (lambda (new before) (string-append " " (pretty-printing new) before)) "" values)] ;(string-append " " (pretty-printing a))]
    [x (~a x)]))


; ciclo-pretty-list: <struct List'> --> String
; retorna un string con la structura interna de una lista, es decir omitiendo parentesis exteriores y el nombre "lista",
; esto para evitar escribir "lista" en cada iteración del pretty-printing
; ej: (ciclo-pretty-list '{cons 1 {cons 2 {cons 3 empty}}}) --> " 1 2 3"
(define (ciclo-pretty-list list)
  (match list
    [(structV 'List 'Empty _) ""]
    [(structV 'List 'Cons values)
     (def (list val rest) values)
     {string-append " " (if (number? val) (number->string val) (pretty-printing val)) (ciclo-pretty-list rest)}]
    ))

; modificar run para agregar listas predefinidas y length
; prepare: <s-expr> --> <s-expr> 
(define (prepare prog) (list 'local '{{datatype List 
                                                {Empty} 
                                                {Cons a b}}
                                      {define length {fun {x} 
                                                          {match x
                                                            {case {Empty} => 0}
                                                            {case {Cons a resto} => {+ 1 {length resto}}}}}}
                                     
                                      } prog))



;pre-parser para hacer azucar sintatico list
;list-parser-fold: <s-expr> --> <s-expr>
(define (list-parser-fold element before)
  (match element
    [(list 'list values ...) (list 'Cons (foldr list-parser-fold '{Empty} values) before)]
    [_ (list 'Cons element before)]))

; strict : Val -> Val - {lazyV}
; evalua las variables lazy para ciertos puntos del programa
(define (strict e)
  (match e
    ;[(structV name variant values) (structV name variant (map (lambda (value) (strict value)) values))]
    [(lazyV expr env cache)
     (if (unbox cache)
         (begin
           ;(printf "using cached val ~v~n" (unbox cache))
           (unbox cache))
         (let ([val (strict (interp expr env))])
           ;(printf "forcing lazyV to ~v~n" val)
           (set-box! cache val)
           (unbox cache))
         )]
    [else else])
  )

;;super-strict : Val -> Val-{lazyV}
;es un strict exclusivo para la salida, pues para el caso de las estructuras, forza la evaluación de todos sus parametros recursivamente
(define (super-strict e)
  (match e
    [(structV name variant values) (structV name variant (map (lambda (value) (super-strict value)) values))]
    [(lazyV expr env cache)
     (if (unbox cache)
         (begin
           (printf "using cached val ~v~n" (unbox cache))
           (unbox cache))
         (let ([val (super-strict (interp expr env))])
           (printf "forcing lazyV to ~v~n" val)
           (set-box! cache val)
           (unbox cache))
         )]
    [else else])
  )

;stream-data {StructV}
;Inicializa el tipo de estructura stream para usarlo en el programa
(def stream-data '{datatype Stream {lazyCons a {lazy b}}})
;;make-stream: Value x Value --> {lazyCons v1 v2}
;crea un stream a partir de dos valores
(def make-stream '{define make-stream {fun {x {lazy y}} {lazyCons x y}}})

;;ones: {} --> (Stream 1 1 1 1 .....)
;; crea un stream de 1's infinito
(def ones '{define ones {make-stream 1 ones}})

;;stream-hd: <Stream> --> value
;retorna el primer elemento del stream, es decir, su cabecera
(def stream-hd '{define stream-hd {fun {x}
                                       {match x
                                         {case {lazyCons a b} => a}}}})

;;stream-tl: <Stream> --> <Stream>
;;retorna la cola del stream, es decir, otro stream
(def stream-tl '{define stream-tl {fun {x}
                                       {match x
                                         {case {lazyCons a b} => b}}}})

;;stream-take: Num x <Stream> --> <List a b c ....>
;;retorna los n primeros elementos del stream
(def stream-take '{define stream-take {fun {n stream}
                                           {if {> n 0} {Cons {stream-hd stream} {stream-take {- n 1} {stream-tl stream}}} {Empty}}
                                           }})

;;librería para inicializar en el programa las funciones y definiciones relacionadas a los Streams
(def stream-lib (list stream-data
                      make-stream
                      stream-hd
                      stream-tl
                      stream-take))

;;stream-zipwith: <fun> <Stream> <Stream> --> <Stream>
(def stream-zipWith '{define stream-zipWith {fun {f s1 s2}
                                                 {make-stream {f {stream-hd s1} {stream-hd s2}} {stream-zipWith f {stream-tl s1} {stream-tl s2}}}
                                                 }})

; fibs: {} --> <Stream>
; genera el stream que contiene la sucesión de números de fibonacci
(def fibs '{define fibs {make-stream 1 {make-stream 1 {stream-zipWith {fun {n m} {+ n m}} fibs {stream-tl fibs}}}}})

; merge-sort: <Stream> <Stream> --> <Stream>
; dados dos streams ordenados (cada uno) retorna un stream con la mezcla de estos ordenada
(def merge-sort '{define merge-sort {fun {s1 s2}
                                         {if {< {stream-hd s1} {stream-hd s2}}
                                             {make-stream {stream-hd s1} {merge-sort {stream-tl s1} s2}} ;then
                                             {make-stream {stream-hd s2} {merge-sort s1 {stream-tl s2}}} ;else
                                             }
                                         }})