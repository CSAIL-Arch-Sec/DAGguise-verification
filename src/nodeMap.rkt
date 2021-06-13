#lang rosette

(provide 
  initNodeMap

  addTR
  extractTR)

(struct nodeMap_t (map) #:mutable #:transparent)
(define (initNodeMap) (nodeMap_t (make-hash)))


(define (addTR nodeMap nodeID_SH nodeID_TR)
  (assert (not (hash-has-key? (nodeMap_t-map nodeMap) nodeID_SH)))
  (hash-set! (nodeMap_t-map nodeMap) nodeID_SH nodeID_TR))

(define (extractTR nodeMap nodeID_SH)
  (define nodeID_TR (hash-ref (nodeMap_t-map nodeMap) nodeID_SH (void)))
  (if (equal? (void) nodeID_TR)
    (void)
    (hash-remove! (nodeMap_t-map nodeMap) nodeID_SH))
  nodeID_TR)


(define (testMe)
  (define nodeMap (initNodeMap))
  (addTR nodeMap 1 10)
  (println nodeMap)
  (addTR nodeMap 2 20)
  (println nodeMap)
  (println (extractTR nodeMap 1))
  (println (extractTR nodeMap 3))
  (println nodeMap))

;(testMe)

