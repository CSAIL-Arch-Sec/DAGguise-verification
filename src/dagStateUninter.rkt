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
;HIST_SIZE - const - the length of respHistory, this is used to generate new requests
;OBSERVE_SIZE - const - the size of whole history, this is only for observation usage
;TAG_SIZE - log2 of #Bank
(struct dagState (respHistory vertexID coreID reqFunc HIST_SIZE OBSERVE_SIZE TAG_SIZE REAL_SIZE) #:mutable #:transparent)
(define (init-dagState coreID reqFunc HIST_SIZE OBSERVE_SIZE TAG_SIZE)
  (dagState
    (bv 0 (* (+ 1 TAG_SIZE) (max HIST_SIZE OBSERVE_SIZE)))
    0 coreID reqFunc
    (* (+ 1 TAG_SIZE) HIST_SIZE)
    (* (+ 1 TAG_SIZE) OBSERVE_SIZE)
    TAG_SIZE
    (* (+ 1 TAG_SIZE) (max HIST_SIZE OBSERVE_SIZE))))

; For K induction
(define (set-dagState! dagState respHistory vertexID)
  (set-dagState-respHistory! dagState (zero-extend respHistory (bitvector (dagState-REAL_SIZE dagState))))
  (set-dagState-vertexID! dagState vertexID)
)


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


(define (simuRespFor-dagState! dagState vertexID tagID)
  (set-dagState-respHistory! dagState
    (bvor (dagState-respHistory dagState)
      (bvadd (bvshl (bv 1 (dagState-REAL_SIZE dagState)) (bv (dagState-TAG_SIZE dagState) (dagState-REAL_SIZE dagState)))
             (zero-extend tagID (bitvector (dagState-REAL_SIZE dagState))))))
)

(define (incClkFor-dagState! dagState)
  (set-dagState-respHistory! dagState
    (bvshl (dagState-respHistory dagState) (bv (+ 1 (dagState-TAG_SIZE dagState)) (dagState-REAL_SIZE dagState))))
)

(define (dagState-req dagState)
  (define validTag ((dagState-reqFunc dagState) (extract (- (dagState-HIST_SIZE dagState) 1) 0 (dagState-respHistory dagState))))
  (if (bitvector->bool (msb validTag))
    (begin
      (set-dagState-vertexID! dagState (+ 1 (dagState-vertexID dagState)))
      (packet (dagState-coreID dagState) (dagState-vertexID dagState) 0 (extract (- 1 (dagState-TAG_SIZE dagState)) 0 validTag)))
    (void)))


(define (testMe)
  (define-symbolic func (~> (bitvector 4) (bitvector 2)))
  ;(define (func x) (bv -1 2))
  (define dagState (init-dagState CORE_Shaper func 2 4 1))
  (simuRespFor-dagState! dagState 11111 (bv 1 1))

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
