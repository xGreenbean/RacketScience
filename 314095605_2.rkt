#lang pl 03

#|Question 1|#

;;building the tree was pretty straight forward.
;;only in the end i chaged <ROL> ::= <Reg> since,
;;by the instructions ROL only evaluates to Reg

#| BNF for the ROL language:
<ROL> ::= <Reg>
<RegE> ::= {Reg Bit-List}
||{And <RegE> <RegE>}
||{Or <RegE> <RegE>}
||{Shl <RegE>}
||{<Symbol>}
||{With <Symbol> <RegE> <RegE>}
||{<Boolean>}
||{Geq <RegE> <RegE>}
||{Maj <RegE>}
||{If <RegE> <RegE> <RegE>}
<Bits> ::=  <Bits> <Bit>| <Bit>
<Bit> ::= 1 | 0
|#

;; Defining two new types
(define-type BIT = (U 0 1))

(define-type Bit-List = (Listof BIT))

;; RegE abstract syntax trees

;;took about 10 minitues,
;;main difficulty was if, whether to put Boolean or RegE for the condition.

(define-type RegE
[Reg Bit-List]
[And RegE RegE]
[Or RegE RegE]
[Shl RegE]
[Id Symbol]
[With Symbol RegE RegE]
[Bool Boolean]
[Geq RegE RegE]
[Maj RegE]
[If RegE RegE RegE]) ;;maybe nonsense

;; Next is a technical function that converts (casts)
;; (any) list into a bit-list. We use it in parse-sexpr.
(: list->bit-list : (Listof Any) -> Bit-List)
;; to cast a list of bits as a bit-list
(define (list->bit-list lst)
(cond [(null? lst) null]
[(eq? (first lst) 1)(cons 1 (list->bit-list (rest lst)))]
[else (cons 0 (list->bit-list (rest lst)))]))


