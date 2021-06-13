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
  (let ([packet (getReq dagState_TR)])
    (if (equal? (void) packet) (void) (push! obuf_TR packet)))

  ; TR to SH
  (let [(packet_SH (getReq dagState_SH))]
    (if (equal? (void) packet_SH)
      (void)
      (begin
        (if (and (not (equal? (void) (getHead obuf_TR)))
                 (equal? (packet-tag (getHead obuf_TR)) (packet-tag packet_SH)))
          (let ([packet_TR (pop! obuf_TR)])
            (set-packet-address! packet_SH (packet-address packet_TR))
            (addTR! nodeMap (packet-nodeID packet_TR) (packet-nodeID packet_SH)))
          (void))
        (push! obuf_SH packet_SH))))

  ; in RC
  (let ([packet (getReq dagState_RC)])
    (if (equal? (void) packet) (void) (push! obuf_RC packet)))

  ; SH/RC to scheduler
  (match-define (list accept_SH accept_RC)
    (willAccept scheduler
      (not (equal? (void) (getHead obuf_SH)))
      (not (equal? (void) (getHead obuf_RC)))))
  (if accept_SH (updateWithReq! scheduler (pop! obuf_SH)) (void))
  (if accept_RC (updateWithReq! scheduler (pop! obuf_RC)) (void))

  ; scheduler to SH/RC
  (match-define (list resp_SH resp_RC) (getResp scheduler))
  (if (equal? (void) resp_SH)
    (void)
    (begin
      (updateWithResp! dagState_SH (packet-nodeID resp_SH))
      (let ([nodeID_TR (extractTR! nodeMap (packet-nodeID resp_SH))])
        (if (equal? (void) nodeID_TR)
          (void)
          (updateWithResp! dagState_SH nodeID_TR)))))
  (if (equal? (void) resp_RC)
    (void)
    (begin
      (updateWithResp! dagState_RC (packet-nodeID resp_RC))
      (addLog! observation clk)))

  ; update clk
  (set-state-clk! state (+ 1 clk))
  (updateClk_dag! dagState_TR)
  (updateClk_dag! dagState_SH)
  (updateClk_dag! dagState_RC)
  (updateClk_scheduler! scheduler)

  ; recursive next cycle
  ;(println state)
  (println observation)
  (if (equal? MAXCLK clk) (void) (simu state observation MAXCLK)))


(define (testMe)
  (define state (init-state 3 3 3 6))
  (define observation (init-observation))
  (simu state observation 100))

;(testMe)

