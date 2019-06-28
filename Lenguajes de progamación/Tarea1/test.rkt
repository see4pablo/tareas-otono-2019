#lang play
(require "main.rkt")
(require "machine.rkt")


;; parse-type
(test (parse-type '{Num -> Num}) (TFun (TNum) (TNum)))
(test (parse-type 'Num) (TNum))
(test/exn (parse-type '{ -> Num}) "Parse error")


;; parse
(test (parse '{+ 1 3}) (add (num 1) (num 3)))
(test (parse '{- 4 2}) (sub (num 4) (num 2)))
(test (parse '{with {x : Num 5} {+ x 3}}) (app (fun 'x (TNum) (add (id 'x) (num 3)) #f) (num 5)))
(test (parse '{fun {x : Num} {+ x x}}) (fun 'x (TNum) (add (id 'x) (id 'x)) #f))
(test (parse '{fun {x : Num} : Num {+ x 1}}) (fun 'x (TNum) (add (id 'x) (num 1)) (TNum)))
(test (parse '{with {y : Num 2} {+ x y}}) (app (fun 'y (TNum) (add (id 'x) (id 'y)) #f) (num 2)))
(test (parse '((fun (x : Num) x) 1)) (app (fun 'x (TNum) (id 'x) #f) (num 1)))

;; prettify
(test (prettify (TNum)) 'Num)
(test (prettify (TFun (TNum) (TFun (TNum) (TNum)))) '(Num -> (Num -> Num)))

;;typeof
(test (typeof (parse '{+ 1 3})) (TNum))
(test (typeof (parse 1)) (TNum))
(test (typeof (parse '{fun {x : Num} : Num 5})) (TFun (TNum) (TNum)))
(test (typeof (parse '{{fun {x : Num} x} 1}))(TNum))
(test (typeof (parse '{fun {x : Num} x})) (TFun (TNum) (TNum)))
(test/exn (typeof (parse '{fun {x : Num} : {Num -> Num} 10})) "Type error in expression fun position 1: expected (Num -> Num) found Num")
(test/exn (typeof (parse '{1 2})) "Type error in expression app position 1: expected (T -> S) found Num")
(test/exn (typeof (parse '{{fun {x : Num} : Num {+ x x}} {fun {x : Num} : Num 5}})) "Type error in expression app position 2: expected Num found (Num -> Num)")
(test/exn (typeof (parse '{fun{x : Num}{+ x {fun{z : Num} 1}}})) "Type error in expression + position 2: expected Num found (Num -> Num)")
(test/exn (typeof (parse 'y)) "Type error: free identifier: y")

;; deBruijn
(test (deBruijn (num 3)) (num 3))
(test (deBruijn (parse '{with {x : Num 5}  {with  {y : Num  {+ x 1}} {+ y x}}}))
      (app (fun-db (app (fun-db (add (acc 0) (acc 1))) (add (acc 0) (num 1)))) (num 5)))
(test/exn (deBruijn (parse 'x)) "Free identifier: x")

;;compile
(test (compile (add (num 2) (num 1))) (list  (INT-CONST 1) (INT-CONST 2) (ADD)))
(test (compile (deBruijn (parse '{{fun {x : Num} : Num {+ x 10}} {+ 2 3}}))) (list (INT-CONST 3) (INT-CONST 2) (ADD) (CLOSURE (list (INT-CONST 10) (ACCESS 0) (ADD) (RETURN))) (APPLY)) )






;typecheck
(test (typecheck '3) 'Num)
(test (typecheck  '{fun {f : Num} : Num 10}) '(Num -> Num))
(test/exn (typecheck  '{+ 2 {fun {x : Num} : Num x}}) "Type error in expression + position 2: expected Num found (Num -> Num)")