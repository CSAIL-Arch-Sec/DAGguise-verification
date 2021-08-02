#lang rosette

(require "state.rkt")

(provide
  simu
  
  (all-from-out "state.rkt"))

(error-print-width 1000000)

(define DEBUG_SYMOPT #f)


(define (simu state MAXCLK)

  ; timer
  (define startTime (current-seconds))

  ; nickname (NOTE: this will not be updated within this clk)
  (define clk (state-clk state))
  (define dagState_Tx (state-dagState_Tx state))
  (define buffer_Tx (state-buffer_Tx state))
  (define dagState_Shaper (state-dagState_Shaper state))
  (define buffer_Shaper (state-buffer_Shaper state))
  (define vertexMap (state-vertexMap state))
  (define dagState_Rx (state-dagState_Rx state))
  (define buffer_Rx (state-buffer_Rx state))
  (define scheduler (state-scheduler state))

  ; in transmitter
  (let ([packet (dagState-req dagState_Tx)])
    (unless (void? packet) (pushTo-buffer! buffer_Tx packet)))

  ; transmitter to shaper
  (let [(packet (dagState-req dagState_Shaper))]
    (unless (void? packet)
      (begin
        (when (and (not (void? (buffer-head buffer_Tx)))
                   (equal? (packet-tag (buffer-head buffer_Tx)) (packet-tag packet)))
          (let ([packet_Tx (popFrom-buffer! buffer_Tx)])
            (set-packet-address! packet (packet-address packet_Tx))
            (addTxTo-vertexMap! vertexMap (packet-vertexID packet_Tx) (packet-vertexID packet))))
        (pushTo-buffer! buffer_Shaper packet))))

  ; in receiver
  (let ([packet (dagState-req dagState_Rx)])
    (unless (void? packet) (pushTo-buffer! buffer_Rx packet)))

  ; shaper/receiver to scheduler
  (match-define (list accept_Shaper accept_Rx)
    (scheduler-canAccept scheduler
      (not (void? (buffer-head buffer_Shaper)))
      (not (void? (buffer-head buffer_Rx)))))
  (when accept_Shaper (simuReqFor-scheduler! scheduler (popFrom-buffer! buffer_Shaper)))
  (when accept_Rx (simuReqFor-scheduler! scheduler (popFrom-buffer! buffer_Rx)))

  ; scheduler to shaper/receiver
  (match-define (list resp_Shaper resp_Rx) (scheduler-resp scheduler))

  ; NOTE: After the above line, some assert() is implicitly added into vc.
  ;       This assert is about at least one of the union guards(conditions) should hold.
  ;       This should be fine because these assert should be (and confirmed to be) always true.
  ; NOTE: Further more, these assert() will be carried on to the simulation for secret1.
  ;       This should also be fine.
  ; NOTE: In general, these assert() seems to be used to help simplify other symbolic expressions.
  
  (unless (void? resp_Shaper)
    (begin
      (simuRespFor-dagState! dagState_Shaper (packet-vertexID resp_Shaper) (packet-tag resp_Shaper))
      (let ([vertexID_Tx (extractTxFrom-vertexMap! vertexMap (packet-vertexID resp_Shaper))])
        (if (void? vertexID_Tx)
          (void)
          (simuRespFor-dagState! dagState_Shaper vertexID_Tx (packet-tag resp_Shaper))))))
  (unless (void? resp_Rx)
    (simuRespFor-dagState! dagState_Rx (packet-vertexID resp_Rx) (packet-tag resp_Rx)))

  ;(simuRespFor-dagState! dagState_Shaper 0 0)
  ; update clk
  (set-state-clk! state (+ 1 clk))
  (incClkFor-dagState! dagState_Tx)
  (incClkFor-dagState! dagState_Shaper)
  (incClkFor-dagState! dagState_Rx)
  (incClkFor-scheduler! scheduler)

  ; recursive next cycle
  (print "Time for state-") (print (state-clk state)) (print ": ") (print (/ (- (current-seconds) startTime) 60.0)) (println "min")
  ;(println state)
  ;(println "scheduler")
  ;(println scheduler)
  (unless (equal? 1 MAXCLK) (simu state (- MAXCLK 1))))


(define (testMe)
  (define state (concrete:init-state 3 3 3 6))
  (simu state 100))

;(testMe)

