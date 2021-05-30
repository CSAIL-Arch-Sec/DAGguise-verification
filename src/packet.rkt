#lang rosette

(provide
  (struct-out packet_t)
  core_SH
  core_RC)


(struct packet_t (coreID nodeID address tag) #:mutable #:transparent)


(define core_SH 0)
(define core_RC 1)

