#lang rosette

(provide expr-simple)
(require rosette/base/core/polymorphic)


(define (expr-simple expr printDebug)
  (match expr
    [v #:when (not (term? v)) v]
    [(expression (== &&) x y) #:when (unsat? (verify (assert y))) (begin (when printDebug (println "A*****************")) (expr-simple x printDebug))]
    [(expression (== &&) x y) #:when (unsat? (verify (assert (not y)))) (begin (when printDebug (println "B*****************")) #f)]
    [(expression (== &&) x y) (&& (expr-simple x printDebug) (expr-simple y printDebug))]
    [(expression (== ||) x y) #:when (unsat? (verify (assert y))) (begin (when printDebug (println "C*****************")) #t)]
    [(expression (== ||) x y) #:when (unsat? (verify (assert (not y)))) (begin (when printDebug (println "D*****************")) (expr-simple x printDebug))]
    [(expression (== ||) x y) (|| (expr-simple x printDebug) (expr-simple y printDebug))]
    [(expression (== ite) x y z) #:when (unsat? (verify (assert (equal? 0 (ite x y z))))) (begin (when printDebug (println "E*****************")) 0)]
    [(expression (== ite) x y z) #:when (unsat? (verify (assert x))) (begin (when printDebug (println "F*****************")) (expr-simple y printDebug))]
    [(expression (== ite) x y z) #:when (unsat? (verify (assert (not x)))) (begin (when printDebug (println "G*****************")) (expr-simple z printDebug))]
    [(expression (== ite) x y z) (ite (expr-simple x printDebug) (expr-simple y printDebug) (expr-simple z printDebug))]
    [(expression (== =) x y) (= (expr-simple x printDebug) (expr-simple y printDebug))]
    [(expression (== +) x y) (+ (expr-simple x printDebug) (expr-simple y printDebug))]
    [(expression (== -) x y) (- (expr-simple x printDebug) (expr-simple y printDebug))]
    [(expression (== !) x) (! (expr-simple x printDebug))]
    [v v]))

