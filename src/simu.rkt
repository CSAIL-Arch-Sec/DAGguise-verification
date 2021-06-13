#lang rosette

(require
  "state.rkt"
  "observe.rkt")

(provide
  simu)


(define (simu state observe MAXCLK)
  ; nickname (NOTE: this will not be updated within this clk)
  (define clk (state_t-clk state))
  (define dagState_TR (state_t-dagState_TR state))
  (define obuf_TR (state_t-obuf_TR state))
  (define dagState_SH (state_t-dagState_SH state))
  (define obuf_SH (state_t-obuf_SH state))
  (define nodeMap (state_t-nodeMap state))
  (define dagState_RC (state_t-dagState_RC state))
  (define obuf_RC (state_t-obuf_RC state))
  (define SCH (state_t-SCH state))

  ; in TR
  (let ([packet (getReq dagState_TR)])
    (if (equal? (void) packet) (void) (push obuf_TR packet)))

  ; TR to SH
  (let [(packet_SH (getReq dagState_SH))]
    (if (equal? (void) packet_SH)
      (void)
      (begin
        (if (and (not (equal? (void) (getHead obuf_TR)))
                 (equal? (packet_t-tag (getHead obuf_TR)) (packet_t-tag packet_SH)))
          (let ([packet_TR (pop obuf_TR)])
            (set-packet_t-address! packet_SH (packet_t-address packet_TR))
            (addTR nodeMap (packet_t-nodeID packet_TR) (packet_t-nodeID packet_SH)))
          (void))
        (push obuf_SH packet_SH))))

  ; in RC
  (let ([packet (getReq dagState_RC)])
    (if (equal? (void) packet) (void) (push obuf_RC packet)))

  ; SH/RC to SCH
  (match-define (list accept_SH accept_RC)
    (willAccept SCH
      (not (equal? (void) (getHead obuf_SH)))
      (not (equal? (void) (getHead obuf_RC)))))
  (if accept_SH (updateWithReq SCH (pop obuf_SH)) (void))
  (println obuf_RC)
  (println accept_RC)
  (println SCH)
  (if accept_RC (updateWithReq SCH (pop obuf_RC)) (void))
  (println SCH)
  ; a ui for debugging

  ; SCH to SH/RC
  (match-define (list resp_SH resp_RC) (getResp SCH))
  (if (equal? (void) resp_SH)
    (void)
    (begin
      (updateWithResp dagState_SH (packet_t-nodeID resp_SH))
      (let ([nodeID_TR (extractTR nodeMap (packet_t-nodeID resp_SH))])
        (if (equal? (void) nodeID_TR)
          (void)
          (updateWithResp dagState_SH nodeID_TR)))))
  (if (equal? (void) resp_RC)
    (void)
    (begin
      (updateWithResp dagState_RC (packet_t-nodeID resp_RC))
      (addLog observe clk)))

  ; update clk
  (set-state_t-clk! state (+ 1 clk))
  (updateClk_dag dagState_TR)
  (updateClk_dag dagState_SH)
  (updateClk_dag dagState_RC)
  (updateClk_SCH SCH)

  ; recursive next cycle
  (println state)
  (println observe)
  (if (equal? MAXCLK clk) (void) (simu state observe MAXCLK)))


(define (testMe)
  (define state (initState 3 3 3 6))
  (define observe (initObserve))
  (simu state observe 100))

;(testMe)

