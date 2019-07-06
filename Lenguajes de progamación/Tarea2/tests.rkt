#lang play

;Author: Pablo Aliaga
;adaptación de lenguaje MiniScheme para lazyness, pretty-printing y streams

(print-only-errors #t)

(require "main.rkt")
;; Test sub-module.
;; See http://blog.racket-lang.org/2012/06/submodules.html

;this tests should never fail; these are tests for MiniScheme+ 
(module+ test
  (test (run '{+ 1 1}) 2)
  
  (test (run '{{fun {x y z} {+ x y z}} 1 2 3}) 6)  
  
  (test (run '{< 1 2}) #t)
  
  (test (run '{local {{define x 1}}
                x}) 1)
  
  (test (run '{local {{define x 2}
                      {define y {local {{define x 1}} x}}}
                {+ x x}}) 4)
  
  ;; datatypes  
  (test (run '{local {{datatype List {Empty} {Cons a b}}} {List? {Empty}}}) #t)
  
  (test (run '{local {{datatype List {Empty} {Cons a b}}} {Empty? {Empty}}}) #t)
  
  (test (run '{local {{datatype List {Empty} {Cons a b}}} {List? {Cons 1 2}}}) #t)
  
  (test (run '{local {{datatype List {Empty} {Cons a b}}} {Cons? {Cons 1 2}}}) #t)
  
  (test (run '{local {{datatype List {Empty} {Cons a b}}} {Empty? {Cons 1 2}}})
        #f)
  
  (test (run '{local {{datatype List {Empty} {Cons a b}}} {Empty? {Empty}}}) #t)
  
  (test (run '{local {{datatype List {Empty} {Cons a b}}} {Cons? {Empty}}})
        #f)      
  
  ;; match
  (test (run '{match 1 {case 1 => 2}}) 2)
  
  (test (run '{match 2
                {case 1 => 2}
                {case 2 => 3}})             
        3)
  
  (test (run '{match #t {case #t => 2}}) 2)
  
  (test (run '{match #f
                {case #t => 2}
                {case #f => 3}})             
        3)

  (test (run '{local {{datatype Nat
                                {Zero}
                                {Succ n}}
                      {define pred {fun {n} 
                                        {match n
                                          {case {Zero} => {Zero}}
                                          {case {Succ m} => m}}}}}
                {Succ? {pred {Succ {Succ {Zero}}}}}})
        #t)
  (test (run '{local {{datatype Nat
                                {Zero}
                                {Succ n}}
                      {define pred {fun {n} 
                                        {match n
                                          {case {Zero} => {Zero}}
                                          {case {Succ m} => m}}}}}
                {Succ? {pred {Succ {Succ {Zero}}}}}}) #t))

;tests for extended MiniScheme+ 
#;(module+ sanity-tests
    (test (run '{local {{datatype Nat 
                  {Zero} 
                  {Succ n}}
                {define pred {fun {n} 
                               {match n
                                 {case {Zero} => {Zero}}
                                 {case {Succ m} => m}}}}}
          {pred {Succ {Succ {Zero}}}}}) "{Succ {Zero}}"))
  
;---- ACA COMIENZAN MIS TESTS --------
    

;Test 1 Pretty printing, Succ zero
(test (pretty-printing (structV 'Nat 'Succ (list (structV 'Nat 'Zero empty))))
"{Succ {Zero}}")
;Test 2 Pretty printing, Succ Succ Zero
(test (pretty-printing (structV 'Nat 'Succ (list (structV 'Nat 'Succ (list (structV 'Nat 'Zero '()))))))
"{Succ {Succ {Zero}}}")


;Prueba para extender el ambiente con listas y length
 (test (run '{local {{datatype List 
                  {Empty} 
                  {Cons a b}}
                {define length {fun {lista} 
                               {match lista
                                 {case {Empty} => 0}
                                 {case {Cons a resto} => {+ 1 {length resto}}}}}}}
          {length {Cons 1 {Cons 2 {Cons 3 {Empty}}}}}}) 3)

;Prueba de run con implementacion de Listas y length
(test (run (prepare '{Empty? {Empty}})) #t)

;Prueba de length con implementacion de run
(test (run '{length {Cons 1 {Cons 2 {Cons 3 {Empty}}}}}) 3)

;Prueba del parser para traducir list a Cons del lenguaje
;(test (list-parser '{list 1 2 3 4})
 ;     '(Cons 1 (Cons 2 (Cons 3 (Cons 4 (Empty))))))

;Prueba del azucar sintactico list en el run
(test (run '{match {list {+ 1 1} 4 6}
          {case {Cons h r} => h}
          {case _ => 0}})
2)
;Prueba 2 del azucar sintáctico list en el run
(test (run '{match {list}
          {case {Cons h r} => h}
              {case _ => 0}})
0)

;Prueba de extension de list a pattern matching case
(test (run '{match {list 2 {list 4 5} 6}
          {case {list a {list b c} d} => c}})
5)

;Arreglos pretty-printing para listas
(test (run '{list})
"{list}")

(test (run '{list 1 4 6})
"{list 1 4 6}")

(test (run '{list 1 4 {list 3 6} 7})
"{list 1 4 {list 3 6} 7}")

;Test simples para ir comprobando transicion del lenguaje a lazy
(test (run '{{fun {x} 1} 2})
1)

(test (run '{{fun {x {lazy y}} {+ x y}} 3 4}) 7)

;Error test (PLAY no soporta excepciones de runtime)
;(test/exn (run '{{fun {x  y} x} 1 {/ 1 0}}) "/: division by zero") ()

(test (run '{{fun {x  {lazy y}} x} 1 {/ 1 0}}) 1)

(test (run '{local {{datatype T 
                  {C {lazy a}}}
                {define x {C {/ 1 0}}}}
          {T? x}}) #t)

;Error test (PLAY no soporta excepciones de runtime)
;(test/exn (run '{local {{datatype T 
                  ;{C a}}
                ;{define x {C {/ 1 0}}}}
          ;{T? x}}) "/: division by zero")

(test (run '{local {{datatype T {C a {lazy b}}}
                {define x {C  0 {+ 1 2}}}}
               x})
"{C 0 3}"     )

;;test obtenido desde otro alumno
(test (run '{local
              {{datatype A {B x {lazy y}}}}
              {match {B 2 {/ 1 0}}
                {case {B 2 h} => 2}
                {case _ => 5}}})
      2)
;;test obtenido desde otro alumno para probar condicionales
(test (run '{{fun {{lazy x}} {if x 1 2}} #f}) 2)
(test (run '{{fun {{lazy x}} {if x 1 2}} #t}) 1)

;;test de funciones basicas de stream
(test (run `{local {,stream-data ,make-stream ,ones} {lazyCons 1 2}}) "{lazyCons 1 2}")
(test (run `{local {,stream-data ,make-stream ,ones} {lazyCons 1 {lazyCons 1 {/ 4 2}}}}) "{lazyCons 1 {lazyCons 1 2}}")
(test (run `{local {,stream-data ,make-stream ,ones} {make-stream 1 2}}) "{lazyCons 1 2}")
(test (run `{local {,stream-data ,make-stream ,ones} {make-stream 1 {make-stream 2 3}}}) "{lazyCons 1 {lazyCons 2 3}}")

(test (run `{local {,stream-data ,make-stream ,ones ,stream-tl ,stream-hd} {stream-hd {make-stream 2 3}}})
2)
(test (run `{local {,stream-data ,make-stream ,ones ,stream-tl ,stream-hd} {stream-tl {make-stream 2 3}}}) 3)
(test (run `{local {,stream-data ,make-stream ,ones ,stream-tl ,stream-hd} {stream-hd {make-stream 1 {/ 1 0}}}})
1)

(test (run `{local {,stream-data ,make-stream ,stream-hd ,ones}
{stream-hd ones}})
1)
(test (run `{local {,stream-data ,make-stream
                             ,stream-hd ,stream-tl ,ones}
          {stream-hd {stream-tl ones}}})
1)

(test (run `{local ,stream-lib
          {local {,ones ,stream-take}
            {stream-take 10 ones}}})
"{list 1 1 1 1 1 1 1 1 1 1}")

(test (run `{local ,stream-lib
          {local {,ones ,stream-zipWith}
            {stream-take 10
                         {stream-zipWith
                          {fun {n m}
                               {+ n m}}
                          ones
                          ones}}}})
"{list 2 2 2 2 2 2 2 2 2 2}")

;division by zero test
(test (run `{local ,stream-lib
          {local {,ones ,stream-take}
            {stream-take 3 {make-stream 1 {make-stream 2 {make-stream 3 {make-stream {/ 1 0} {5}}}}}}}})
"{list 1 2 3}")

;Error test (PLAY no soporta excepciones de runtime)
;(test/exn (run `{local ,stream-lib
 ;         {local {,ones ,stream-take}
  ;          {stream-take 4 {make-stream 1 {make-stream 2 {make-stream 3 {make-stream {/ 1 0} {5}}}}}}}})
;"/: division by zero")

;test fibonacci
(test (run `{local ,stream-lib
          {local {,stream-zipWith ,fibs}
            {stream-take 10 fibs}}})
"{list 1 1 2 3 5 8 13 21 34 55}")

;test merge-sort
(test (run `{local ,stream-lib
               {local {,stream-take ,merge-sort ,fibs ,stream-zipWith}
                 {stream-take 10 {merge-sort fibs fibs}}}})
"{list 1 1 1 1 2 2 3 3 5 5}")

;segundo test de merge-sort mas simple
(test (run `{local ,stream-lib
               {local {,stream-take ,merge-sort ,fibs ,stream-zipWith ,ones}
                 {stream-take 6 {merge-sort
                                 {make-stream 1 {make-stream 5 {make-stream 10 {make-stream 15 ones}}}}
                                 {make-stream 3 {make-stream 7 {make-stream 12 ones}}}
                                 }}}})
"{list 1 3 5 7 10 12}")

  



