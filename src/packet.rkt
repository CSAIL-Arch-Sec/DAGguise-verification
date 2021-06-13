#lang rosette

(provide
  (struct-out packet)
  CORE_SH
  CORE_RC)


(struct packet (coreID nodeID address tag) #:mutable #:transparent)


(define CORE_SH 0)
(define CORE_RC 1)

