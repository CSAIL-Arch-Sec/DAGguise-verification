#lang rosette

(require "simu.rkt")

(define (checkSecu_init MAXCLK TAG_SIZE INTERVAL_SIZE_SHAPER INTERVAL_SIZE_SCHEDULER)

  ; STEP1: init the state
  ; concrete: shaper, scheduler
  ; symbolic: whether Tx/Rx send req at each cycle, and the tag
  (define-symbolic sec1 sec2 recv (bitvector (* (+ 1 TAG_SIZE) MAXCLK)))
  
  (define state1 (init-state
    (sym:init-dagState sec1 CORE_Shaper 0 TAG_SIZE)
    (fixRate:init-dagState CORE_Shaper (- (expt 2 INTERVAL_SIZE_SHAPER) 1) TAG_SIZE)
    (sym:init-dagState recv CORE_Rx (+ 1 MAXCLK) TAG_SIZE)
    (fixRate:init-scheduler (- (expt 2 INTERVAL_SIZE_SCHEDULER) 1) (+ 1 MAXCLK) TAG_SIZE)
  ))
  (define state2 (init-state
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

(define (checkSecu_induct MAXCLK TAG_SIZE INTERVAL_SIZE_SHAPER INTERVAL_SIZE_SCHEDULER VERTEXID_SIZE BUF_SIZE_DAG BUF_SIZE_SCHEDULER)

  ; STEP1: init the state
  ; concrete: shaper, scheduler
  ; symbolic: whether Tx/Rx send req at each cycle, and the tag
  (define-symbolic sec1 sec2 recv (bitvector (* (+ 1 TAG_SIZE) (+ 1 MAXCLK))))
  
  (define state1 (init-state
    (sym:init-dagState sec1 CORE_Shaper 0 TAG_SIZE)
    (fixRate:init-dagState CORE_Shaper (- (expt 2 INTERVAL_SIZE_SHAPER) 1) TAG_SIZE)
    (sym:init-dagState recv CORE_Rx 2 TAG_SIZE)
    (fixRate:init-scheduler (- (expt 2 INTERVAL_SIZE_SCHEDULER) 1) 2 TAG_SIZE)
  ))
  (define state2 (init-state
    (sym:init-dagState sec2 CORE_Shaper 0 TAG_SIZE)
    (fixRate:init-dagState CORE_Shaper (- (expt 2 INTERVAL_SIZE_SHAPER) 1) TAG_SIZE)
    (sym:init-dagState recv CORE_Rx 2 TAG_SIZE)
    (fixRate:init-scheduler (- (expt 2 INTERVAL_SIZE_SCHEDULER) 1) 2 TAG_SIZE)
  ))


  ; STEP2: set the state with symbolic value
  ; shaper's state
  (define-symbolic pending_Shaper1 pending_Shaper2 boolean?)
  (define-symbolic cycleForNext_Shaper1 cycleForNext_Shaper2 (bitvector INTERVAL_SIZE_SHAPER))
  (define-symbolic tagID_Shaper1 tagID_Shaper2 (bitvector TAG_SIZE))
  (fixRate:set-dagState! (state-dagState_Shaper state1) pending_Shaper1 (bitvector->natural cycleForNext_Shaper1) tagID_Shaper1)
  (fixRate:set-dagState! (state-dagState_Shaper state2) pending_Shaper2 (bitvector->natural cycleForNext_Shaper2) tagID_Shaper2)

  ; helper functions to get symbolic value
  (define (symBoolList listLenth) (build-list listLenth (lambda (ingore) (define-symbolic* x boolean?) x)))
  (define (symVecList bitWidth listLenth) (build-list listLenth (lambda (ingore) (define-symbolic* x (bitvector bitWidth)) x)))

  ; scheduler: Because the induction assumption says "scheduler has same history",
  ;            scheduler state can be set to the same for 2 secrets.
  (define cycleForNext_scheduler (symVecList INTERVAL_SIZE_SCHEDULER (expt 2 TAG_SIZE)))
  (define buf_scheduler-valid    (build-list (expt 2 TAG_SIZE) (lambda (ignore) (symBoolList BUF_SIZE_SCHEDULER))))
  (define buf_scheduler-coreID (build-list (expt 2 TAG_SIZE) (lambda (ignore) (symVecList 1 BUF_SIZE_SCHEDULER))))
  (define buf_scheduler-vertexID (build-list (expt 2 TAG_SIZE) (lambda (ignore) (symVecList VERTEXID_SIZE BUF_SIZE_SCHEDULER))))
  (fixRate:set-scheduler! (state-scheduler state1) cycleForNext_scheduler buf_scheduler-valid buf_scheduler-coreID buf_scheduler-vertexID)
  (fixRate:set-scheduler! (state-scheduler state2) cycleForNext_scheduler buf_scheduler-valid buf_scheduler-coreID buf_scheduler-vertexID)

  ; Tx: state can be different for 2 secrets
  ; Rx: Because the induction assumption says "receiver has same observation (history)",
  ;     Rx state can be set to the same.

  ; Buffer_Tx/Shaper: state can be different for 2 secrets
  (define (buf-valid)    (symBoolList BUF_SIZE_DAG))
  (define (buf-vertexID) (symVecList VERTEXID_SIZE BUF_SIZE_DAG))
  (define (buf-tag)      (symVecList TAG_SIZE BUF_SIZE_DAG))
  (set-buffer! (state-buffer_Tx     state1) (buf-valid) CORE_Shaper (buf-vertexID) (buf-tag))
  (set-buffer! (state-buffer_Shaper state1) (buf-valid) CORE_Shaper (buf-vertexID) (buf-tag))
  (set-buffer! (state-buffer_Tx     state2) (buf-valid) CORE_Shaper (buf-vertexID) (buf-tag))
  (set-buffer! (state-buffer_Shaper state2) (buf-valid) CORE_Shaper (buf-vertexID) (buf-tag))

  ; Buffer_Rx: same for 2 secrets
  (define buf_Rx-valid (buf-valid))
  (define buf_Rx-vertexID (buf-vertexID))
  (define buf_Rx-tag (buf-tag))
  (set-buffer! (state-buffer_Rx state1) buf_Rx-valid CORE_Rx buf_Rx-vertexID buf_Rx-tag)
  (set-buffer! (state-buffer_Rx state2) buf_Rx-valid CORE_Rx buf_Rx-vertexID buf_Rx-tag)


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

  (when (sat? sol)
    (println "scheduler-reqHistory")
    (println (evaluate (scheduler-reqHistory (state-scheduler state1)) sol))
    (println "vs")
    (println (evaluate (scheduler-reqHistory (state-scheduler state2)) sol))
    (println "dagState-respHistory")
    (println (evaluate (dagState-respHistory (state-dagState_Rx state1)) sol))
    (println "vs")
    (println (evaluate (dagState-respHistory (state-dagState_Rx state2)) sol))
    (println "scheduler-resp")
    (println (evaluate (scheduler-resp (state-scheduler state1)) sol))
    (println "vs")
    (println (evaluate (scheduler-resp (state-scheduler state2)) sol))

    (println "state")
    (println (evaluate state1 sol))
    (println "vs")
    (println (evaluate state2 sol))
  )
  (print "Time for SMT solver: ") (print (/ (- (current-seconds) startTime) 60.0)) (println "min")
)


; - concrete implementations:
;   - TAG_SIZE
;   - INTERVAL_SIZE_SHAPER
;   - INTERVAL_SIZE_SCHEDULER
;   - VERTEXID_SIZE
;   - BUF_SIZE_DAG
;   - BUF_SIZE_SCHEDULER
; - k-induction's k
;   - arg-cycle
(define (testMe)

  (define TAG_SIZE 1) (define INTERVAL_SIZE_SHAPER 2) (define INTERVAL_SIZE_SCHEDULER 1)
  (define VERTEXID_SIZE 4) (define BUF_SIZE_DAG 1) (define BUF_SIZE_SCHEDULER 1)

  (define arg-cycle 6)
  (command-line
    #:once-each
    [("--cycle") v "Number of cycles to simulate"
                   (set! arg-cycle (string->number v))]
  )
  (print "Run with args: --cycle:") (print arg-cycle)
  
  (checkSecu_init arg-cycle TAG_SIZE INTERVAL_SIZE_SHAPER INTERVAL_SIZE_SCHEDULER)
  (checkSecu_induct arg-cycle TAG_SIZE INTERVAL_SIZE_SHAPER INTERVAL_SIZE_SCHEDULER VERTEXID_SIZE BUF_SIZE_DAG BUF_SIZE_SCHEDULER)
)

(testMe)

