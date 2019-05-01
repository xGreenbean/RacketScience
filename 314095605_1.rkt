#lang pl 02
#|

#Question 1#
;;took about one hour including going trough the lecture notes.
;;main difficulties, figuring out whether my "grammer" has ambigutity
a)

<num> ::= <DIGIT> | (1)
          <DIGIT> <num> | (2)
          {string-length <Str>} (3)

<DIGIT> ::= 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 (4)

<Char*> ::= #\v Char*| (5)
            #\v        (6)

<Str> ::= {string Char*}(7)
         | <const Char*> (8)
         | {string-append <Str> <String*>}(9)
         | {string-insert <Str> <Str> #\v <num>}(10)
         | {number->string <num>}(11)

<String *> ::= <Str> <String *>| (12)
               <Str>]] (13)

<SE> ::= #\v |(14)
          <num> |(15)
          <Str> (16)

<const Char*> ::= lambda | (17)
                  " <num> " (18)

#Question 1)b)#
;;operations: , string-length, , string-insert, string
;; string-append number->string

;;this Question took about 35 grueling minitues, main difficulty is organizing
;;every thing so that i get a good grade.

$first expression$

<SE> -> <num> (15)

<num> -> {string-length <Str>} (3)

{string-length <Str>} -> {string-length {string-insert <Str> <Str> #\v <num>}} (10)

{string-length {string-insert <Str> <Str> #\v <num>}} -> {string-length {string-insert<const Char*> <const Char*> #\v <num>}} (8)

{string-length {string-insert <const Char*> <const Char*> #\v <num>}} -> {string-length {string-insert lambda lambda #\v <DIGIT>}} (2) and (17)

{string-length {string-insert lambda lambda #\v <DIGIT>}} -> {string-length {string-insert lambda lambda #\v 5}} (4)

{string-length {string-insert lambda lambda #\v 5}} -> {string-length "v5"}

{string-length "v5"} -> 2



$second expression$

<SE> -> <Str> (16)

<Str> -> {number->string <num>} (11)

{number->string <num>} ->  {number->string <DIGIT>} (1)

{number->string <DIGIT>} -> {number->string 9}

{number->string 9} -> "9"


$third expression$


<SE> -> <Str>

<Str> -> {string-append <Str> <String *>} (9)

{string-append <Str> <String *>} -> {string-append <Str> <Str>} (13)

{string-append <Str> <Str>}  -> {string-append <const char *> <onst char *>} (8)

{string-append lambda lambda} -> ""


#Question 2a#


2)a)we have an issue of ambiguity {* {+ {set 1} {set 2}} get}
    can evaluate to both {* {+ 1 {set 2}} get} -> 6
    or to {* {+ {set 1} 2} get} -> 3
    because we do not know what would derive first and therfore what will be
    drawn from memory for the multiplication
 my fix:
#|short version: decide an order of derivation|#

;; took about 45 minitues to write this answer
;; main difficulty checking that i have not ambiguity and all required rules apply

#Question 2b#
2)b)
#|

<MAE> ::= {seq <sAE> <eAE>} | {seq <nAE>} (1)

<AE> ::=
            | { + <x> <x> } (2)
            | { - <x> <x> }
            | { * <x> <x> }
            | { / <x> <x> }

<x> ::= <num> | get (3)

<nAE> ::=
            | { + <num>  <num>  } (4)
            | { - <num> <num>   }
            | { * <num>  <num>  }
            | { / <num>  <num>  }

<mAE> = {set <AE>}| {set <AE>} <mAE> (5)

<sAE> = {set <nAE>}| {set <nAE>} <mAE> (6)

<eAE> ::=   | { + <get>  <num>  } (7)
            | { - <get> <num>   }
            | { * <get>  <num>  }
            | { / <get>  <num>  }
            | { + <num>  <get>  }
            | { - <num> <get>   }
            | { * <num>  <get>  }
            | { / <num>  <get>  }
            | { + <get> <get>  }
            | { - <get> <get>   }
            | { * <get> <get>  }
            | { / <get> <get>  }

|#

#Question 2b#

2)b)

;;took alot of time to write these trees, about 20 minitues of my life.
$first sequance$

<MAE> -> {seq <sAE> <eAE>} (1)

{seq <sAE> <eAE>} -> {seq <sAE> { + <get>  <num>  }} (7)

{seq <sAE> { + <get>  <num>  }} ->  {seq {set <nAE>} { + <get>  <num>  }} (6)

{seq {set <nAE>} { + <get>  <num>  }} -> {seq {set { / <num>  <num>  } } { + <get>  <num>  }} (4)

{seq {set { / <num>  <num>  } } { + <get>  <num>  }}  -> {seq {set { / 3  1  } } { + <get>  4  }}

{seq {set { / 3  1  } } { + <get>  4  }} -> {seq {set 3 } { + <get>  4  }}

{seq {set 3 } { + <get>  4  }} -> {seq { + 3  4  }}

{seq { + 3  4  }} - > 7

$second sequance$

<MAE> -> {seq <sAE> <eAE>} (1)

{seq <sAE> <eAE>} -> {seq <sAE> { + <get>  <num>  }} (7)

{seq <sAE> { + <get>  <num>  }} ->  {seq {set <nAE>} { + <get>  <num>  }} (6)

{seq {set <nAE>} { + <get>  <num>  }} -> {seq {set { / <num>  <num>  } } { + <get>  <num>  }} (4)

{seq {set { * <num>  <num>  } } { - <get>  <num>  }}  -> {seq {set { * 0  9  } } { - <get>  5  }}

{seq {set { * 0  9  } } { - <get>  5  }} -> {seq {set 0 } { - <get>  5  }}

{seq {set 0 } { + <get>  5  }} -> {seq { - 0  5  }}

{seq { - 0  5  }} - > -5

$third sequance$

<MAE> -> {seq <sAE> <eAE>} (1)

{seq <sAE> <eAE>} -> {seq <sAE> { * <get>  <num>  }} (7)

{seq <sAE> { * <get>  <num>  }} ->  {seq {set <nAE>} { * <get>  <num>  }} (6)

{seq {set <nAE>} { * <get>  <num>  }} -> {seq {set { * <num>  <num>  } } { * <get>  <num>  }} (4)

{seq {set { * <num>  <num>  } } { * <get>  <num>  }}  -> {seq {set { * 6  0  } } { * <get>  5  }}

{seq {set { * 6  0  } } { * <get>  5  }} -> {seq {set 0 } { * <get>  5  }}

{seq {set 0 } { * <get>  5  }} -> {seq { * 0  5  }}

{seq { * 0  5  }} - > 0

|#

#|Question 3|#
;;function from natural to natural
;; basicly squares the input
(: square : Natural -> Natural)
(define (square x)
(* x x))
;; input natural number (current value) natural number (combined values)
;; a combiner function recieves the current value (x) and the combined values so far y
;; square the current value and adds to y
(: combiner : Natural Natural -> Natural)
(define (combiner x y)
(+ (square x) y))

;;input list of natural numbers , output a natural number who is the sum of squares of the input.
;; using foldl to caculate the sum of squares with out combiner function.
(: sum-of-squares : (Listof Natural)  -> Natural)
(define (sum-of-squares list)
 ;;value 0 since it 0 + something is something
(foldl combiner 0 list))


(test (sum-of-squares '(1 2 3)) => 14)

#|Question 4a|#
;; this question took about 40 minitues, once i tought c language like it became much clearer.
;; (funcion pointers)

;;input list of numbers (the coefficients of the polinomial)
;;output a function from number to number, input is x value to asses the polynomial at x.
;; out put is value of the polynomial for x = input
(: createPolynomial : (Listof Number) -> (Number -> Number))
(define (createPolynomial coeffs)
 (: poly : (Listof Number) Number Integer Number ->
Number)
 (define (poly argsL x power accum)
  ;; if our list is empty we return the accumelator (which has the value of the polynomial)
 (if (null? argsL)
     accum
     ;; else call poly with rest of the list same x value to evaluate and cacualate the current value and add to accum.
     (poly (rest argsL) x (+ power 1) (+ (* (expt x power) (first argsL)) accum)))
   )
 (: polyX : Number -> Number)
 (define (polyX x)
   ;;call poly with right parameters. power of zero and accum 0
   (poly coeffs x 0 0))
  ;;return polyx
   polyX)

(define p2345 (createPolynomial '(2 3 4 5)))
(test (p2345 0) =>
 (+ (* 2 (expt 0 0)) (* 3 (expt 0 1)) (* 4 (expt 0 2)) (* 5
(expt 0 3))))
(test (p2345 4) =>
 (+ (* 2 (expt 4 0)) (* 3 (expt 4 1)) (* 4 (expt 4 2)) (* 5
(expt 4 3))))
(test (p2345 11) => (+ (* 2 (expt 11 0)) (* 3 (expt 11 1)) (* 4
(expt 11 2)) (* 5 (expt 11 3))))
(define p536 (createPolynomial '(5 3 6)))
(test (p536 11) => (+ (* 5 (expt 11 0)) (* 3 (expt 11 1)) (* 6
(expt 11 2))))
(define p_0 (createPolynomial '()))
(test (p_0 4) => 0)

#|Question 4b|#

#|
i)
;;pretty straight forward
;;no difficulties
 The grammar:
 <PLANG> ::= {{poly <AEs> }{<AEs> }}
 <AEs> ::= <AE> | <AE> <AEs>
 <AE> ::= same as described in class
 |#

#|ii)|#
;;this question took 3 hours
;; syntax is a **** and im still not sure why i cant use cond inside match.
;; so took me a while to think about matching an empty list
(define-type PLANG
 [Poly (Listof AE) (Listof AE)])

;;this code was provided for us,
;;therefore i did not test it.
 (define-type AE
 [Num Number]
 [Add AE AE]
 [Sub AE AE]
 [Mul AE AE]
 [Div AE AE])

 (: parse-sexpr : Sexpr -> AE)
 ;; to convert s-expressions into AEs
 (define (parse-sexpr sexpr)
 (match sexpr
 [(number: n) (Num n)]
 [(list '+ lhs rhs) (Add (parse-sexpr lhs)
 (parse-sexpr rhs))]
 [(list '- lhs rhs) (Sub (parse-sexpr lhs)
 (parse-sexpr rhs))]
 [(list '* lhs rhs) (Mul (parse-sexpr lhs)
 (parse-sexpr rhs))]
 [(list '/ lhs rhs) (Div (parse-sexpr lhs)
 (parse-sexpr rhs))]
[else (error 'parse-sexpr "bad syntax in ~s"
 sexpr)]))


 (: parse : String -> PLANG)
 ;; parses a string containing a PLANG expressionto a PLANG AST
 (define (parse str)
   (let ([code (string->sexpr str)])
 (match code
   ;; if pattern is poly followed by empty list we throw error
   [(list (cons 'poly '()) (list tai ...)) (error 'parse "at least one coefficient is
 required in ~s" code)]
      ;; if pattern is ((poly $non empty list$) $empty list$) we throw error
   [(list (cons 'poly hea) '()) (error 'parse "at least one point is
 required in ~s" code)]
   ;;otherwise we assume current syntax and use map to parse each of the list "AEs"
   [(list (cons 'poly hea) (list tai ...)) (Poly (map parse-sexpr hea) (map parse-sexpr tai))]
   [else (error 'parse "bad syntax in ~s"
                code)])))


(test (parse "{{poly 1 2 3} {1 2 3}}")
 => (Poly (list (Num 1) (Num 2) (Num 3))
 (list (Num 1) (Num 2) (Num 3))))
(test (parse "{{poly } {1 2} }") 
 =error> "parse: at least one coefficient is
 required in ((poly) (1 2))")
(test (parse "{{poly 1 2} {} }")
 =error> "parse: at least one point is
 required in ((poly 1 2) ())")
(test (parse "{{pct 1 2} {} }")
 =error> "parse: bad syntax in ((pct 1 2) ())")

#|Question 4b|#
;; evaluates AE expressions to numbers
;; this question was actually pretty easy 20 minitues
(: eval : AE ->  Number )
(define (eval expr)
(cases expr
[(Num n) n]
[(Add l r) (+ (eval l) (eval r))]
[(Sub l r) (- (eval l) (eval r))]
[(Mul l r) (* (eval l) (eval r))]
[(Div l r) (/ (eval l) (eval r))]))

(: eval-poly : PLANG -> (Listof Number) )
(define (eval-poly p-expr)
 (cases  p-expr
   ;; if we have Poly type of variant
   ;; we create polynomial from evaluating all "AES" in the first list
   ;; then we use the returned function to caculate value at point (which are parsed from AEs with map and eval)
   
   [(Poly coeffs points) (map (createPolynomial (map eval coeffs)) (map eval points))]))

(: run : String -> (Listof Number))
;; evaluate a FLANG program contained in a string
(define (run str)
(eval-poly (parse str)))


(test (run "{{poly 1 2 3} {1 2 3}}")
=> '(6 17 34))
(test (run "{{poly 4 2 7} {1 4 9}}")
=> '(13 124 589))
(test (run "{{poly 1 2 3} {1 2 3}}")
=> '(6 17 34))
(test (run "{{poly 4/5 } {1/2 2/3 3}}")
=> '(4/5 4/5 4/5))
(test (run "{{poly 2 3} {4}}")
=> '(14))
(test (run "{{poly 1 1 0} {-1 3 3}}")
=> '(0 4 4))