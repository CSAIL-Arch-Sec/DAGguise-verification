#lang rosette

(provide
  init-observation

  addLogTo-observation!
  observation-log)


;TODO: log can be more complex than just clk
(struct observation (log_RC) #:mutable #:transparent)
(define (init-observation) (observation (list)))


(define (addLogTo-observation! observe clk)
  (set-observation-log_RC! observe (append (observation-log_RC observe) (list clk))))


(define (observation-log observe)
  (observation-log_RC observe))


(define (testMe)
  (define observe (init-observation))
  (addLogTo-observation! observe 1)
  (addLogTo-observation! observe 3)
  (addLogTo-observation! observe 10)
  (println (observation-log observe))

  (addLogTo-observation! observe 100)
  (println (observation-log observe)))

;(testMe)

