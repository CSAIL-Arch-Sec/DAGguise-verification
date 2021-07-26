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
  scheduler-resp
  scheduler-reqHistory
)

(define BUF_SIZE 10)
(define DEBUG_SYMOPT #f)


;FIFO scheduler
;buf - save packets that will be response in future
;cycleForNext - will send a response after cycleForNext
;reqHistory - a bitvector to log whether each cycle has request. (valid_Shaper, bankID, valid_Rx, bankID)
;interval - const - send response every interval cycles
;OBSERVE_SIZE - const - the size of whole history, this is only for a stronger k-induction
;TAG_SIZE - log2 of #Bank
(struct scheduler (buf cycleForNext reqHistory interval OBSERVE_SIZE TAG_SIZE) #:mutable #:transparent)
(define (init-scheduler interval OBSERVE_SIZE TAG_SIZE)
  (scheduler
    (list) interval
    (bv 0 (* 2 (+ 1 TAG_SIZE) OBSERVE_SIZE))
    interval (* 2 (+ 1 TAG_SIZE) OBSERVE_SIZE) TAG_SIZE)) ;TODO: this is a hack to get good response interval


(define (symopt-scheduler! scheduler)

  (when DEBUG_SYMOPT (println "--------------------------------------------------"))
  (when DEBUG_SYMOPT (println "before symopt: symopt-scheduler!"))
  (when DEBUG_SYMOPT (println scheduler))

  (when (union? (scheduler-buf scheduler))
    (define (update-guardKey guardKey)
      (append
        (list (expr-simple (car guardKey) DEBUG_SYMOPT))
        (map (lambda (x) (packet-simple x DEBUG_SYMOPT)) (rest guardKey))))
    (define union-contents-old (union-contents (scheduler-buf scheduler)))
    (define union-contents-new (map update-guardKey union-contents-old))
    
    (set-union-contents! (scheduler-buf scheduler) union-contents-new))

  (when DEBUG_SYMOPT (println "--------------------------------------------------"))
  (when DEBUG_SYMOPT (println "before symopt: symopt-scheduler!"))
  (when DEBUG_SYMOPT (println scheduler))

  (set-scheduler-cycleForNext! scheduler (expr-simple (scheduler-cycleForNext scheduler) DEBUG_SYMOPT))

  (when DEBUG_SYMOPT (println "after symopt: symopt-scheduler!"))
  (when DEBUG_SYMOPT (println scheduler))
  (when DEBUG_SYMOPT (println "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"))
)


(define (simuReqFor-scheduler! scheduler packet)
  (set-scheduler-buf! scheduler
    (append (scheduler-buf scheduler) (list packet)))

  (when (equal? CORE_Shaper (packet-coreID packet))
    (set-scheduler-reqHistory! scheduler
      (bvor (scheduler-reqHistory scheduler)
        (bvadd (bvshl (bv 1 (scheduler-OBSERVE_SIZE scheduler)) (bv (scheduler-TAG_SIZE scheduler) (scheduler-OBSERVE_SIZE scheduler)))
               (zero-extend (packet-tag packet) (bitvector (scheduler-OBSERVE_SIZE scheduler)))))))

  (when (equal? CORE_Rx (packet-coreID packet))
    (set-scheduler-reqHistory! scheduler
      (bvor (scheduler-reqHistory scheduler)
        (bvshl
          (bvadd (bvshl (bv 1 (scheduler-OBSERVE_SIZE scheduler)) (bv (scheduler-TAG_SIZE scheduler) (scheduler-OBSERVE_SIZE scheduler)))
                 (zero-extend (packet-tag packet) (bitvector (scheduler-OBSERVE_SIZE scheduler))))
          (bv (+ 1 (scheduler-TAG_SIZE scheduler)) (scheduler-OBSERVE_SIZE scheduler))))))
)

(define (incClkFor-scheduler! scheduler)
  (unless (equal? 0 (length (scheduler-buf scheduler)))
    (if (equal? 0 (scheduler-cycleForNext scheduler))
      (begin (set-scheduler-buf! scheduler (rest (scheduler-buf scheduler)))
             (set-scheduler-cycleForNext! scheduler (scheduler-interval scheduler)))
      (set-scheduler-cycleForNext! scheduler (- (scheduler-cycleForNext scheduler) 1))))

  (set-scheduler-reqHistory! scheduler
    (bvshl (scheduler-reqHistory scheduler) (bv (* 2 (+ 1 (scheduler-TAG_SIZE scheduler))) (scheduler-OBSERVE_SIZE scheduler))))
)

;(match-define (list a b) (f))
;(do-something-with a b)
(define (scheduler-canAccept scheduler req_Shaper req_Rx)
  (list req_Shaper req_Rx)
  ;(if (> BUF_SIZE (length (scheduler-buf scheduler))) ;TODO: add prority
  ;  (list req_Shaper req_Rx)
  ;  (list #f #f))
  )

(define (scheduler-resp scheduler)
  (if (&& (< 0 (length (scheduler-buf scheduler)))
          (equal? 0 (scheduler-cycleForNext scheduler)))
    (let ([packet (first (scheduler-buf scheduler))])
      (cond
        [(equal? CORE_Shaper (packet-coreID packet)) (list packet (void))]
        [(equal? CORE_Rx (packet-coreID packet)) (list (void) packet)]
        [else (assert #f)]))
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

