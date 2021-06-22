#lang rosette

(provide
  (struct-out packet)
  CORE_SH
  CORE_RC)


;coreID - who send this packet
;nodeID - used to match req/resp
;address - not used yet
;tag - used for scheduler, for bank conflict, not used yet
(struct packet (coreID nodeID address tag) #:mutable #:transparent)


(define CORE_SH 0)
(define CORE_RC 1)

