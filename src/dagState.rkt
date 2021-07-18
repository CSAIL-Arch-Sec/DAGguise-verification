#lang rosette

(require "packet.rkt" "symopt.rkt")

(provide
  init-dagState

  simuRespFor-dagState!
  incClkFor-dagState!
  dagState-req
  
  (all-from-out "packet.rkt"))

(define DEBUG_SYMOPT #f)


;cycleForNext - will send a request after cycleForNext
;vertexID - the ID of next sent request, unique for each req/resp pair
;coreID - const - all sent packet will be labeled with coreID, unique for each core/dag
;interval - const - send request every interval cycles
(struct dagState (cycleForNext vertexID coreID interval) #:mutable #:transparent)
(define (init-dagState coreID interval) (dagState interval 0 coreID interval))


(define (symopt-dagState! dagState)
  (set-dagState-cycleForNext! dagState (expr-simple (dagState-cycleForNext dagState) DEBUG_SYMOPT))
  (set-dagState-vertexID! dagState (expr-simple (dagState-vertexID dagState) DEBUG_SYMOPT)))


(define (simuRespFor-dagState! dagState vertexID)
  (void))

(define (incClkFor-dagState! dagState)
  (if (equal? 0 (dagState-cycleForNext dagState))
    (set-dagState-cycleForNext! dagState (dagState-interval dagState))
    (set-dagState-cycleForNext! dagState (- (dagState-cycleForNext dagState) 1)))
  (when DEBUG_SYMOPT (println "--------------------------------------------------"))
  (when DEBUG_SYMOPT (println "before symopt: incClkFor-dagState!"))
  (when DEBUG_SYMOPT (println dagState))
  (symopt-dagState! dagState)
  (when DEBUG_SYMOPT (println "after symopt: incClkFor-dagState!"))
  (when DEBUG_SYMOPT (println dagState))
  (when DEBUG_SYMOPT (println "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"))
  )

(define (dagState-req dagState)
  (if (equal? 0 (dagState-cycleForNext dagState))
    (begin
      (set-dagState-vertexID! dagState (+ 1 (dagState-vertexID dagState)))
      (packet (dagState-coreID dagState) (dagState-vertexID dagState) 0 0))
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
