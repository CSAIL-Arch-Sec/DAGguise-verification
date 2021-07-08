#lang rosette

(provide
  (struct-out packet)
  CORE_Shaper
  CORE_Rx)


;coreID - who send this packet
;vertexID - used to match req/resp
;address - not used yet
;tag - used for scheduler, for bank conflict, not used yet
(struct packet (coreID vertexID address tag) #:mutable #:transparent)


(define CORE_Shaper 0)
(define CORE_Rx 1)

