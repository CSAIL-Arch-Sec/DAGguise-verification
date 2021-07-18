#lang rosette

(require
  "state.rkt"
  "observation.rkt")

(provide
  simu)


(define (simu state observation MAXCLK)
  ; nickname (NOTE: this will not be updated within this clk)
  (define clk (state-clk state))
  (define dagState_TR (state-dagState_TR state))
  (define obuf_TR (state-obuf_TR state))
  (define dagState_SH (state-dagState_SH state))
  (define obuf_SH (state-obuf_SH state))
  (define nodeMap (state-nodeMap state))
  (define dagState_RC (state-dagState_RC state))
  (define obuf_RC (state-obuf_RC state))
  (define scheduler (state-scheduler state))

  ; in TR
  (let ([packet (dagState-req dagState_TR)])
    (unless (equal? (void) packet) (pushTo-obuf! obuf_TR packet)))

  ; TR to SH
  (let [(packet_SH (dagState-req dagState_SH))]
    (unless (equal? (void) packet_SH)
      (begin
        (when (and (not (equal? (void) (obuf-head obuf_TR)))
                   (equal? (packet-tag (obuf-head obuf_TR)) (packet-tag packet_SH)))
          (let ([packet_TR (popFrom-obuf! obuf_TR)])
            (set-packet-address! packet_SH (packet-address packet_TR))
            (addTRTo-nodeMap! nodeMap (packet-nodeID packet_TR) (packet-nodeID packet_SH))))
        (pushTo-obuf! obuf_SH packet_SH))))

  ; in RC
  (let ([packet (dagState-req dagState_RC)])
    (unless (equal? (void) packet) (pushTo-obuf! obuf_RC packet)))

  ; SH/RC to scheduler
  (match-define (list accept_SH accept_RC)
    (scheduler-canAccept scheduler
      (not (equal? (void) (obuf-head obuf_SH)))
      (not (equal? (void) (obuf-head obuf_RC)))))
  (when accept_SH (simuReqFor-scheduler! scheduler (popFrom-obuf! obuf_SH)))
  (when accept_RC (simuReqFor-scheduler! scheduler (popFrom-obuf! obuf_RC)))

  ; scheduler to SH/RC
  (match-define (list resp_SH resp_RC) (scheduler-resp scheduler))
  (unless (equal? (void) resp_SH)
    (begin
      (simuRespFor-dagState! dagState_SH (packet-nodeID resp_SH))
      (let ([nodeID_TR (extractTRFrom-nodeMap! nodeMap (packet-nodeID resp_SH))])
        (if (equal? (void) nodeID_TR)
          (void)
          (simuRespFor-dagState! dagState_SH nodeID_TR)))))
  (unless (equal? (void) resp_RC)
    (begin
      (simuRespFor-dagState! dagState_RC (packet-nodeID resp_RC))
      (addLogTo-observation! observation clk)))

  ; update clk
  (set-state-clk! state (+ 1 clk))
  (incClkFor-dagState! dagState_TR)
  (incClkFor-dagState! dagState_SH)
  (incClkFor-dagState! dagState_RC)
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

