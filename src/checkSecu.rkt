#lang rosette

(require "simu.rkt")

(define (checkSecu_init MAXCLK TAG_SIZE INTERVAL_SIZE_SHAPER INTERVAL_SIZE_SCHEDULER)

  ; STEP1: init the state
  ; concrete: shaper, scheduler
  ; symbolic: whether Tx/Rx send req at each cycle, and the tag
  (define-symbolic sec1 sec2 recv (bitvector (* (+ 1 TAG_SIZE) MAXCLK)))
  
  (define state1 (concrete:init-state
    (sym:init-dagState sec1 CORE_Shaper 0 TAG_SIZE)
    (fixRate:init-dagState CORE_Shaper (- (expt 2 INTERVAL_SIZE_SHAPER) 1) TAG_SIZE)
    (sym:init-dagState recv CORE_Rx (+ 1 MAXCLK) TAG_SIZE)
    (fixRate:init-scheduler (- (expt 2 INTERVAL_SIZE_SCHEDULER) 1) (+ 1 MAXCLK) TAG_SIZE)
  ))
  (define state2 (concrete:init-state
    (sym:init-dagState sec2 CORE_Shaper 0 TAG_SIZE)
    (fixRate:init-dagState CORE_Shaper (- (expt 2 INTERVAL_SIZE_SHAPER) 1) TAG_SIZE)
    (sym:init-dagState recv CORE_Rx (+ 1 MAXCLK) TAG_SIZE)
    (fixRate:init-scheduler (- (expt 2 INTERVAL_SIZE_SCHEDULER) 1) (+ 1 MAXCLK) TAG_SIZE)
  ))


  ; STEP2: simu for K cycles
  (simu state1 MAXCLK)
  (println "---------------------------")
  (simu state2 MAXCLK)
  (println "---------------------------")


  ; STEP3: assert for the receiver observation (check secure)
  (define startTime (current-seconds))
  (define sol
    (verify (assert (&& (equal? (dagState-respHistory (state-dagState_Rx state1)) (dagState-respHistory (state-dagState_Rx state2)))
                        (equal? (scheduler-reqHistory (state-scheduler state1)) (scheduler-reqHistory (state-scheduler state2))))))
  )
  (println sol)
  (print "Time for SMT solver: ") (print (/ (- (current-seconds) startTime) 60.0)) (println "min")
)

(define (checkSecu_induct MAXCLK TAG_SIZE INTERVAL_SIZE_SHAPER INTERVAL_SIZE_SCHEDULER)

  ; STEP1: init the state
  ; concrete: shaper, scheduler
  ; symbolic: whether Tx/Rx send req at each cycle, and the tag
  (define-symbolic sec1 sec2 recv (bitvector (* (+ 1 TAG_SIZE) (+ 1 MAXCLK))))
  
  (define state1 (concrete:init-state
    (sym:init-dagState sec1 CORE_Shaper 0 TAG_SIZE)
    (fixRate:init-dagState CORE_Shaper (- (expt 2 INTERVAL_SIZE_SHAPER) 1) TAG_SIZE)
    (sym:init-dagState recv CORE_Rx 2 TAG_SIZE)
    (fixRate:init-scheduler (- (expt 2 INTERVAL_SIZE_SCHEDULER) 1) 2 TAG_SIZE)
  ))
  (define state2 (concrete:init-state
    (sym:init-dagState sec2 CORE_Shaper 0 TAG_SIZE)
    (fixRate:init-dagState CORE_Shaper (- (expt 2 INTERVAL_SIZE_SHAPER) 1) TAG_SIZE)
    (sym:init-dagState recv CORE_Rx 2 TAG_SIZE)
    (fixRate:init-scheduler (- (expt 2 INTERVAL_SIZE_SCHEDULER) 1) 2 TAG_SIZE)
  ))


  ; STEP2: set the state with symbolic value
  ; symbolic: shaper's state
  ; TODO: should set into a compete symbolic state
  (define-symbolic cycleForNext_Shaper1 cycleForNext_Shaper2 (bitvector 2))
  (define-symbolic tagID_Shaper1 tagID_Shaper2 (bitvector TAG_SIZE))

  (fixRate:set-dagState! (state-dagState_Shaper state1) (bitvector->natural cycleForNext_Shaper1) tagID_Shaper1)
  (fixRate:set-dagState! (state-dagState_Shaper state2) (bitvector->natural cycleForNext_Shaper2) tagID_Shaper2)


  ; STEP3: assume for K cycles
  (println "---------------------------")
  (println "assume K cycles")
  (define (assumeK state1 state2 MAXCLK)
    (simu state1 1)
    (simu state2 1)
    (assume (equal? (dagState-respHistory (state-dagState_Rx state1)) (dagState-respHistory (state-dagState_Rx state2))))
    (assume (equal? (scheduler-reqHistory (state-scheduler state1)) (scheduler-reqHistory (state-scheduler state2))))
    (unless (equal? 1 MAXCLK) (assumeK state1 state2 (- MAXCLK 1)))
  )
  (assumeK state1 state2 MAXCLK)


  ; STEP4: assert for 1 cycle (check secure)
  (println "---------------------------")
  (println "assert 1 cycle")
  (simu state1 1)
  (simu state2 1)

  (define startTime (current-seconds))
  (define sol
    (verify (assert (&& (equal? (dagState-respHistory (state-dagState_Rx state1)) (dagState-respHistory (state-dagState_Rx state2)))
                        (equal? (scheduler-reqHistory (state-scheduler state1)) (scheduler-reqHistory (state-scheduler state2))))))
  )
  (println sol)
  (print "Time for SMT solver: ") (print (/ (- (current-seconds) startTime) 60.0)) (println "min")
)


; - concrete implementations:
;   - TAG_SIZE
;   - INTERVAL_SIZE_SHAPER
;   - INTERVAL_SIZE_SCHEDULER
; - k-induction's k
;   - arg-cycle
(define (testMe)
  (define arg-cycle 4)
  (define TAG_SIZE 1) (define INTERVAL_SIZE_SHAPER 2) (define INTERVAL_SIZE_SCHEDULER 1)
  (command-line
    #:once-each
    [("--cycle") v "Number of cycles to simulate"
                   (set! arg-cycle (string->number v))]
  )
  (print "Run with args: --cycle:") (print arg-cycle)
  
  (checkSecu_init arg-cycle TAG_SIZE INTERVAL_SIZE_SHAPER INTERVAL_SIZE_SCHEDULER)
  (checkSecu_induct arg-cycle TAG_SIZE INTERVAL_SIZE_SHAPER INTERVAL_SIZE_SCHEDULER)
)

(testMe)

