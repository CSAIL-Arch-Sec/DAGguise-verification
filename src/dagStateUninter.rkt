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


;reqFunc - an uninterpreted function to decide whether sending request this cycle based on response history
;respHistory - a bitvector to log whether each cycle has response,  vector[0] is the youngest ; TODO: use tag in history
;vertexID - the ID of next sent request, unique for each req/resp pair
;coreID - const - all sent packet will be labeled with coreID, unique for each core/dag
;HIST_SIZE - const - the length of respHistory.
(struct dagState (respHistory vertexID coreID reqFunc HIST_SIZE OBSERVE_SIZE) #:mutable #:transparent)
(define (init-dagState coreID reqFunc HIST_SIZE OBSERVE_SIZE) (dagState (bv 0 OBSERVE_SIZE) 0 coreID reqFunc HIST_SIZE OBSERVE_SIZE))

; For K induction
(define (set-dagState! dagState respHistory vertexID)
  (set-dagState-vertexID! dagState vertexID))
  (set-dagState-respHistory! dagState (zero-extend respHistory (bitvector (dagState-OBSERVE_SIZE dagState))))


(define (symopt-dagState! dagState)

  (when DEBUG_SYMOPT (println "--------------------------------------------------"))
  (when DEBUG_SYMOPT (println "before symopt: symopt-dagState!"))
  (when DEBUG_SYMOPT (println dagState))

  (set-dagState-respHistory! dagState (expr-simple (dagState-respHistory dagState) DEBUG_SYMOPT))
  (set-dagState-vertexID! dagState (expr-simple (dagState-vertexID dagState) DEBUG_SYMOPT))

  (when DEBUG_SYMOPT (println "after symopt: symopt-dagState!"))
  (when DEBUG_SYMOPT (println dagState))
  (when DEBUG_SYMOPT (println "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"))
)


(define (simuRespFor-dagState! dagState vertexID)
  (set-dagState-respHistory! dagState
    (bvor (dagState-respHistory dagState) (bv 1 (dagState-OBSERVE_SIZE dagState)))))

(define (incClkFor-dagState! dagState)
  (set-dagState-respHistory! dagState
    (bvshl (dagState-respHistory dagState) (bv 1 (dagState-OBSERVE_SIZE dagState)))))

(define (dagState-req dagState)
  (if ((dagState-reqFunc dagState) (extract (- (dagState-HIST_SIZE dagState) 1) 0 (dagState-respHistory dagState)))
    (begin
      (set-dagState-vertexID! dagState (+ 1 (dagState-vertexID dagState)))
      (packet (dagState-coreID dagState) (dagState-vertexID dagState) 0 0))
    (void)))


(define (testMe)
  (define dagState (init-dagState CORE_Shaper))
  (simuRespFor-dagState! dagState 11111)

  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState))

;(testMe)
