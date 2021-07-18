#lang rosette
; rosette? rosette/safe?

(require "packet.rkt")

(provide
  init-scheduler

  simuReqFor-scheduler!
  incClkFor-scheduler!
  scheduler-canAccept
  scheduler-resp
  
  (all-from-out "packet.rkt"))


(define BUF_SIZE 10)


;FIFO scheduler
;buf - save packets that will be response in future
;cycleForNext - will send a response after cycleForNext
;interval - const - send response every interval cycles
(struct scheduler (buf cycleForNext interval) #:mutable #:transparent)
(define (init-scheduler interval) (scheduler (list) interval interval))


(define (simuReqFor-scheduler! scheduler packet)
  (set-scheduler-buf! scheduler
    (append (scheduler-buf scheduler) (list packet))))

(define (incClkFor-scheduler! scheduler)
  (unless (equal? 0 (length (scheduler-buf scheduler)))
    (if (equal? 0 (scheduler-cycleForNext scheduler))
      (begin (set-scheduler-buf! scheduler (rest (scheduler-buf scheduler)))
             (set-scheduler-cycleForNext! scheduler (scheduler-interval scheduler)))
      (set-scheduler-cycleForNext! scheduler (- (scheduler-cycleForNext scheduler) 1)))))

;(match-define (list a b) (f))
;(do-something-with a b)
(define (scheduler-canAccept scheduler req_Shaper req_Rx)
  (if (> BUF_SIZE (length (scheduler-buf scheduler))) ;TODO: add prority
    (list req_Shaper req_Rx)
    (list #f #f)))

(define (scheduler-resp scheduler)
  (if (equal? 0 (scheduler-cycleForNext scheduler))
    (let ([packet (first (scheduler-buf scheduler))])
      (cond
        [(equal? CORE_Shaper (packet-coreID packet)) (list packet (void))]
        [(equal? CORE_Rx (packet-coreID packet)) (list (void) packet)]
        [else (assert #f)])) ;TODO: why need this assume?
    (list (void) (void))))


(define (testMe)
  (define scheduler (init-scheduler 3))

  (println (scheduler-canAccept scheduler #t #f))
  (println "-------------------")
  
  (simuReqFor-scheduler! scheduler (packet 0 0 0 0))
  (incClkFor-scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (simuReqFor-scheduler! scheduler (packet 0 0 0 1))
  (simuReqFor-scheduler! scheduler (packet 1 0 0 1))
  (incClkFor-scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (println (scheduler-resp scheduler))
  (incClkFor-scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (println (scheduler-resp scheduler))
  (incClkFor-scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (println (scheduler-resp scheduler))
  (incClkFor-scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (println (scheduler-resp scheduler))
  (incClkFor-scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (println (scheduler-resp scheduler))
  (incClkFor-scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (println (scheduler-resp scheduler))
  (incClkFor-scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (println (scheduler-resp scheduler))
  (incClkFor-scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (println (scheduler-resp scheduler))
  (incClkFor-scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (println (scheduler-resp scheduler))
  (incClkFor-scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (println (scheduler-resp scheduler))
  (incClkFor-scheduler! scheduler)
  (println scheduler)
  (println "-------------------"))

;(testMe)

