#lang rosette

(provide 
  init-vertexMap

  addTxTo-vertexMap!
  extractTxFrom-vertexMap!)


(struct vertexMap (map) #:mutable #:transparent)
(define (init-vertexMap) (vertexMap (list)))


(define (addTxTo-vertexMap! vertexMap vertexID_Shaper vertexID_Tx)
  ;(assert (not (findf
  ;  (lambda (pair) (equal? (car pair) vertexID_Shaper))
  ;  (vertexMap-map vertexMap))))
  (set-vertexMap-map! vertexMap
    (append (vertexMap-map vertexMap) (list (cons vertexID_Shaper vertexID_Tx)))))

(define (extractTxFrom-vertexMap! vertexMap vertexID_Shaper)
  (define vertexIDPair (findf
    (lambda (pair) (equal? (car pair) vertexID_Shaper))
    (vertexMap-map vertexMap)))
  (if (equal? #f vertexIDPair)
    (void)
    (begin
      (set-vertexMap-map! vertexMap (remove vertexIDPair (vertexMap-map vertexMap)))
      (cdr vertexIDPair))))


(define (testMe)
  (define vertexMap (init-vertexMap))
  (addTxTo-vertexMap! vertexMap 1 10)
  (println vertexMap)
  (addTxTo-vertexMap! vertexMap 2 20)
  (println vertexMap)
  (println (extractTxFrom-vertexMap! vertexMap 1))
  (println (extractTxFrom-vertexMap! vertexMap 3))
  (println vertexMap))

;(testMe)

