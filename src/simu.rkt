#lang rosette

(require
  "state.rkt"
  "observation.rkt")

(provide
  simu)


(define (simu state observation MAXCLK)
  ; nickname (NOTE: this will not be updated within this clk)
  (define clk (state-clk state))
  (define dagState_Tx (state-dagState_Tx state))
  (define obuf_Tx (state-obuf_Tx state))
  (define dagState_Shaper (state-dagState_Shaper state))
  (define obuf_Shaper (state-obuf_Shaper state))
  (define nodeMap (state-nodeMap state))
  (define dagState_Rx (state-dagState_Rx state))
  (define obuf_Rx (state-obuf_Rx state))
  (define scheduler (state-scheduler state))

  ; in transmitter
  (let ([packet (dagState-req dagState_Tx)])
    (unless (equal? (void) packet) (pushTo-obuf! obuf_Tx packet)))

  ; transmitter to shaper
  (let [(packet_Shaper (dagState-req dagState_Shaper))]
    (unless (equal? (void) packet_Shaper)
      (begin
        (when (and (not (equal? (void) (obuf-head obuf_Tx)))
                   (equal? (packet-tag (obuf-head obuf_Tx)) (packet-tag packet_Shaper)))
          (let ([packet_Tx (popFrom-obuf! obuf_Tx)])
            (set-packet-address! packet_Shaper (packet-address packet_Tx))
            (addTxTo-nodeMap! nodeMap (packet-nodeID packet_Tx) (packet-nodeID packet_Shaper))))
        (pushTo-obuf! obuf_Shaper packet_Shaper))))

  ; in receiver
  (let ([packet (dagState-req dagState_Rx)])
    (unless (equal? (void) packet) (pushTo-obuf! obuf_Rx packet)))

  ; shaper/receiver to scheduler
  (match-define (list accept_Shaper accept_Rx)
    (scheduler-canAccept scheduler
      (not (equal? (void) (obuf-head obuf_Shaper)))
      (not (equal? (void) (obuf-head obuf_Rx)))))
  (when accept_Shaper (simuReqFor-scheduler! scheduler (popFrom-obuf! obuf_Shaper)))
  (when accept_Rx (simuReqFor-scheduler! scheduler (popFrom-obuf! obuf_Rx)))

  ; scheduler to shaper/receiver
  (match-define (list resp_Shaper resp_Rx) (scheduler-resp scheduler))
  (unless (equal? (void) resp_Shaper)
    (begin
      (simuRespFor-dagState! dagState_Shaper (packet-nodeID resp_Shaper))
      (let ([nodeID_Tx (extractTxFrom-nodeMap! nodeMap (packet-nodeID resp_Shaper))])
        (if (equal? (void) nodeID_Tx)
          (void)
          (simuRespFor-dagState! dagState_Shaper nodeID_Tx)))))
  (unless (equal? (void) resp_Rx)
    (begin
      (simuRespFor-dagState! dagState_Rx (packet-nodeID resp_Rx))
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

