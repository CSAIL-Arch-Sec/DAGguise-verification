#lang rosette

(require "packet.rkt" "symopt.rkt")
(require rosette/base/core/union)

(provide
  init-buffer
  set-buffer!

  symopt-buffer!
  pushTo-buffer!
  popFrom-buffer!
  buffer-head

  (all-from-out "packet.rkt"))

(define DEBUG_SYMOPT #f)


(struct buffer (buf) #:mutable #:transparent)
(define (init-buffer) (buffer (list)))

(define (set-buffer! buffer buf-valid coreID buf-vertexID buf-tag)
  (set-buffer-buf! buffer
    (filter (lambda (x) (not (void? x)))
      (map (lambda (valid vertexID tag) (if valid (packet coreID (bitvector->natural vertexID) 0 tag) (void)))
           buf-valid buf-vertexID buf-tag)))
)


(define (symopt-buffer! buffer)

  (when DEBUG_SYMOPT (println "--------------------------------------------------"))
  (when DEBUG_SYMOPT (println "before symopt: symopt-buffer!"))
  (when DEBUG_SYMOPT (println buffer))

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
  (define TAG_SIZE 1)
  (define VERTEXID_SIZE 4)
  (define BUF_SIZE_DAG 2)
  (define (buf-valid)    (build-list BUF_SIZE_DAG (lambda (ingore) (define-symbolic* x boolean?)                  x)))
  (define (buf-vertexID) (build-list BUF_SIZE_DAG (lambda (ingore) (define-symbolic* x (bitvector VERTEXID_SIZE)) x)))
  (define (buf-tag)      (build-list BUF_SIZE_DAG (lambda (ingore) (define-symbolic* x (bitvector TAG_SIZE))      x)))
  (set-buffer! buffer (buf-valid) CORE_Shaper (buf-vertexID) (buf-tag))
  (println (union-contents (buffer-buf buffer)))

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

