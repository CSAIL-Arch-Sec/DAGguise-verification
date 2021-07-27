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


(struct dagState (reqBuf reqBufIndex vertexID respHistory coreID HIST_SIZE TAG_SIZE) #:mutable #:transparent)
(define (init-dagState reqBuf coreID HIST_SIZE TAG_SIZE)
  (dagState
    reqBuf 0 0
    (if (< 0 HIST_SIZE) (bv 0 (* (+ 1 TAG_SIZE) HIST_SIZE)) (void))
    coreID
    (* (+ 1 TAG_SIZE) HIST_SIZE)
    TAG_SIZE)
)

; For K induction
(define (set-dagState! dagState reqBuf vertexID)
  (set-dagState-reqBufIndex! dagState 0)
  (set-dagState-reqBuf! dagState reqBuf)
  (set-dagState-vertexID! dagState vertexID)
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
  (when (< 0 (dagState-HIST_SIZE dagState))
    (set-dagState-respHistory! dagState
      (bvor (dagState-respHistory dagState)
            (bvor (bvshl (bv 1 (dagState-HIST_SIZE dagState)) (bv (dagState-TAG_SIZE dagState) (dagState-HIST_SIZE dagState)))
                  (zero-extend tagID (bitvector (dagState-HIST_SIZE dagState)))))))
)

(define (incClkFor-dagState! dagState)
  (set-dagState-reqBufIndex! dagState (+ 1 (dagState-TAG_SIZE dagState) (dagState-reqBufIndex dagState)))
  (when (< 0 (dagState-HIST_SIZE dagState))
    (set-dagState-respHistory! dagState
      (bvshl (dagState-respHistory dagState) (bv (+ 1 (dagState-TAG_SIZE dagState)) (dagState-HIST_SIZE dagState)))))
)

(define (dagState-req dagState)
  (define validTag (extract (+ (dagState-TAG_SIZE dagState) (dagState-reqBufIndex dagState)) (dagState-reqBufIndex dagState) (dagState-reqBuf dagState)))
  (if (bitvector->bool (msb validTag))
    (begin
      (set-dagState-vertexID! dagState (+ 1 (dagState-vertexID dagState)))
      (packet (dagState-coreID dagState) (dagState-vertexID dagState) 0 (extract (- 1 (dagState-TAG_SIZE dagState)) 0 validTag)))
    (void))
)


(define (testMe)
  ;(define-symbolic reqBuf (bitvector 8))
  (define reqBuf (bv #b11100100 8))
  (define dagState (init-dagState reqBuf CORE_Shaper 10 1))
  (simuRespFor-dagState! dagState 11111 (bv 1 1))

  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)

  (set-dagState! dagState (bv #b0110 4) 100)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
)

;(testMe)
