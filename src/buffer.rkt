#lang rosette

(provide
  init-buffer

  pushTo-buffer!
  popFrom-buffer!
  buffer-head)


(struct buffer (buf) #:mutable #:transparent)
(define (init-buffer) (buffer (list)))


(define (pushTo-buffer! buffer packet)
  (set-buffer-buf! buffer (append (buffer-buf buffer) (list packet))))

(define (popFrom-buffer! buffer)
  (assert (> (length (buffer-buf buffer)) 0))
  (define returnPacket (list-ref (buffer-buf buffer) 0))
  (set-buffer-buf! buffer (list-tail (buffer-buf buffer) 1))
  returnPacket)

(define (buffer-head buffer)
  (if (> (length (buffer-buf buffer)) 0)
    (list-ref (buffer-buf buffer) 0)
    (void)))


(require "packet.rkt")
(define (testMe)
  (define buffer (init-buffer))

  (println buffer)
  (pushTo-buffer! buffer (packet 0 0 0 0))
  (println buffer)
  (pushTo-buffer! buffer (packet 0 0 0 1))
  (println buffer)
  (println "-------------------")

  (define buffer2 (init-buffer))
  (print "buffer2 should be different")
  (println buffer2)
  (println "-------------------")

  (println buffer)
  (println (buffer-head buffer))
  (println (popFrom-buffer! buffer))
  (println "-------------------")
  (println buffer)
  (println (buffer-head buffer))
  (println (popFrom-buffer! buffer))
  (println "-------------------")
  (println buffer)

)

;(testMe)

