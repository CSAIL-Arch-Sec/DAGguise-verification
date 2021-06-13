#lang rosette

(require "packet.rkt")

(provide
  initDagState

  updateWithResp
  updateClk_dag
  getReq
  
  (all-from-out "packet.rkt"))

; comments are important for struct 
; check the convension of comments
(struct dagState_t (cycleForNext coreID interval nodeID) #:mutable #:transparent)
(define (initDagState coreID interval) (dagState_t 0 coreID interval 0))

; add !
(define (updateWithResp dagState nodeID)
  (void))

(define (updateClk_dag dagState)
  (if (equal? 0 (dagState_t-cycleForNext dagState))
    (set-dagState_t-cycleForNext! dagState (dagState_t-interval dagState))
    (set-dagState_t-cycleForNext! dagState (- (dagState_t-cycleForNext dagState) 1))))

(define (getReq dagState)
  (if (equal? 0 (dagState_t-cycleForNext dagState))
    (begin
      (set-dagState_t-nodeID! dagState (+ 1 (dagState_t-nodeID dagState)))
      (packet_t (dagState_t-coreID dagState) (dagState_t-nodeID dagState) 0 0))
    (void)))


(define (testMe)
  (define dagState (initDagState core_SH 3))
  (updateWithResp dagState 11111)

  (println (getReq dagState))
  (updateClk_dag dagState)
  (println (getReq dagState))
  (updateClk_dag dagState)
  (println (getReq dagState))
  (updateClk_dag dagState)
  (println (getReq dagState))
  (updateClk_dag dagState)
  (println (getReq dagState))
  (updateClk_dag dagState))

;(testMe)
