#lang rosette

(provide expr-simple)
(require rosette/base/core/polymorphic)

(define USE_SYMOPT #f)


(define (expr-simple expr printDebug)
  (if USE_SYMOPT
    (match expr
      [v #:when (not (term? v)) v]
      [v #:when (&& (boolean? v) (unsat? (verify (assert v)))) (begin (when printDebug (println "K*****************")) (when printDebug (println expr)) #t)]
      [v #:when (&& (boolean? v) (unsat? (verify (assert (not v))))) (begin (when printDebug (println "L*****************")) #f)]
      ;[v #:when (&& (boolean? v) (unsat? (verify (assert (equal? () v))))) (begin (when printDebug (println "L*****************")) #f)]
  
      [(expression (== &&) x y) #:when (unsat? (verify (assert (|| (not x) y)))) (begin (when printDebug (println "A*****************")) (expr-simple x printDebug))]
      [(expression (== &&) x y) #:when (unsat? (verify (assert (|| (not y) x)))) (begin (when printDebug (println "B*****************")) (expr-simple y printDebug))]
      [(expression (== &&) x y) (&& (expr-simple x printDebug) (expr-simple y printDebug))]
  
      [(expression (== ||) x y) #:when (unsat? (verify (assert (|| (not x) y)))) (begin (when printDebug (println "C*****************")) (expr-simple y printDebug))]
      [(expression (== ||) x y) #:when (unsat? (verify (assert (|| (not y) x)))) (begin (when printDebug (println "D*****************")) (expr-simple x printDebug))]
      [(expression (== ||) x y) (|| (expr-simple x printDebug) (expr-simple y printDebug))]
  
      [(expression (== ite) x y z) #:when (unsat? (verify (assert (equal? 0 (ite x y z))))) (begin (when printDebug (println "E*****************")) 0)]
      [(expression (== ite) x y z) #:when (unsat? (verify (assert x))) (begin (when printDebug (println "F*****************")) (expr-simple y printDebug))]
      [(expression (== ite) x y z) #:when (unsat? (verify (assert (not x)))) (begin (when printDebug (println "G*****************")) (expr-simple z printDebug))]
      [(expression (== ite) x y z) (ite (expr-simple x printDebug) (expr-simple y printDebug) (expr-simple z printDebug))]
      [(expression (== ite*) gvs ...)
        (begin
          (when printDebug (println "J****************"))
          (define gvs-new 
            (filter (lambda (gv) (not (eqv? #f (car gv))))
              (map (lambda (gv) (match gv [(expression (== ⊢) g v) (begin
                  (cons (expr-simple g printDebug) (expr-simple v printDebug)))]))
                gvs)))
          (if (< 0 (length gvs-new))
            (apply ite* gvs-new)
            (void)))
      ]
  
      ; (= 0 (ite (|| (= 0 recv) (= 1 recv)) recv (+ -1 (ite (= 0 recv) recv (+ -1 recv)))))
      ; (= 0 (ite (= 0 (ite (= 0 recv) recv (+ -1 recv))) recv (+ -1 (ite (= 0 recv) recv (+ -1 recv))))) -> (|| (= 0 recv) (= 2 recv))
      [(expression (== =) x (expression (== ite) y-x y-y y-z))
        #:when (unsat? (verify (assert (equal? (|| (= 0 y-y) (= 2 y-y)) expr))))
        (begin (when printDebug (println "H*****************"))
          (|| (= 0 (expr-simple y-y printDebug)) (= 2 (expr-simple y-y printDebug))))]
  
      ; (= 0 (ite (= 0 recv) recv (+ -1 recv))) -> (|| (= 0 recv) (= 1 recv))
      [(expression (== =) x (expression (== ite) (expression (== =) y-x-x y-x-y) y-y (expression (== +) y-z-x y-z-y)))
        #:when (&& (equal? x 0) (equal? y-x-x 0) (equal? y-x-y y-y) (term? y-y) (equal? y-z-x -1) (equal? y-z-y y-y))
        (begin (when printDebug (println "I*****************"))
          (|| (= 0 (expr-simple y-y printDebug)) (= 1 (expr-simple y-y printDebug))))]
  
      [(expression (== =) x y) (= (expr-simple x printDebug) (expr-simple y printDebug))]
      [(expression (== ⊢) x y) (⊢ (expr-simple x printDebug) (expr-simple y printDebug))]
      [(expression (== =) x y) (= (expr-simple x printDebug) (expr-simple y printDebug))]
      [(expression (== +) x y) (+ (expr-simple x printDebug) (expr-simple y printDebug))]
      [(expression (== -) x y) (- (expr-simple x printDebug) (expr-simple y printDebug))]
      [(expression (== !) x) (! (expr-simple x printDebug))]
      [v v])
    expr))

