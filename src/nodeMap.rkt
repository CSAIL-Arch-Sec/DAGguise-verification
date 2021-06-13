#lang rosette

(provide 
  init-nodeMap

  addTR!
  extractTR!)

(struct nodeMap (map) #:mutable #:transparent)
(define (init-nodeMap) (nodeMap (make-hash)))


(define (addTR! nodeMap nodeID_SH nodeID_TR)
  (assert (not (hash-has-key? (nodeMap-map nodeMap) nodeID_SH)))
  (hash-set! (nodeMap-map nodeMap) nodeID_SH nodeID_TR))

(define (extractTR! nodeMap nodeID_SH)
  (define nodeID_TR (hash-ref (nodeMap-map nodeMap) nodeID_SH (void)))
  (if (equal? (void) nodeID_TR)
    (void)
    (hash-remove! (nodeMap-map nodeMap) nodeID_SH))
  nodeID_TR)


(define (testMe)
  (define nodeMap (init-nodeMap))
  (addTR! nodeMap 1 10)
  (println nodeMap)
  (addTR! nodeMap 2 20)
  (println nodeMap)
  (println (extractTR! nodeMap 1))
  (println (extractTR! nodeMap 3))
  (println nodeMap))

;(testMe)

