#lang rosette

(require "packet.rkt" "symopt.rkt")

(provide
  (struct-out dagState)
  init-dagState
  set-dagState!

  symopt-dagState!
  simuRespFor-dagState!
  incClkFor-dagState!
  dagState-req)

(define DEBUG_SYMOPT #f)


;cycleForNext - will send a request after cycleForNext
;vertexID - the ID of next sent request, unique for each req/resp pair
;coreID - const - all sent packet will be labeled with coreID, unique for each core/dag
;interval - const - send request every interval cycles
;tagID - the tag (bankID) of next sent request.
;TAG_SIZE - log2 of #Bank
(struct dagState (pending cycleForNext vertexID coreID tagID interval TAG_SIZE) #:mutable #:transparent)
(define (init-dagState coreID interval TAG_SIZE) (dagState #f interval 0 coreID (bv 0 TAG_SIZE) interval TAG_SIZE))

; For K induction
(define (set-dagState! dagState pending cycleForNext tagID)
  (set-dagState-pending! dagState pending)
  (set-dagState-cycleForNext! dagState (if pending (dagState-interval dagState) cycleForNext))
  (set-dagState-tagID! dagState tagID)
)


(define (symopt-dagState! dagState)

  (when DEBUG_SYMOPT (println "--------------------------------------------------"))
  (when DEBUG_SYMOPT (println "before symopt: symopt-dagState!"))
  (when DEBUG_SYMOPT (println dagState))

  (when DEBUG_SYMOPT (println "after symopt: symopt-dagState!"))
  (when DEBUG_SYMOPT (println dagState))
  (when DEBUG_SYMOPT (println "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"))
)


(define (simuRespFor-dagState! dagState vertexID tagID)
  (set-dagState-pending! dagState #f)
  (void))

(define (incClkFor-dagState! dagState)
  (unless (dagState-pending dagState)
    (if (equal? 0 (dagState-cycleForNext dagState))
      (begin
        (set-dagState-pending! dagState #t)
        (set-dagState-cycleForNext! dagState (dagState-interval dagState)))
      (set-dagState-cycleForNext! dagState (- (dagState-cycleForNext dagState) 1))))
)

(define (dagState-req dagState)
  (if (&& (not (dagState-pending dagState)) (equal? 0 (dagState-cycleForNext dagState)))
    (begin
      (set-dagState-tagID! dagState (bvadd (bv 1 (dagState-TAG_SIZE dagState)) (dagState-tagID dagState)))
      (set-dagState-vertexID! dagState (+ 1 (dagState-vertexID dagState)))
      (packet (dagState-coreID dagState) (dagState-vertexID dagState) 0 (dagState-tagID dagState)))
    (void)))


(define (testMe)
  (define dagState (init-dagState CORE_Shaper 3 1))
  (simuRespFor-dagState! dagState 11111 222)

  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
)

;(testMe)
