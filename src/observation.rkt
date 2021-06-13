#lang rosette

(provide
  init-observation

  addLog!
  getLog)


;TODO: log can be more complex than just clk
(struct observation (log_RC) #:mutable #:transparent)
(define (init-observation) (observation (list)))


(define (addLog! observe clk)
  (set-observation-log_RC! observe (append (observation-log_RC observe) (list clk))))


(define (getLog observe)
  (observation-log_RC observe))


(define (testMe)
  (define observe (init-observation))
  (addLog! observe 1)
  (addLog! observe 3)
  (addLog! observe 10)
  (println (getLog observe))

  (addLog! observe 100)
  (println (getLog observe)))

;(testMe)

