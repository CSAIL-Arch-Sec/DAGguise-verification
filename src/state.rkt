#lang rosette

(require
  "dagState.rkt"
  "buffer.rkt"
  "vertexMap.rkt"
  "scheduler.rkt")

(provide
  init-state
  (struct-out state)
  
  (all-from-out "dagState.rkt")
  (all-from-out "buffer.rkt")
  (all-from-out "vertexMap.rkt")
  (all-from-out "scheduler.rkt"))


;Tx - transmitter
;Rx - receiver
(struct state 
  (
    clk
    dagState_Tx buffer_Tx 
    dagState_Shaper buffer_Shaper vertexMap
    dagState_Rx buffer_Rx 
    scheduler)
  #:mutable #:transparent)
(define (init-state interval_Tx interval_Shaper interval_Rx interval_SCH) (state
  0
  (init-dagState CORE_Shaper interval_Tx) (init-buffer)
  (init-dagState CORE_Shaper interval_Shaper) (init-buffer) (init-vertexMap)
  (init-dagState CORE_Rx interval_Rx) (init-buffer)
  (init-scheduler interval_SCH)))

