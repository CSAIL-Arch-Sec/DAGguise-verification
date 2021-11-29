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
(define (init-state dagState_Tx dagState_Shaper dagState_Rx scheduler)
  (state
    0
    dagState_Tx (init-buffer)
    dagState_Shaper (init-buffer) (init-vertexMap)
    dagState_Rx (init-buffer)
    scheduler)
)

