#lang rosette

(provide
  initObuf

  push
  pop
  getHead)


(struct obuf_t (buf) #:mutable #:transparent)
(define (initObuf) (obuf_t (list)))


(define (push obuf packet)
  (set-obuf_t-buf! obuf (append (obuf_t-buf obuf) (list packet))))

(define (pop obuf)
  (assert (> (length (obuf_t-buf obuf)) 0))
  (define returnPacket (list-ref (obuf_t-buf obuf) 0))
  (set-obuf_t-buf! obuf (list-tail (obuf_t-buf obuf) 1))
  returnPacket)

(define (getHead obuf)
  (if (> (length (obuf_t-buf obuf)) 0)
    (list-ref (obuf_t-buf obuf) 0)
    (void)))


(require "packet.rkt")  ; hope this would not be provided
(define (testMe)
  (define obuf (initObuf))

  (println obuf)
  (push obuf (packet_t 0 0 0 0))
  (println obuf)
  (push obuf (packet_t 0 0 0 1))
  (println obuf)
  (println "-------------------")

  (define obuf2 (initObuf))
  (print "obuf2 should be different")
  (println obuf2)
  (println "-------------------")

  (println obuf)
  (println (getHead obuf))
  (println (pop obuf))
  (println "-------------------")
  (println obuf)
  (println (getHead obuf))
  (println (pop obuf))
  (println "-------------------")
  (println obuf)

)

;(testMe)

