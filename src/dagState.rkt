#lang rosette

(require "packet.rkt")

(provide
  initDagState

  updateWithResp
  updateClk_dag
  getReq
  
  (all-from-out "packet.rkt"))


(struct dagState_t (cycleForNext coreID) #:mutable #:transparent)
(define (initDagState coreID) (dagState_t 0 coreID))


(define INIT_CYCLE 3)



(define (updateWithResp dagState nodeID)
  (void))

(define (updateClk_dag dagState)
  (if (equal? 0 (dagState_t-cycleForNext dagState))
    (set-dagState_t-cycleForNext! dagState INIT_CYCLE)
    (set-dagState_t-cycleForNext! dagState (- (dagState_t-cycleForNext dagState) 1))))

(define (getReq dagState)
  (if (equal? 0 (dagState_t-cycleForNext dagState))
    (packet_t (dagState_t-coreID dagState) 0 0 0)
    (void)))


(define (testMe)
  (define dagState (initDagState core_SH))
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

(testMe)
