#lang rosette

(require "packet.rkt")

(provide
  init-dagState

  simuRespFor-dagState!
  incClkFor-dagState!
  dagState-req
  
  (all-from-out "packet.rkt"))


;cycleForNext - will send a request after cycleForNext
;nodeID - the ID of next sent request, unique for each req/resp pair
;coreID - const - all sent packet will be labeled with coreID, unique for each core/dag
;interval - const - send request every interval cycles
(struct dagState (cycleForNext nodeID coreID interval) #:mutable #:transparent)
(define (init-dagState coreID interval) (dagState 0 0 coreID interval))

(define (simuRespFor-dagState! dagState nodeID)
  (void))

(define (incClkFor-dagState! dagState)
  (if (equal? 0 (dagState-cycleForNext dagState))
    (set-dagState-cycleForNext! dagState (dagState-interval dagState))
    (set-dagState-cycleForNext! dagState (- (dagState-cycleForNext dagState) 1))))

(define (dagState-req dagState)
  (if (equal? 0 (dagState-cycleForNext dagState))
    (begin
      (set-dagState-nodeID! dagState (+ 1 (dagState-nodeID dagState)))
      (packet (dagState-coreID dagState) (dagState-nodeID dagState) 0 0))
    (void)))


(define (testMe)
  (define dagState (init-dagState CORE_Shaper 3))
  (simuRespFor-dagState! dagState 11111)

  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState)
  (println (dagState-req dagState))
  (incClkFor-dagState! dagState))

;(testMe)
