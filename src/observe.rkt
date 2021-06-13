#lang rosette

(provide
  initObserve

  addLog
  getLog)


;TODO: log can be more complex than just clk
(struct observe_t (log_RC) #:mutable #:transparent)
(define (initObserve) (observe_t (list)))


(define (addLog observe clk)
  (set-observe_t-log_RC! observe (append (observe_t-log_RC observe) (list clk))))


(define (getLog observe)
  (observe_t-log_RC observe))


(define (testMe)
  (define observe (initObserve))
  (addLog observe 1)
  (addLog observe 3)
  (addLog observe 10)
  (println (getLog observe))

  (addLog observe 100)
  (println (getLog observe)))

;(testMe)

