#lang rosette

(require "packet.rkt" "symopt.rkt")
(require rosette/base/core/union)

(provide
  init-buffer

  symopt-buffer!
  pushTo-buffer!
  popFrom-buffer!
  buffer-head

  (all-from-out "packet.rkt"))

(define DEBUG_SYMOPT #f)


(struct buffer (buf) #:mutable #:transparent)
(define (init-buffer) (buffer (list)))


(define (symopt-buffer! buffer)

  (when DEBUG_SYMOPT (println "--------------------------------------------------"))
  (when DEBUG_SYMOPT (println "before symopt: symopt-buffer!"))
  (when DEBUG_SYMOPT (println buffer))

  (define (symopt-union! union)
    (when (union? union)
      (define (guardKey-simple guardKey)
        (cons
          (expr-simple (car guardKey) DEBUG_SYMOPT)
          (packet-simple (cdr guardKey) DEBUG_SYMOPT)))
      (define union-contents-old (union-contents union))
      (define union-contents-new (map guardKey-simple union-contents-old))
      (set-union-contents! union union-contents-new)))
  (for-each symopt-union! (buffer-buf buffer))

  (when DEBUG_SYMOPT (println "after symopt: symopt-buffer!"))
  (when DEBUG_SYMOPT (println buffer))
  (when DEBUG_SYMOPT (println "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"))
)


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

