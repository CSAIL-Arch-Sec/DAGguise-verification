#lang rosette

(provide
  init-obuf

  push!
  pop!
  getHead)


(struct obuf (buf) #:mutable #:transparent)
(define (init-obuf) (obuf (list)))


(define (push! obuf packet)
  (set-obuf-buf! obuf (append (obuf-buf obuf) (list packet))))

(define (pop! obuf)
  (assert (> (length (obuf-buf obuf)) 0))
  (define returnPacket (list-ref (obuf-buf obuf) 0))
  (set-obuf-buf! obuf (list-tail (obuf-buf obuf) 1))
  returnPacket)

(define (getHead obuf)
  (if (> (length (obuf-buf obuf)) 0)
    (list-ref (obuf-buf obuf) 0)
    (void)))


(require "packet.rkt")
(define (testMe)
  (define obuf (init-obuf))

  (println obuf)
  (push! obuf (packet 0 0 0 0))
  (println obuf)
  (push! obuf (packet 0 0 0 1))
  (println obuf)
  (println "-------------------")

  (define obuf2 (init-obuf))
  (print "obuf2 should be different")
  (println obuf2)
  (println "-------------------")

  (println obuf)
  (println (getHead obuf))
  (println (pop! obuf))
  (println "-------------------")
  (println obuf)
  (println (getHead obuf))
  (println (pop! obuf))
  (println "-------------------")
  (println obuf)

)

;(testMe)

