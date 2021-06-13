#lang rosette

(require "packet.rkt")

(provide
  init-dagState

  updateWithResp!
  updateClk_dag!
  getReq
  
  (all-from-out "packet.rkt"))

(struct dagState (cycleForNext coreID interval nodeID) #:mutable #:transparent)
(define (init-dagState coreID interval) (dagState 0 coreID interval 0))

(define (updateWithResp! dagState nodeID)
  (void))

(define (updateClk_dag! dagState)
  (if (equal? 0 (dagState-cycleForNext dagState))
    (set-dagState-cycleForNext! dagState (dagState-interval dagState))
    (set-dagState-cycleForNext! dagState (- (dagState-cycleForNext dagState) 1))))

(define (getReq dagState)
  (if (equal? 0 (dagState-cycleForNext dagState))
    (begin
      (set-dagState-nodeID! dagState (+ 1 (dagState-nodeID dagState)))
      (packet (dagState-coreID dagState) (dagState-nodeID dagState) 0 0))
    (void)))


(define (testMe)
  (define dagState (init-dagState core_SH 3))
  (updateWithResp! dagState 11111)

  (println (getReq dagState))
  (updateClk_dag! dagState)
  (println (getReq dagState))
  (updateClk_dag! dagState)
  (println (getReq dagState))
  (updateClk_dag! dagState)
  (println (getReq dagState))
  (updateClk_dag! dagState)
  (println (getReq dagState))
  (updateClk_dag! dagState))

;(testMe)
