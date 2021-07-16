#lang rosette

(provide expr-simple)
(require rosette/base/core/polymorphic)


(define (expr-simple expr)
  (match expr
    [v #:when (not (term? v)) v]
    [(expression (== &&) x y) #:when (unsat? (verify (assert y))) (begin (println "A*****************") (expr-simple x))]
    [(expression (== &&) x y) #:when (unsat? (verify (assert (not y)))) (begin (println "B*****************") #f)]
    [(expression (== &&) x y) (&& (expr-simple x) (expr-simple y))]
    [(expression (== ||) x y) #:when (unsat? (verify (assert y))) (begin (println "C*****************") #t)]
    [(expression (== ||) x y) #:when (unsat? (verify (assert (not y)))) (begin (println "D*****************") (expr-simple x))]
    [(expression (== ||) x y) (|| (expr-simple x) (expr-simple y))]
    [(expression (== ite) x y z) #:when (unsat? (verify (assert (equal? 0 (ite x y z))))) (begin (println "E*****************") 0)]
    [(expression (== ite) x y z) #:when (unsat? (verify (assert x))) (begin (println "F*****************") (expr-simple y))]
    [(expression (== ite) x y z) #:when (unsat? (verify (assert (not x)))) (begin (println "G*****************") (expr-simple z))]
    [(expression (== ite) x y z) (ite (expr-simple x) (expr-simple y) (expr-simple z))]
    [(expression (== =) x y) (= (expr-simple x) (expr-simple y))]
    [(expression (== +) x y) (+ (expr-simple x) (expr-simple y))]
    [(expression (== -) x y) (- (expr-simple x) (expr-simple y))]
    [(expression (== !) x) (! (expr-simple x))]
    [v v]))

