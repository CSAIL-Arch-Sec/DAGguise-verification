#lang rosette
; rosette? rosette/safe?

(require "packet.rkt" "symopt.rkt")
(require rosette/base/core/union)

(provide
  (struct-out scheduler)
  init-scheduler
  set-scheduler!

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
    (make-vector (expt 2 TAG_SIZE) (list))
    (make-vector (expt 2 TAG_SIZE) interval)
    (bv 0 (* 2 (+ 1 TAG_SIZE) OBSERVE_SIZE))
    interval (* 2 (+ 1 TAG_SIZE) OBSERVE_SIZE) TAG_SIZE)) ;TODO: this is a hack to get good response interval

; For K induction
(define (set-scheduler! scheduler cycleForNext buf-valid buf-coreID buf-vertexID)
  (set-scheduler-cycleForNext! scheduler
    (list->vector
      ;(map (lambda (i) (bitvector->natural i))
      (map (lambda (i) 0)
           cycleForNext)))

  ; NOTE: because tag become useless after being pushed into bank buffer, set all tag to 0
  (set-scheduler-buf! scheduler
    (list->vector
      (map (lambda (valid-multi coreID-multi vertexID-multi)
                   (filter (lambda (x) (not (void? x)))
                      ;(map (lambda (valid coreID vertexID) (if valid (packet (bitvector->natural coreID) (bitvector->natural vertexID) 0 0) (void)))
                      (map (lambda (valid coreID vertexID) (if #t (packet (bitvector->natural coreID) (bitvector->natural vertexID) 0 0) (void)))
                           valid-multi coreID-multi vertexID-multi)))
           buf-valid buf-coreID buf-vertexID)))
)


(define (symopt-scheduler! scheduler)

  (when DEBUG_SYMOPT (println "--------------------------------------------------"))
  (when DEBUG_SYMOPT (println "before symopt: symopt-scheduler!"))
  (when DEBUG_SYMOPT (println scheduler))

  (when DEBUG_SYMOPT (println "after symopt: symopt-scheduler!"))
  (when DEBUG_SYMOPT (println scheduler))
  (when DEBUG_SYMOPT (println "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"))
)


(define (simuReqFor-scheduler! scheduler packet)
  (let ([tagID (bitvector->natural (packet-tag packet))]
        [buf (scheduler-buf scheduler)])
    (vector-set! buf tagID (append (vector-ref buf tagID) (list packet))))

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
  (define buf-isEmpty (vector-map (lambda (buf) (empty? buf))
                                  (scheduler-buf scheduler)))
  (define buf-willResp (vector-map (lambda (cycleForNext) (>= 0 cycleForNext))
                                  (scheduler-cycleForNext scheduler)))

  (define (setFirstTrue_recur v i waitFirstTrueFlag)
    (when (< i (vector-length v))
      (if waitFirstTrueFlag
        (if (vector-ref v i)
          (setFirstTrue_recur v (+ 1 i) #f)
          (setFirstTrue_recur v (+ 1 i) #t))
        (begin (vector-set! v i #f)
               (setFirstTrue_recur v (+ 1 i) #f)))))
  (setFirstTrue_recur buf-willResp 0 #t)

  (vector-map! (lambda (buf isEmpty willResp) (if (&& (not isEmpty) willResp)
                                                (rest buf)
                                                buf))
               (scheduler-buf scheduler) buf-isEmpty buf-willResp)
  (vector-map! (lambda (cycleForNext isEmpty willResp) (if (not isEmpty)
                                                          (if willResp
                                                              (scheduler-interval scheduler)
                                                              (- cycleForNext 1))
                                                          (scheduler-interval scheduler)))
               (scheduler-cycleForNext scheduler) buf-isEmpty buf-willResp)

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

; NOTE: when bus contention, we always give smaller tagID high priority
(define (scheduler-resp scheduler)
  (define packet-canResp
    (vector-filter-not void?
      (vector-map (lambda (buf cycleForNext) (if (&& (not (empty? buf)) (>= 0 cycleForNext))
                                                 (first buf)
                                                 (void)))
                  (scheduler-buf scheduler) (scheduler-cycleForNext scheduler))))

  (if (vector-empty? packet-canResp)
    (list (void) (void))
    (let ([packet (vector-ref packet-canResp 0)])
      (cond
        [(equal? CORE_Shaper (packet-coreID packet)) (list packet (void))]
        [(equal? CORE_Rx (packet-coreID packet)) (list (void) packet)]
        [else (assert #f)])))
)


(define (testMe)
  (define scheduler (init-scheduler 2 1 1))
  (set-scheduler! scheduler
    (list (bv 1 1) (bv 1 1))
    (list (list #t #f) (list #f #t))
    (list (list (bv 0 1) (bv 0 1)) (list (bv 0 1) (bv 0 1)))
    (list (list (bv 0 1) (bv 0 1)) (list (bv 0 1) (bv 0 1))))

  ;(println (scheduler-canAccept scheduler #t #f))
  (println scheduler)
  (println "-------------------")
  
  ;(simuReqFor-scheduler! scheduler (packet 0 0 0 (bv 0 1)))
  (println (scheduler-resp scheduler))
  (incClkFor-scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  ;(simuReqFor-scheduler! scheduler (packet 0 0 0 (bv 0 1)))
  ;(simuReqFor-scheduler! scheduler (packet 1 0 0 (bv 1 1)))
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
  (println "-------------------")
  (println (scheduler-resp scheduler))
  (incClkFor-scheduler! scheduler)
  (println scheduler)
  (println "-------------------"))

;(testMe)

