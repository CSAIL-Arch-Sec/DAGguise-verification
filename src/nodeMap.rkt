#lang rosette

(provide 
  init-nodeMap

  addTxTo-nodeMap!
  extractTxFrom-nodeMap!)


(struct nodeMap (map) #:mutable #:transparent)
(define (init-nodeMap) (nodeMap (list)))


(define (addTxTo-nodeMap! nodeMap nodeID_Shaper nodeID_Tx)
  ;(assert (not (findf
  ;  (lambda (pair) (equal? (car pair) nodeID_Shaper))
  ;  (nodeMap-map nodeMap))))
  (set-nodeMap-map! nodeMap
    (append (nodeMap-map nodeMap) (list (cons nodeID_Shaper nodeID_Tx)))))

(define (extractTxFrom-nodeMap! nodeMap nodeID_Shaper)
  (define nodeIDPair (findf
    (lambda (pair) (equal? (car pair) nodeID_Shaper))
    (nodeMap-map nodeMap)))
  (if (equal? #f nodeIDPair)
    (void)
    (begin
      (set-nodeMap-map! nodeMap (remove nodeIDPair (nodeMap-map nodeMap)))
      (cdr nodeIDPair))))


(define (testMe)
  (define nodeMap (init-nodeMap))
  (addTxTo-nodeMap! nodeMap 1 10)
  (println nodeMap)
  (addTxTo-nodeMap! nodeMap 2 20)
  (println nodeMap)
  (println (extractTxFrom-nodeMap! nodeMap 1))
  (println (extractTxFrom-nodeMap! nodeMap 3))
  (println nodeMap))

;(testMe)

