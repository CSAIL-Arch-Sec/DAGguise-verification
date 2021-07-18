#lang rosette

(provide 
  init-nodeMap

  addTRTo-nodeMap!
  extractTRFrom-nodeMap!)


(struct nodeMap (map) #:mutable #:transparent)
(define (init-nodeMap) (nodeMap (list)))


(define (addTRTo-nodeMap! nodeMap nodeID_SH nodeID_TR)
  ;(assert (not (findf
  ;  (lambda (pair) (equal? (car pair) nodeID_SH))
  ;  (nodeMap-map nodeMap))))
  (set-nodeMap-map! nodeMap
    (append (nodeMap-map nodeMap) (list (cons nodeID_SH nodeID_TR)))))

(define (extractTRFrom-nodeMap! nodeMap nodeID_SH)
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
  (addTRTo-nodeMap! nodeMap 1 10)
  (println nodeMap)
  (addTRTo-nodeMap! nodeMap 2 20)
  (println nodeMap)
  (println (extractTRFrom-nodeMap! nodeMap 1))
  (println (extractTRFrom-nodeMap! nodeMap 3))
  (println nodeMap))

;(testMe)

