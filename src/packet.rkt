#lang rosette

(require "symopt.rkt")

(provide
  (struct-out packet)
  packet-simple
  
  CORE_Shaper
  CORE_Rx)

(define CORE_Shaper 0)
(define CORE_Rx 1)
(define DEBUG_SYMOPT #f)


;coreID - who send this packet
;vertexID - used to match req/resp
;address - not used yet
;tag - used for scheduler, for bank conflict, not used yet
(struct packet (coreID vertexID address tag) #:mutable #:transparent)


(define (packet-simple complexPacket)
  (packet
    (packet-coreID complexPacket)
    (expr-simple (packet-vertexID complexPacket))
    (packet-address complexPacket)
    (packet-tag complexPacket)))