;;took about 20 minitues, main difficulty was to
;;understand what do we need 2 functions for (parse-sexpr and parse-expr-RegL
(: parse-sexpr : Sexpr -> RegE)
;; to convert the main s-expression into ROL
(define (parse-sexpr sexpr)
(match sexpr
[(list 'reg-len ‘= (number: n) args)
 			(if (> n 0)
       				(parse-sexpr-RegL args n)
    				(error 'parse-sexpr "Register length must be at least 1 ~s" sexpr) )]
		[else (error 'parse-sexpr "bad syntax in ~s" sexpr)]))


;;this was easy once i completed the previous function
;; took about 50 minitues, then the tests did not pass,
;; so took another 1hr to fix the code, mainly add constructor,
;; so that we return RES.

(: parse-sexpr-RegL : Sexpr Number -> RegE)
;; to convert s-expressions into RegEs
(define (parse-sexpr-RegL sexpr reg-len)
(match sexpr
[(list (and a (or 1 0)) ... ) 
		(if (= reg-len (length a))
			 (Reg (list->bit-list a))
		 	(error 'parse-sexpr-RegE "wrong number of bits in ~s" a)) ]
  [(list 'and list1 list2) (And (parse-sexpr-RegL list1 reg-len) (parse-sexpr-RegL list2 reg-len))]
  [(list 'or list1 list2) 	 (Or (parse-sexpr-RegL list1 reg-len) (parse-sexpr-RegL list2 reg-len))]
  [(list 'shl list) (Shl (parse-sexpr-RegL list reg-len))]
  [(list 'maj? list1 ) (Maj (parse-sexpr-RegL list1 reg-len))]
  [(list 'geq? list1 list2) (Geq (parse-sexpr-RegL list1 reg-len) (parse-sexpr-RegL list2 reg-len))]
  [(list 'if b expr1 expr2) (If (parse-sexpr-RegL b reg-len) (parse-sexpr-RegL expr1 reg-len) (parse-sexpr-RegL expr2 reg-len) )]
  ['true (Bool #t)]
  ['false (Bool #f)]
  [(symbol: id-name) (Id id-name)]  
  [(cons 'with args)
 	(match sexpr
     		[(list 'with (list (symbol: oldName) newName) body)
     			 (With oldName (parse-sexpr-RegL newName reg-len) (parse-sexpr-RegL body reg-len))]
   	        [else (error 'parse-sexpr-RegE "bad `with' syntax in ~s" sexpr)])]
[else (error 'parse-sexpr "bad syntax in ~s" sexpr)]))


;;straight forward
;; 1min
(: parse : String -> RegE)
;; parses a string containing a RegE expression to a RegE AST
(define (parse str)
(parse-sexpr (string->sexpr str)))

(define-type RES
[TF Boolean]
[RegV Bit-List])

;;this took about 20 mins, i copied most of it from the slides,
;; the extra time was to add so that it is applicable for our tests.
(: subst : RegE Symbol RegE -> RegE)
(define (subst expr from to)
    (cases expr
      [(Reg n) expr]
      [(Bool b) expr]
      [(Or l r) (Or (subst l from to) (subst r from to))]
      [(And l r) (And (subst l from to) (subst r from to))]
      [(Geq l r) (Geq (subst l from to) (subst r from to))]
      [(Maj ls) (Maj (subst ls from to))]
      [(Shl s) (Shl (subst s from to))]
      [(If expr1 expr2 expr3) (If (subst expr1 from to) (subst expr2 from to) (subst expr3 from to))]
      [(Id name) (if (eq? name from) to expr)]
      [(With bound-id named-expr bound-body)
       (With bound-id
             (subst named-expr from to)
             (if (eq? bound-id from)
               bound-body
               (subst bound-body from to)))]))
(: eval : RegE -> RES)
;; evaluates RegE expressions by reducing them to bit-lists
(define (eval expr)
(cases expr
  [(Reg r) (RegV r)]
  [(And l r) (reg-arith-op bit-and (eval l) (eval r))]
  [(Or l r) (reg-arith-op bit-or (eval l) (eval r))]
  [(Maj ls) (TF (majority? (RegV->bit-list (eval ls))))]
  [(Geq ls1 ls2) (TF (geq-bitlists? (RegV->bit-list (eval ls1)) (RegV->bit-list (eval ls2))))]
  [(Bool b) (TF b)]
  [(If expr1 expr2 expr3) (if (cases (eval expr1)
                                [(TF b) b]
                                [else #t]) (eval expr2) (eval expr3))]
  [(Shl ls)  (RegV (shift-left (RegV->bit-list (eval ls))))]
  [(With bound-id named-expr bound-body)
       (eval (subst bound-body
                    bound-id
                     (cases (eval named-expr)
                     [(RegV reg) (Reg reg)]
                     [(TF b) (Bool b)])))]
  [(Id name) (error 'eval "free identifier: ~s" name)]))
  


;; Defining functions for dealing with arithmetic operations
;; on the above types
(: bit-and : BIT BIT -> BIT) ;; Arithmetic and
(define(bit-and a b)
(cond
  [(eq? a 1) (if (eq? b 1) 1 0)]
  [else 0]))


(: bit-or : BIT BIT -> BIT) ;; Aithmetic or
(define(bit-or a b)
(cond
  [(eq? a 1) 1]
  [(eq? b 1) 1]
  [else 0]))

(: reg-arith-op : (BIT BIT -> BIT) RES RES -> RES)
;; Consumes two registers and some binary bit operation 'op',
;; and returns the register obtained by applying op on the
;; i'th bit of both registers for all i.
(define(reg-arith-op op reg1 reg2)
  (: bit-arith-op : Bit-List Bit-List -> Bit-List)
  ;; Consumes two bit-lists and uses the binary bit operation 'op'.
  ;; It returns the bit-list obtained by applying op on the
  ;; i'th bit of both registers for all i.
  (define(bit-arith-op bl1 bl2)
    (map op bl1 bl2))
  (RegV (bit-arith-op (RegV->bit-list reg1) (RegV->bit-list reg2))))
  (: majority? : Bit-List -> Boolean)
  ;; Consumes a list of bits and checks whether the
  ;; number of 1's are at least as the number of 0's.
  (define(majority? bl)
    (if (>= (foldl + 0 bl) (/ (length bl) 2)) #t #f))

  (: geq-bitlists? : Bit-List Bit-List -> Boolean)
  ;; Consumes two bit-lists and compares them. It returns true if the
  ;; first bit-list is larger or equal to the second.
  (define (geq-bitlists? bl1 bl2)
    (cond
      ;;we know all lists are of same length
   [(and (null? bl1) (null? bl2)) #t]
   [(eq? (first bl1) 1) (if (eq? (first bl2) 1) (geq-bitlists? (rest bl1) (rest bl2)) #t)]
   [(eq? (first bl2) 1)  #f]
   [else (geq-bitlists? (rest bl1) (rest bl2))]))


  ;; Shifts left a list of bits (once)
  (: shift-left : Bit-List -> Bit-List)
  (define(shift-left bl)
    (append (rest bl) (list (first  bl))))
  (: RegV->bit-list : RES -> Bit-List)
  ;; extract a bit-list from RES type
   (define (RegV->bit-list res)
     (cases res
     [(RegV bl) bl]
     [(TF b) (error RegV->bit-list "run must return a bit-list ~s" b)]))

(: run : String -> Bit-List)
(define (run str)
  (RegV->bit-list (eval(parse str))))

;; tests
(test (run "{ reg-len = 4 {1 0 0 0}}") => '(1 0 0 0))
(test (run "{ reg-len = 4 {shl {1 0 0 0}}}") => '(0 0 0 1))
(test (run "{ reg-len = 4
{and {shl {1 0 1 0}}{shl {1 0 1 0}}}}") =>
'(0 1 0 1))
;; tests
(test (run "{ reg-len = 4 {1 0 0 0}}") => '(1 0 0 0))
(test (run "{ reg-len = 4 {shl {1 0 0 0}}}") => '(0 0 0 1))
(test (run "{ reg-len = 4
{and {shl {1 0 1 0}}{shl {1 0 1 0}}}}") =>
'(0 1 0 1))
(test (run "{ reg-len = 4
{ or {and {shl {1 0 1 0}} {shl {1 0 0 1}}}
{1 0 1 0}}}") => '(1 0 1 1))
(test (run "{ reg-len = 2
{ or {and {shl {1 0}} {1 0}} {1 0}}}") =>
'(1 0))
(test (run "{ reg-len = 4 {with {x {1 1 1 1}} {shl y}}}")
=error> "free identifier: y")
(test (run "{ reg-len = 2
{ with {x { or {and {shl {1 0}}
{1 0}}
{1 0}}}
{shl x}}}") => '(0 1))
(test (run "{ reg-len = 4 {or {1 1 1 1} {0 1 1}}}") =error>
"wrong number of bits in (0 1 1)")
(test (run "{ reg-len = 0 {}}") =error>
"Register length must be at least 1")
(test (run "{ reg-len = 3
{if {geq? {1 0 1} {1 1 1}}
{0 0 1}
{1 1 0}}}") => '(1 1 0))
(test (run "{ reg-len = 4
{if {maj? {0 0 1 1}}
{shl {1 0 1 1}}
{1 1 0 1}}}") => '(0 1 1 1))
(test (run "{ reg-len = 4
{if false {shl {1 0 1 1}} {1 1 0 1}}}") =>
'(1 1 0 1))
(test (run "{ reg-len = 4
{if true {shl {1 0 1 1}} {1 1 0 1}}}") =>
'(0 1 1 1))
(test (run "{ reg-len = 0
{if false {shl {1 0 1 1}} {1 1 0 1}}}") =error>
"Register length must be at least 1")
(test (run "{ reg-len = a
{if false {shl {1 0 1 1}} {1 1 0 1}}}") =error>
"parse-sexpr: bad syntax in (reg-len = a (if false (shl (1 0 1 1)) (1 1 0 1)")


(test (run "{ reg-len = 4 {if true {shl {1 0 1 1}} {1 1 0 1}}}") =>
      '(0 1 1 1))
(test (run "{ reg-len = salut {with {x {1 1 1 1}} {shl y}}}")=error>
      "parse-sexpr: bad syntax in (reg-len = salut (with (x (1 1 1 1)) (shl y)))")
(test (run "{ reg-len = 4 {with {x buuuug bug}}}")=error>
      "parse-sexpr-RegE: bad `with' syntax in (with (x buuuug bug))")
(test (run "{ reg-len = 2 {if {maj? {0 0}}{0 1} {0 1}}}") =>
      '(0 1))
(test (run "{ reg-len = 2 {if {geq? {0 0}{1 1}}{0 1} {0 1}}}") =>
      '(0 1))
(test (run "{ reg-len = 2 {buuug}}")=error>
      "parse-sexpr: bad syntax in (buuug)")
(test (run "{ reg-len = 2 {maj? {0 0}}}")=error>
      "#<procedure:RegV->bit-list>: run must return a bit-list #f")
(test (run "{ reg-len = 2 {with {x { or {and {or {1 0} {1 0}}{1 0}}{1 0}}}{maj? x}}}")=error>
      "#<procedure:RegV->bit-list>: run must return a bit-list #t")
(test (run "{ reg-len = 2 {with {x { or {and {or {1 0} {1 0}}{1 0}}{1 0}}}{or {0 1} {0 1}}}}") =>
      '(0 1))
(test (run "{ reg-len = 2 {with {x { or {and {or {1 0} {1 0}}{1 0}}{1 0}}}{and {0 1} {0 1}}}}") =>
      '(0 1))
(test (run "{ reg-len = 2 {with {x { or {and {or {1 0} {1 0}}{1 0}}{1 0}}}{bool buug}}}")=error>
      "parse-sexpr: bad syntax in (bool buug)")
(test (run "{ reg-len = 2 {with {x { or {and {or {1 0} {1 0}}{1 0}}{1 0}}}{geq? {0 0}{1 1}}}}")=error>
      "#<procedure:RegV->bit-list>: run must return a bit-list #f")
(test (run "{ reg-len = 2 {with {x { or {and {or {1 0} {1 0}}{1 0}}{1 0}}}{if false {1 0} {0 1}}}}")=>
      '(0 1))
(test (run "{ reg-len = 2 {with {x { or {and {or {1 0} {1 0}}{1 0}}{1 0}}}{with {x { or {and {or {1 0} {1 0}}{1 0}}{1 0}}}{if false {1 0} {0 1}}}}}")=>
      '(0 1))
(test (run "{ reg-len = 2 {with {x { or {and {or {1 0} {1 0}}{1 0}}{1 0}}}{with {x {and {and {and {0 0} {0 0}}{1 0}}{1 0}}}{if true {1 0} {1 1}}}}}")=>
      '(1 0))
(test (run "{ reg-len = 2 {if {geq? {0 0}{1 1}}{0 1} {0 1}}}") =>
      '(0 1))
(test (run "{ reg-len = 2 {if {geq? {1 1}{0 0}}{0 1} {0 1}}}") =>
      '(0 1))
(test (run "{ reg-len = 2 {if {geq? {1 0}{0 1}}{0 1} {0 1}}}") =>
      '(0 1))
(test (run "{ reg-len = 1 {if {geq? {1}{1}}{1} {1}}}") =>
      '(1))
(test (run "{ reg-len = 1 {if {geq? {0}{0}}{0} {0}}}") =>
      '(0))
;;test i added for full coverage, also modified geq? because full coverage was not possible there,
;since bit-list all troughout must be of same size
(test (run "{ reg-len = 1 {if {0} {0} {1}}}") =>
      '(0))
(test (run "{ reg-len = 2 {if {with {x true} x} {0 0} {1 1}}}")=>
      '(0 0))
(test (run "{ reg-len = 2 {if {with {x true} {with {y x} y}} {0 0} {1 1}}}")=>
      '(0 0))