#lang pl
;; writing code in Racket is like digging holes with a toothbrush,
;; possible but not my first choice.




#|Question 1, took about half hour, wasnt hard.|#


;; Input 5 Strings
;; Output first String to have prefix "pl" or #f
;; how: first check that string has atleast 2 chars,
;; then see if string has prefix "pl" using string-ref.
;; we check strings by order so that first string that has the prefix will be returend
(: plPrefixContained : String String String String String -> (U String Boolean))

(define (plPrefixContained s1 s2 s3 s4 s5)
  (cond
    [(and (>= (string-length s1) 2) (and (eq? (string-ref s1 0) #\p) (eq? (string-ref s1 1) #\l))) s1]
    [(and (>= (string-length s2) 2) (and (eq? (string-ref s2 0) #\p) (eq? (string-ref s2 1) #\l))) s2]
    [(and (>= (string-length s3) 2) (and (eq? (string-ref s3 0) #\p) (eq? (string-ref s3 1) #\l))) s3]
    [(and (>= (string-length s4) 2) (and (eq? (string-ref s4 0) #\p) (eq? (string-ref s4 1) #\l))) s4]
    [(and (>= (string-length s5) 2) (and (eq? (string-ref s5 0) #\p) (eq? (string-ref s5 1) #\l))) s5]
    [else #f]))

(test (plPrefixContained "yypl" "opl" "lpTT" "lpl" "lol") => false)
(test (plPrefixContained "yypl" "opl" "lpTT" "pl" "lol") => "pl")
(test (plPrefixContained "a" "b" "c" "c" "p") => false)
(test (plPrefixContained "pppp" "pppp1" "ppppl" "p1" "pl") => "pl")
(test (plPrefixContained "stupid" "" "lol" "" "plSADASDWQ123") => "plSADASDWQ123")
(test (plPrefixContained "pl" "pl1" "pl2" "pl3" "pl4") => "pl")
(test (plPrefixContained "Pl" "plqw" "pl2" "pl3" "pl4") => "plqw")
(test (plPrefixContained "pL" "PL" "plPPP" "pl3" "pl4") => "plPPP")




#|Question 2 took about an hour, mainly syntax issues|#
#|Part A|#


(: longestStringHelper : (Listof Any) (U String Boolean) -> (U String Boolean))

;; Input List of any type, And a String or Boolean.
;; Output String or Boolean.
;; helper fuction for longestString,
;; if first string in list is longer then ret, continue recursively
;; with first and rest of the list, otherwise continue recursively with ret and rest of list.
(define (longestStringHelper list ret)
  (cond [(null? list) ret]
        [(not (string? (first list))) (longestStringHelper (rest list) ret)]
        [(not (string? ret)) (longestStringHelper (rest list) (first list))]
        [(> (string-length (first list)) (string-length ret)) (longestStringHelper (rest list) (first list))]
        [else (longestStringHelper (rest list) ret)]))




(: longestString : (Listof Any) -> (U Boolean String))

;; Input: list
;; Output Boolean or String
;; returns the logenst string in the list or #f is dosent exist.
;; uses longestStringHelper, for tail recursion as requested.
(define (longestString list)
  (longestStringHelper list #f))

(test (longestString '(34 uuu 90)) => false)
(test (longestString '(uu 56 oooo "r" "rRR" "b" "TTT")) => "rRR")
(test (longestString '(uu 56 oooo "r" "ABCDEFS" "b" "ABCDEFSsS")) => "ABCDEFSsS")




#|Part B took about one hour, syntax again.|#


(: shortestStringHelper : (Listof Any) (U String Boolean) -> (U String Boolean))
;;same as longestStringHeleper if longestStringHeleper works this works.
(define (shortestStringHelper list ret)
  (cond [(null? list) ret]
        [(not (string? (first list))) (shortestStringHelper (rest list) ret)]
        [(not (string? ret)) (shortestStringHelper (rest list) (first list))]
        [(< (string-length (first list)) (string-length ret)) (shortestStringHelper (rest list) (first list))]
        [else (shortestStringHelper (rest list) ret)]))




(: shortestString : (Listof Any) -> (U String Boolean))
;;same as longestString if longestString works this works.
(define (shortestString list)
  (shortestStringHelper list #f))

(test (shortestString '(34 uuu 90)) => false)
(test (shortestString '(uu 56 oooo "r" "rRR" "TTT" "TTTT" "r")) => "r")





;; Input: A list of any type
;; Output: null or list of 2 strings
;; Helper function for short&long-lists, deals with a single list.
;; check for the shortest string in the list, if exists checks for longest and returns a list of both.
;; otherwise returns null.
(: short&long-listsHelper : (Listof Any) -> (Listof (U Boolean String)))
(define (short&long-listsHelper ls)
   (cond [(shortestString ls) (list short (longestString ls))]
         [else null]))


#|Finally the function we came for|#


(: short&long-lists : (Listof (Listof Any)) -> (Listof (Listof (U Boolean String))))
;;input: list of lists of any type
;;output: list of list of String or Boolean (should'nt return Boolean, but because
;; how i implemented the recursion in previous functions i have to include it as well).
;; for every list in the list returns the shortest and logenst string or null.
;; uses the helper function abouve which is documented.
(define (short&long-lists ls)
  (map short&long-listsHelper ls))

(test (short&long-lists '((any "Benny" 10 "OP" 8) (any Benny OP (2 3)))) => '(("OP" "Benny") ()))
(test (short&long-lists '(("2 5 5" 1 "5gg" L) (v gggg "f") ())) => '(("5gg" "2 5 5") ("f" "f") ()))
(test (short&long-lists '(("2 5 5" 1 "5ggggggggg" L) ("g" gggg "f") ())) => '(( "2 5 5" "5ggggggggg") ("g" "g") ()))





#|Questions 3|#
;; took about 2 hours, wasted alot of time trying to find,
;; where defining type were disccused in the course.
;; Thinking wise i had no clue, after friend showed me where to look in the
;; lecture notes and gave me the linked list annotaion wasn't hard to put togheter.


;; Represents a stack with key and value
;; new type, with 2 variants: EmptyKS and PUSH
;; Push is like a linked list, has a key, value and pointer to next.
;; next can be "null" if its EmptyKS.
(define-type KeyStack
  [EmptyKS]
  [Push Symbol String KeyStack])




(: search-stack : Symbol KeyStack -> (U String Boolean))
;; Input: Symbol and KeyStack
;; Output: String or Boolean
;; searches for the Symbol recursively, similar to a linked list.
;; if Symbol is found return its string
;; if we reach the end (EmptyKS) return false.
(define (search-stack key stack)
  (cases stack
    [(Push sym str stacknext)(cond
                                    [(eq? key sym) str]
                                    [else (search-stack key stacknext)])]
    [EmptyKS #f]))



;; pops stack
;; Input: KeyStack
;; Output: Boolean or KeyStack
;; checks if stack is Push, if so return its next.
;; if stack is empty return false
(: pop-stack : KeyStack -> (U KeyStack Boolean))
(define (pop-stack stack)
  (cases stack
    [(Push sym str stacknext) stacknext]
    [EmptyKS #f]))

(test (EmptyKS) => (EmptyKS)) (test (Push 'b "B" (Push 'a "A" (EmptyKS))) => (Push 'b "B" (Push 'a "A" (EmptyKS))))
(test (Push 'a "AAA" (Push 'b "B" (Push 'a "A" (EmptyKS)))) => (Push 'a "AAA" (Push 'b "B" (Push 'a "A" (EmptyKS)))))
(test (search-stack 'a (Push 'a "AAA" (Push 'b "B" (Push 'a "A" (EmptyKS))))) => "AAA")
(test (search-stack 'c (Push 'a "AAA" (Push 'b "B" (Push 'a "A" (EmptyKS))))) => #f)
(test (pop-stack (Push 'a "AAA" (Push 'b "B" (Push 'a "A" (EmptyKS))))) => (Push 'b "B" (Push 'a "A" (EmptyKS))))
(test (pop-stack (EmptyKS)) => #f)




#|Question 4|#
;;took about 1 hour, the Racket documentation can be improved.
;;went trough Barzilay course and found the documented function. so that helped.


(: is-odd? : Natural -> Boolean)
;; input : Natural Number Output: boolean
;; true for odd and false for even.
;; if x is odd then x - 1 is even.. and so on.
;; so when we reach 0 for odd number it will be in iseven? and return true
;; and for even number we will reach 0 in isodd? and return false.
(define (is-odd? x)
(if (zero? x)
false
(is-even? (- x 1))))





(: is-even? : Natural -> Boolean)
;; input : Natural Number Output: boolean
;; true for even and false for odd.
;; if x is even then x - 1 is odd.. and so on.
;; so when we reach 0 for odd number it will be in isodd? and return false
;; and for even number we will reach 0 in iseven? and return true.
(define (is-even? x)
(if (zero? x)
true
(is-odd? (- x 1))))

;; tests --- is-odd?/is-even?
(test (not (is-odd? 12)))
(test (is-even? 12))
(test (not (is-odd? 0)))
(test (is-even? 0))
(test (is-odd? 1))
(test (not (is-even? 1)))





(: every? : (All (A) (A -> Boolean) (Listof A) -> Boolean))
;; Input:: list of type A and a function from type A to Boolean
;; Output: Boolean
;; Returns false if any element of lst fails the given pred,
;; true if all pass pred.
(define (every? pred lst)
(or (null? lst)
(and (pred (first lst))
(every? pred (rest lst)))))




;; An example for the usefulness of this polymorphic function
(: all-even? : (Listof Natural) -> Boolean)
;; input list output: boolean
;; checks with function iseven?
;;if all elements of list are even if so return true otherwise false.
(define (all-even? lst)
(every? is-even? lst))

;; tests
(test (all-even? null))
(test (all-even? (list 0)))
(test (all-even? (list 2 4 6 8)))
(test (not (all-even? (list 1 3 5 7))))
(test (not (all-even? (list 1))))
(test (not (all-even? (list 2 4 1 6))))





(: every2? : (All (A B) (A -> Boolean) (B -> Boolean) (Listof A) (Listof B) -> Boolean))
;; input: function and list of type A, fuction and list of type B
;; output: boolean
;; if both lists are empty return true, otherwise check
;; that every element of first list is true for first function,
;; and every element of second list is true for second function.
;; if so return true otherwise false.
(define (every2? pred1 pred2 lst1 lst2)
(or (null? lst1) ;; both lists assumed to be of same length
(and (pred1 (first lst1))
(pred2 (first lst2))
(every2? pred1 pred2 (rest lst1) (rest lst2)))))