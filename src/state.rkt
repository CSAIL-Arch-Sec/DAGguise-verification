#lang rosette

(require
  "dagState.rkt"
  "buffer.rkt"
  "vertexMap.rkt"
  "scheduler.rkt"
  (prefix-in concrete: "stateConcrete.rkt")
  (prefix-in symbolic: "stateSymbolic.rkt"))

(provide
  concrete:init-state
  symbolic:init-state
  state-clk
  state-dagState_Tx
  state-buffer_Tx
  state-dagState_Shaper
  state-buffer_Shaper
  state-vertexMap
  state-dagState_Rx
  state-buffer_Rx
  state-scheduler
  set-state-clk!
  
  (all-from-out "dagState.rkt")
  (all-from-out "buffer.rkt")
  (all-from-out "vertexMap.rkt")
  (all-from-out "scheduler.rkt"))


(define (state-clk . args)
  (match (car args)
    [(struct concrete:state _) (apply concrete:state-clk args)]
    [(struct symbolic:state _) (apply symbolic:state-clk args)])
)

(define (state-dagState_Tx . args)
  (match (car args)
    [(struct concrete:state _) (apply concrete:state-dagState_Tx args)]
    [(struct symbolic:state _) (apply symbolic:state-dagState_Tx args)])
)

(define (state-buffer_Tx . args)
  (match (car args)
    [(struct concrete:state _) (apply concrete:state-buffer_Tx args)]
    [(struct symbolic:state _) (apply symbolic:state-buffer_Tx args)])
)

(define (state-dagState_Shaper . args)
  (match (car args)
    [(struct concrete:state _) (apply concrete:state-dagState_Shaper args)]
    [(struct symbolic:state _) (apply symbolic:state-dagState_Shaper args)])
)

(define (state-buffer_Shaper . args)
  (match (car args)
    [(struct concrete:state _) (apply concrete:state-buffer_Shaper args)]
    [(struct symbolic:state _) (apply symbolic:state-buffer_Shaper args)])
)

(define (state-vertexMap . args)
  (match (car args)
    [(struct concrete:state _) (apply concrete:state-vertexMap args)]
    [(struct symbolic:state _) (apply symbolic:state-vertexMap args)])
)

(define (state-dagState_Rx . args)
  (match (car args)
    [(struct concrete:state _) (apply concrete:state-dagState_Rx args)]
    [(struct symbolic:state _) (apply symbolic:state-dagState_Rx args)])
)

(define (state-buffer_Rx . args)
  (match (car args)
    [(struct concrete:state _) (apply concrete:state-buffer_Rx args)]
    [(struct symbolic:state _) (apply symbolic:state-buffer_Rx args)])
)

(define (state-scheduler . args)
  (match (car args)
    [(struct concrete:state _) (apply concrete:state-scheduler args)]
    [(struct symbolic:state _) (apply symbolic:state-scheduler args)])
)

(define (set-state-clk! . args)
  (match (car args)
    [(struct concrete:state _) (apply concrete:set-state-clk! args)]
    [(struct symbolic:state _) (apply symbolic:set-state-clk! args)])
)

