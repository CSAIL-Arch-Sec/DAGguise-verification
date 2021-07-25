#lang rosette
; rosette? rosette/safe?

(require "packet.rkt" "symopt.rkt")
(require rosette/base/core/union)

(provide
  (struct-out scheduler)
  init-scheduler

  symopt-scheduler!
  simuReqFor-scheduler!
  incClkFor-scheduler!
  scheduler-canAccept
  scheduler-resp)

(define BUF_SIZE 10)
(define DEBUG_SYMOPT #f)


;FIFO scheduler
;buf - save packets that will be response in future
;cycleForNext - will send a response after cycleForNext
;interval - const - send response every interval cycles
(struct scheduler (buf pHead pTail cycleForNext interval) #:mutable #:transparent)
(define (init-scheduler interval) (scheduler (make-vector BUF_SIZE) 0 0 interval interval))


(define (symopt-scheduler! scheduler)

  (when DEBUG_SYMOPT (println "--------------------------------------------------"))
  (when DEBUG_SYMOPT (println "before symopt: symopt-scheduler!"))
  (when DEBUG_SYMOPT (println scheduler))

  (when DEBUG_SYMOPT (println "after symopt: symopt-scheduler!"))
  (when DEBUG_SYMOPT (println scheduler))
  (when DEBUG_SYMOPT (println "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"))
)


(define (simuReqFor-scheduler! scheduler packet)
  (vector-set! (scheduler-buf scheduler) (scheduler-pTail scheduler) packet)
  (set-scheduler-pTail! scheduler (+ 1 (scheduler-pTail scheduler)))
  (when (equal? BUF_SIZE (scheduler-pTail scheduler)) (set-scheduler-pTail! scheduler 0))
)

(define (incClkFor-scheduler! scheduler)
  (unless (equal? (scheduler-pHead scheduler) (scheduler-pTail scheduler))
    (if (equal? 0 (scheduler-cycleForNext scheduler))
      (begin (set-scheduler-pHead! scheduler (+ 1 (scheduler-pHead scheduler)))
             (when (equal? BUF_SIZE (scheduler-pHead scheduler)) (set-scheduler-pHead! scheduler 0))
             (set-scheduler-cycleForNext! scheduler (scheduler-interval scheduler)))
      (set-scheduler-cycleForNext! scheduler (- (scheduler-cycleForNext scheduler) 1))))
)

(define (scheduler-canAccept scheduler req_Shaper req_Rx)
  (if (|| (equal? (remainder (+ 1 (scheduler-pTail scheduler)) BUF_SIZE) (scheduler-pHead scheduler))
          (equal? (remainder (+ 2 (scheduler-pTail scheduler)) BUF_SIZE) (scheduler-pHead scheduler)))
    (list #f #f)
    (list req_Shaper req_Rx))
)

(define (scheduler-resp scheduler)
  (if (&& (not (equal? (scheduler-pHead scheduler) (scheduler-pTail scheduler))) ;This should be implicitly always correct
          (equal? 0 (scheduler-cycleForNext scheduler)))
    (let ([packet (vector-ref (scheduler-buf scheduler) (scheduler-pHead scheduler))])
      (cond
        [(equal? CORE_Shaper (packet-coreID packet)) (list packet (void))]
        [(equal? CORE_Rx (packet-coreID packet)) (list (void) packet)]
        [else (assert #f)]))
    (list (void) (void)))
)


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

