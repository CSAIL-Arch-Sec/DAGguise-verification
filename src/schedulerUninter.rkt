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

(define DEBUG_SYMOPT #f)


;FIFO scheduler
;buf - save packets that will be response in future
;reqHistory - a bitvector to log whether each cycle has response,  vector[0] is the youngest ; TODO: use tag in history
;respFunc - const - an uninterpreted function to decide whether sending response this cycle based on request history
;HIST_SIZE - const - the length of reqHistory.
(struct scheduler (buf reqHistory respFunc HIST_SIZE) #:mutable #:transparent)
(define (init-scheduler respFunc HIST_SIZE) (scheduler (list) (bv 0 HIST_SIZE) respFunc HIST_SIZE))


(define (symopt-scheduler! scheduler)

  (when DEBUG_SYMOPT (println "--------------------------------------------------"))
  (when DEBUG_SYMOPT (println "before symopt: symopt-scheduler!"))
  (when DEBUG_SYMOPT (println scheduler))

  (when DEBUG_SYMOPT (println "after symopt: symopt-scheduler!"))
  (when DEBUG_SYMOPT (println scheduler))
  (when DEBUG_SYMOPT (println "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"))
)


(define (simuReqFor-scheduler! scheduler packet)
  (set-scheduler-reqHistory! scheduler
    (bvor (scheduler-reqHistory scheduler) (bv 1 (scheduler-HIST_SIZE scheduler))))
  (set-scheduler-buf! scheduler
    (append (scheduler-buf scheduler) (list packet)))
)

(define (incClkFor-scheduler! scheduler)
  (when (&& ((scheduler-respFunc scheduler) (scheduler-reqHistory scheduler))
            (< 0 (length (scheduler-buf scheduler))))
    (set-scheduler-buf! scheduler (rest (scheduler-buf scheduler))))
  (set-scheduler-reqHistory! scheduler
    (bvshl (scheduler-reqHistory scheduler) (bv 1 (scheduler-HIST_SIZE scheduler))))
)

(define (scheduler-canAccept scheduler req_Shaper req_Rx)
  (list req_Shaper req_Rx)
)

(define (scheduler-resp scheduler)
  (if (< 0 (length (scheduler-buf scheduler)))
    (if (&& ((scheduler-respFunc scheduler) (scheduler-reqHistory scheduler))
              (< 0 (length (scheduler-buf scheduler))))
      (let ([packet (first (scheduler-buf scheduler))])
        (cond
          [(equal? CORE_Shaper (packet-coreID packet)) (list packet (void))]
          [(equal? CORE_Rx (packet-coreID packet)) (list (void) packet)]
          [else (assert #f)]))
      (list (void) (void)))
    (list (void) (void)))
)


(define (testMe)
  (define HIST_SIZE 10) (define-symbolic sched (~> (bitvector HIST_SIZE) boolean?))
  (define scheduler (init-scheduler sched HIST_SIZE))

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

