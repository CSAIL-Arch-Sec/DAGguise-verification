#lang rosette
; rosette? rosette/safe?

(require "packet.rkt")

(provide
  init-scheduler

  updateWithReq!
  updateClk_scheduler!
  willAccept
  getResp
  
  (all-from-out "packet.rkt"))


(struct scheduler (servingPacket interval) #:mutable #:transparent)
(define (init-scheduler interval) (scheduler (make-hash) interval))


(define (updateWithReq! scheduler packet)
  (hash-set! (scheduler-servingPacket scheduler) packet (scheduler-interval scheduler)))

(define (updateClk_scheduler! scheduler)
  (define (countDown key value)
    (if (equal? 0 (hash-ref (scheduler-servingPacket scheduler) key))
      (hash-remove! (scheduler-servingPacket scheduler) key)
      (hash-set! (scheduler-servingPacket scheduler) key (- value 1))))
  (hash-for-each (scheduler-servingPacket scheduler) countDown))

;(match-define (list a b) (f))
;(do-something-with a b)
(define (willAccept scheduler req_SH req_RC)
  (list req_SH req_RC))

(define (getResp scheduler)
  (define (getSH key value)
    (if (and (equal? core_SH (packet-coreID key)) (equal? 0 value))
      key
      (void)))
  (define respSH (filter (lambda (x) (not (void? x))) (hash-map (scheduler-servingPacket scheduler) getSH)))
  (assert (> 2 (length respSH)))

  (define (getRC key value)
    (if (and (equal? core_RC (packet-coreID key)) (equal? 0 value))
      key
      (void)))
  (define respRC (filter (lambda (x) (not (void? x))) (hash-map (scheduler-servingPacket scheduler) getRC)))
  (assert (> 2 (length respRC)))

  (append 
    (if (equal? 0 (length respSH)) (list (void)) respSH)
    (if (equal? 0 (length respRC)) (list (void)) respRC)))


(define (testMe)
  (define scheduler (init-scheduler 3))

  (println (willAccept scheduler #t #f))
  (println "-------------------")
  
  (updateWithReq! scheduler (packet 0 0 0 0))
  (updateClk_scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (updateWithReq! scheduler (packet 0 0 0 1))
  (updateWithReq! scheduler (packet 1 0 0 1))
  (updateClk_scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (updateClk_scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (println (getResp scheduler))
  (updateClk_scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (println (getResp scheduler))
  (updateClk_scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (updateClk_scheduler! scheduler)
  (println scheduler)
  (println "-------------------"))

;(testMe)

