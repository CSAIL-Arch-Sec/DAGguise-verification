#lang rosette
; rosette? rosette/safe?

(require "packet.rkt" "symopt.rkt")
(require rosette/base/core/union)

(provide
  init-scheduler

  symopt-scheduler!
  simuReqFor-scheduler!
  incClkFor-scheduler!
  scheduler-canAccept
  scheduler-resp
  
  (all-from-out "packet.rkt"))

(define BUF_SIZE 10)
(define DEBUG_SYMOPT #f)


;FIFO scheduler
;buf - save packets that will be response in future
;cycleForNext - will send a response after cycleForNext
;interval - const - send response every interval cycles
(struct scheduler (buf cycleForNext interval) #:mutable #:transparent)
(define (init-scheduler interval) (scheduler (list) interval (- interval 1))) ;TODO: this is a hack to get good response interval


(define (symopt-scheduler! scheduler)

  (when DEBUG_SYMOPT (println "--------------------------------------------------"))
  (when DEBUG_SYMOPT (println "before symopt: symopt-scheduler!"))
  (when DEBUG_SYMOPT (println scheduler))

  (when (union? (scheduler-buf scheduler))
    (define (update-guardKey guardKey)
      (append
        (list (expr-simple (car guardKey) DEBUG_SYMOPT))
        (map packet-simple (rest guardKey))))
    (define union-contents-old (union-contents (scheduler-buf scheduler)))
    (define union-contents-new (map update-guardKey union-contents-old))
    
    (set-union-contents! (scheduler-buf scheduler) union-contents-new))

  (when DEBUG_SYMOPT (println "after symopt: symopt-scheduler!"))
  (when DEBUG_SYMOPT (println scheduler))
  (when DEBUG_SYMOPT (println "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"))
)


(define (simuReqFor-scheduler! scheduler packet)
  (set-scheduler-buf! scheduler
    (append (scheduler-buf scheduler) (list packet))))

(define (incClkFor-scheduler! scheduler)
  ;(unless (equal? 0 (length (scheduler-buf scheduler)))
    (if (equal? 0 (scheduler-cycleForNext scheduler))
      (begin (set-scheduler-buf! scheduler (rest (scheduler-buf scheduler)))
             (set-scheduler-cycleForNext! scheduler (scheduler-interval scheduler)))
      (set-scheduler-cycleForNext! scheduler (- (scheduler-cycleForNext scheduler) 1)));)
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

