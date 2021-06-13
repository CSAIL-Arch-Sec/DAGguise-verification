#lang rosette

(provide
  (struct-out packet)
  core_SH
  core_RC)


(struct packet (coreID nodeID address tag) #:mutable #:transparent)


(define core_SH 0)
(define core_RC 1)

