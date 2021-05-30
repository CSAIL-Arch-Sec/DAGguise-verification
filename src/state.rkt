#lang rosette

(require
  "dagState.rkt"
  "obuf.rkt"
  "SCH.rkt")

(provide
  initState
  (struct-out state_t)
  (all-from-out "dagState.rkt")
  (all-from-out "obuf.rkt")
  (all-from-out "SCH.rkt"))


(struct state_t 
  (dagState_TR obuf_TR 
    dagState_SH obuf_SH 
    dagState_RC obuf_RC 
    SCH)
  #:mutable #:transparent)
(define (initState) (state_t
  (initDagState core_SH) (initObuf)
  (initDagState core_SH) (initObuf)
  (initDagState core_RC) (initObuf)
  (initSCH)))

