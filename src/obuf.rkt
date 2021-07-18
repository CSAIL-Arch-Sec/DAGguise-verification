#lang rosette

(provide
  init-obuf

  pushTo-obuf!
  popFrom-obuf!
  obuf-head)


(struct obuf (buf) #:mutable #:transparent)
(define (init-obuf) (obuf (list)))


(define (pushTo-obuf! obuf packet)
  (set-obuf-buf! obuf (append (obuf-buf obuf) (list packet))))

(define (popFrom-obuf! obuf)
  (assert (> (length (obuf-buf obuf)) 0))
  (define returnPacket (list-ref (obuf-buf obuf) 0))
  (set-obuf-buf! obuf (list-tail (obuf-buf obuf) 1))
  returnPacket)

(define (obuf-head obuf)
  (if (> (length (obuf-buf obuf)) 0)
    (list-ref (obuf-buf obuf) 0)
    (void)))


(require "packet.rkt")
(define (testMe)
  (define obuf (init-obuf))

  (println obuf)
  (pushTo-obuf! obuf (packet 0 0 0 0))
  (println obuf)
  (pushTo-obuf! obuf (packet 0 0 0 1))
  (println obuf)
  (println "-------------------")

  (define obuf2 (init-obuf))
  (print "obuf2 should be different")
  (println obuf2)
  (println "-------------------")

  (println obuf)
  (println (obuf-head obuf))
  (println (popFrom-obuf! obuf))
  (println "-------------------")
  (println obuf)
  (println (obuf-head obuf))
  (println (popFrom-obuf! obuf))
  (println "-------------------")
  (println obuf)

)

;(testMe)

