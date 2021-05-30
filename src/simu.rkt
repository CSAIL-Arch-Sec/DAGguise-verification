#lang rosette

(require "state.rkt")


(define state (initState))

(define (simu state)
  ; nickname
  (define dagState_TR (state_t-dagState_TR state))
  (define obuf_TR (state_t-obuf_TR state))
  (define dagState_SH (state_t-dagState_SH state))
  (define obuf_SH (state_t-obuf_SH state))
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
            (set-packet_t-address! packet_SH (packet_t-address packet_TR)))
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
  (if accept_RC (updateWithReq SCH (pop obuf_RC)) (void))

  ; update clk
  (updateClk_dag dagState_TR)
  (updateClk_dag dagState_SH)
  (updateClk_dag dagState_RC)
  (updateClk_SCH SCH)

  ; recursive next cycle
  (println state)
  (simu state))


(define (testMe)
  (simu state))

(testMe)

