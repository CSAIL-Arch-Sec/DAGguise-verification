#lang rosette

(require
  "dagState.rkt"
  "obuf.rkt"
  "nodeMap.rkt"
  "scheduler.rkt")

(provide
  init-state
  (struct-out state)
  (all-from-out "dagState.rkt")
  (all-from-out "obuf.rkt")
  (all-from-out "nodeMap.rkt")
  (all-from-out "scheduler.rkt"))


(struct state 
  (
    clk
    dagState_TR obuf_TR 
    dagState_SH obuf_SH nodeMap
    dagState_RC obuf_RC 
    scheduler)
  #:mutable #:transparent)
(define (init-state interval_TR interval_SH interval_RC interval_SCH) (state
  0
  (init-dagState core_SH interval_TR) (init-obuf)
  (init-dagState core_SH interval_SH) (init-obuf) (init-nodeMap)
  (init-dagState core_RC interval_RC) (init-obuf)
  (init-scheduler interval_SCH)))

