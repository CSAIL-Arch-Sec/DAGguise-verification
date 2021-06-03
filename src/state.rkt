#lang rosette

(require
  "dagState.rkt"
  "obuf.rkt"
  "nodeMap.rkt"
  "SCH.rkt")

(provide
  initState
  (struct-out state_t)
  (all-from-out "dagState.rkt")
  (all-from-out "obuf.rkt")
  (all-from-out "nodeMap.rkt")
  (all-from-out "SCH.rkt"))


(struct state_t 
  (
    clk
    dagState_TR obuf_TR 
    dagState_SH obuf_SH nodeMap
    dagState_RC obuf_RC 
    SCH)
  #:mutable #:transparent)
(define (initState interval_TR interval_SH interval_RC interval_SCH) (state_t
  0
  (initDagState core_SH interval_TR) (initObuf)
  (initDagState core_SH interval_SH) (initObuf) (initNodeMap)
  (initDagState core_RC interval_RC) (initObuf)
  (initSCH interval_SCH)))

