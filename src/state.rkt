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


;Tx - transmitter
;Rx - receiver
(struct state 
  (
    clk
    dagState_Tx obuf_Tx 
    dagState_Shaper obuf_Shaper nodeMap
    dagState_Rx obuf_Rx 
    scheduler)
  #:mutable #:transparent)
(define (init-state interval_Tx interval_Shaper interval_Rx interval_SCH) (state
  0
  (init-dagState CORE_Shaper interval_Tx) (init-obuf)
  (init-dagState CORE_Shaper interval_Shaper) (init-obuf) (init-nodeMap)
  (init-dagState CORE_Rx interval_Rx) (init-obuf)
  (init-scheduler interval_SCH)))

