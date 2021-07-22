#lang rosette

(provide expr-simple)
(require rosette/base/core/polymorphic)

(define USE_SYMOPT #f)


(define (expr-simple expr printDebug)
  (define PRINT_DEBUG (&& printDebug #t))
  (define needPrint #f)
  (if USE_SYMOPT
    (let ([expr-new
            (match expr
              [v #:when (not (term? v)) v]
              [(expression op x (expression (== ite*) gvs ...))
                (begin  (when PRINT_DEBUG (println "A******************"))
                        (set! needPrint #t)
                        (apply || 
                          (map (lambda (g) (expr-simple g printDebug))
                            (map (lambda (gv) (match gv [(expression (== ⊢) g v) (if (op x v) g #f)]))
                              gvs))))]
              [(expression op child ...)  
                (apply op (for/list ([e child]) (expr-simple e printDebug)))]
              [_ expr])])
      (when (&& PRINT_DEBUG needPrint) (println expr))
      (when (&& PRINT_DEBUG needPrint) (println expr-new))
      (when (&& PRINT_DEBUG needPrint) (assert (equal? expr expr-new)))
      (when (&& PRINT_DEBUG needPrint) (println "^^^^^^^^^^^^^^^^^^"))
      expr-new
    )
    expr))

