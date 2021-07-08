#lang rosette

(provide
  init-observation

  addLogTo-observation!
  observation-log)


;TODO: log can be more complex than just clk
(struct observation (log_Rx) #:mutable #:transparent)
(define (init-observation) (observation (list)))


(define (addLogTo-observation! observation clk)
  (set-observation-log_Rx! observation (append (observation-log_Rx observation) (list clk))))


(define (observation-log observation)
  (observation-log_Rx observation))


(define (testMe)
  (define observation (init-observation))
  (addLogTo-observation! observation 1)
  (addLogTo-observation! observation 3)
  (addLogTo-observation! observation 10)
  (println (observation-log observation))

  (addLogTo-observation! observation 100)
  (println (observation-log observation)))

;(testMe)

