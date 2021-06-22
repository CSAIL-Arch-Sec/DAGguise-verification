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


(define BUF_SIZE 10)


(struct scheduler (buf cycleForNext interval) #:mutable #:transparent)
(define (init-scheduler interval) (scheduler (list) interval interval))


(define (updateWithReq! scheduler packet)
  (assert (not (findf (lambda (x) (equal? x packet))
    (scheduler-buf scheduler))))
  (set-scheduler-buf! scheduler
    (append (scheduler-buf scheduler) (list packet))))

(define (updateClk_scheduler! scheduler)
  (unless (equal? 0 (length (scheduler-buf scheduler)))
    (if (equal? 0 (scheduler-cycleForNext scheduler))
      (begin (set-scheduler-buf! scheduler (rest (scheduler-buf scheduler)))
             (set-scheduler-cycleForNext! scheduler (scheduler-interval scheduler)))
      (set-scheduler-cycleForNext! scheduler (- (scheduler-cycleForNext scheduler) 1)))))

;(match-define (list a b) (f))
;(do-something-with a b)
(define (willAccept scheduler req_SH req_RC)
  (if (> BUF_SIZE (length (scheduler-buf scheduler))) ;TODO: add prority
    (list req_SH req_RC)
    (list #f #f)))

(define (getResp scheduler)
  (if (equal? 0 (scheduler-cycleForNext scheduler))
    (let ([packet (first (scheduler-buf scheduler))])
      (cond
        [(equal? CORE_SH (packet-coreID packet)) (list packet (void))]
        [(equal? CORE_RC (packet-coreID packet)) (list (void) packet)]
        [else (assert #f)])) ;TODO: why need this assume?
    (list (void) (void))))


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
  (println (getResp scheduler))
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
  (println (getResp scheduler))
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
  (println (getResp scheduler))
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
  (println (getResp scheduler))
  (updateClk_scheduler! scheduler)
  (println scheduler)
  (println "-------------------"))

;(testMe)

