#lang rosette

(require
  "state.rkt"
  "observation.rkt")

(provide
  simu
  
  (all-from-out "state.rkt")
  (all-from-out "observation.rkt"))


(define (simu state observation MAXCLK)
  ; nickname (NOTE: this will not be updated within this clk)
  (define clk (state-clk state))
  (define dagState_Tx (state-dagState_Tx state))
  (define buffer_Tx (state-buffer_Tx state))
  (define dagState_Shaper (state-dagState_Shaper state))
  (define buffer_Shaper (state-buffer_Shaper state))
  (define vertexMap (state-vertexMap state))
  (define dagState_Rx (state-dagState_Rx state))
  (define buffer_Rx (state-buffer_Rx state))
  (define scheduler (state-scheduler state))

  ; in transmitter
  (let ([packet (dagState-req dagState_Tx)])
    (unless (equal? (void) packet) (pushTo-buffer! buffer_Tx packet)))

  ; transmitter to shaper
  (let [(packet_Shaper (dagState-req dagState_Shaper))]
    (unless (equal? (void) packet_Shaper)
      (begin
        (when (and (not (equal? (void) (buffer-head buffer_Tx)))
                   (equal? (packet-tag (buffer-head buffer_Tx)) (packet-tag packet_Shaper)))
          (let ([packet_Tx (popFrom-buffer! buffer_Tx)])
            (set-packet-address! packet_Shaper (packet-address packet_Tx))
            (addTxTo-vertexMap! vertexMap (packet-vertexID packet_Tx) (packet-vertexID packet_Shaper))))
        (pushTo-buffer! buffer_Shaper packet_Shaper))))

  ; in receiver
  (let ([packet (dagState-req dagState_Rx)])
    (unless (equal? (void) packet) (pushTo-buffer! buffer_Rx packet)))

  ; shaper/receiver to scheduler
  (match-define (list accept_Shaper accept_Rx)
    (scheduler-canAccept scheduler
      (not (equal? (void) (buffer-head buffer_Shaper)))
      (not (equal? (void) (buffer-head buffer_Rx)))))
  (when accept_Shaper (simuReqFor-scheduler! scheduler (popFrom-buffer! buffer_Shaper)))
  (when accept_Rx (simuReqFor-scheduler! scheduler (popFrom-buffer! buffer_Rx)))

  ; scheduler to shaper/receiver
  (match-define (list resp_Shaper resp_Rx) (scheduler-resp scheduler))
  (unless (equal? (void) resp_Shaper)
    (begin
      (simuRespFor-dagState! dagState_Shaper (packet-vertexID resp_Shaper))
      (let ([vertexID_Tx (extractTxFrom-vertexMap! vertexMap (packet-vertexID resp_Shaper))])
        (if (equal? (void) vertexID_Tx)
          (void)
          (simuRespFor-dagState! dagState_Shaper vertexID_Tx)))))
  (unless (equal? (void) resp_Rx)
    (begin
      (simuRespFor-dagState! dagState_Rx (packet-vertexID resp_Rx))
      (addLogTo-observation! observation clk)))

  ; update clk
  (set-state-clk! state (+ 1 clk))
  (incClkFor-dagState! dagState_Tx)
  (incClkFor-dagState! dagState_Shaper)
  (incClkFor-dagState! dagState_Rx)
  (incClkFor-scheduler! scheduler)

  ; recursive next cycle
  ;(println state)
  (println observation)
  (unless (equal? MAXCLK clk) (simu state observation MAXCLK)))


(define (testMe)
  (define state (init-state 3 3 3 6))
  (define observation (init-observation))
  (simu state observation 100))

(testMe)

