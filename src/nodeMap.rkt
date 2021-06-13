#lang rosette

(provide 
  init-nodeMap

  addTR!
  extractTR!)


(struct nodeMap (map) #:mutable #:transparent)
(define (init-nodeMap) (nodeMap (list)))


(define (addTR! nodeMap nodeID_SH nodeID_TR)
  (assert (not (findf
    (lambda (pair) (equal? (car pair) nodeID_SH))
    (nodeMap-map nodeMap))))
  (set-nodeMap-map! nodeMap
    (append (nodeMap-map nodeMap) (list (cons nodeID_SH nodeID_TR)))))

(define (extractTR! nodeMap nodeID_SH)
  (define nodeIDPair (findf
    (lambda (pair) (equal? (car pair) nodeID_SH))
    (nodeMap-map nodeMap)))
  (if (equal? #f nodeIDPair)
    (void)
    (begin
      (set-nodeMap-map! nodeMap (remove nodeIDPair (nodeMap-map nodeMap)))
      (cdr nodeIDPair))))


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

