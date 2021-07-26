#lang rosette

(require "simu.rkt")


(define (checkSecu HIST_SIZE MAXCLK)
  (define bitWidth 2) (define-symbolic sec1 sec2 pub recv sched
                                       debug1 debug2 (bitvector bitWidth))
  (define-symbolic schedPro
                   debug1Pro debug2Pro (~> (bitvector HIST_SIZE) boolean?))
  (define TAG_SIZE 1)
  (define-symbolic secPro1 secPro2 pubPro recvPro
                   debug3Pro debug4Pro (~> (bitvector (* (+ 1 TAG_SIZE) HIST_SIZE)) (bitvector (+ 1 TAG_SIZE))))


  (define state1 (concrete:init-state
    ;(fixRate:init-dagState CORE_Shaper 100)
    ;(fixRate:init-dagState CORE_Shaper (bitvector->natural sec1))
    (uninter:init-dagState CORE_Shaper secPro1 HIST_SIZE HIST_SIZE TAG_SIZE)

    (fixRate:init-dagState CORE_Shaper 2 TAG_SIZE)
    ;(fixRate:init-dagState CORE_Shaper (bitvector->natural pub))
    ;(uninter:init-dagState CORE_Shaper pubPro HIST_SIZE)

    ;(fixRate:init-dagState CORE_Rx 100)
    ;(fixRate:init-dagState CORE_Rx (bitvector->natural recv))
    (uninter:init-dagState CORE_Rx recvPro HIST_SIZE MAXCLK TAG_SIZE)

    (fixRate:init-scheduler 1 MAXCLK TAG_SIZE)
    ;(fixRateVec:init-scheduler 1)
    ;(fixRate:init-scheduler (bitvector->natural sched))
    ;(fixRateVec:init-scheduler (bitvector->natural sched))
    ;(uninter:init-scheduler schedPro HIST_SIZE)
  ))
  ;(println "init state1") (println state1)
  (simu state1 MAXCLK)
  (println "---------------------------")

  (define state2 (concrete:init-state
    ;(fixRate:init-dagState CORE_Shaper 100)
    ;(fixRate:init-dagState CORE_Shaper (bitvector->natural sec2))
    (uninter:init-dagState CORE_Shaper secPro2 HIST_SIZE HIST_SIZE TAG_SIZE)

    (fixRate:init-dagState CORE_Shaper 2 TAG_SIZE)
    ;(fixRate:init-dagState CORE_Shaper (bitvector->natural pub))
    ;(uninter:init-dagState CORE_Shaper pubPro HIST_SIZE)

    ;(fixRate:init-dagState CORE_Rx 100)
    ;(fixRate:init-dagState CORE_Rx (bitvector->natural recv))
    (uninter:init-dagState CORE_Rx recvPro HIST_SIZE MAXCLK TAG_SIZE)

    (fixRate:init-scheduler 1 MAXCLK TAG_SIZE)
    ;(fixRateVec:init-scheduler 1)
    ;(fixRate:init-scheduler (bitvector->natural sched))
    ;(fixRateVec:init-scheduler (bitvector->natural sched))
    ;(uninter:init-scheduler schedPro HIST_SIZE)
  ))
  ;(println "init state2") (println state2)
  (simu state2 MAXCLK)
  (println "---------------------------")


  (define startTime (current-seconds))
  (println (verify (assert (equal? (dagState-respHistory (state-dagState_Rx state1)) (dagState-respHistory (state-dagState_Rx state2))))))
  (print "Time for SMT solver: ") (print (/ (- (current-seconds) startTime) 60.0)) (println "min")
)


(define (checkSecuInduct HIST_SIZE MAXCLK)

  ; STEP1: init the state
  (define TAG_SIZE 1)
  (define-symbolic secPro1 secPro2 recvPro (~> (bitvector (* (+ 1 TAG_SIZE) HIST_SIZE)) (bitvector (+ 1 TAG_SIZE))))
  
  (define state1 (concrete:init-state
    (uninter:init-dagState CORE_Shaper secPro1 HIST_SIZE HIST_SIZE TAG_SIZE)
    (fixRate:init-dagState CORE_Shaper 3 TAG_SIZE)
    (uninter:init-dagState CORE_Rx recvPro HIST_SIZE MAXCLK TAG_SIZE)
    (fixRate:init-scheduler 1 MAXCLK TAG_SIZE)
  ))
  (define state2 (concrete:init-state
    (uninter:init-dagState CORE_Shaper secPro2 HIST_SIZE HIST_SIZE TAG_SIZE)
    (fixRate:init-dagState CORE_Shaper 3 TAG_SIZE)
    (uninter:init-dagState CORE_Rx recvPro HIST_SIZE MAXCLK TAG_SIZE)
    (fixRate:init-scheduler 1 MAXCLK TAG_SIZE)
  ))


  ; STEP2: set the state with symbolic value
  ; TODO: should set into a compete symbolic state
  (define-symbolic respHistory_Tx1 respHistory_Tx2 respHistory_Rx (bitvector HIST_SIZE))
  (define-symbolic cycleForNext_Shaper1 cycleForNext_Shaper2 (bitvector 2))
  (define-symbolic vertexID_Tx1 vertexID_Tx2 vertexID_Shaper1 vertexID_Shaper2 vertexID_Rx (bitvector 4))
  (define-symbolic tagID_Shaper1 tagID_Shaper2 (bitvector TAG_SIZE))
  (define (set-state! state respHistory_Tx vertexID_Tx
                            cycleForNext_Shaper vertexID_Shaper tagID_Shaper
                            respHistory_Rx vertexID_Rx)
    (uninter:set-dagState! (state-dagState_Tx state) respHistory_Tx vertexID_Tx)
    (fixRate:set-dagState! (state-dagState_Shaper state) cycleForNext_Shaper vertexID_Shaper tagID_Shaper)
    (uninter:set-dagState! (state-dagState_Rx state) respHistory_Rx vertexID_Rx)
  )

  (set-state! state1 respHistory_Tx1 (bitvector->natural vertexID_Tx1)
                     (bitvector->natural cycleForNext_Shaper1) (bitvector->natural vertexID_Shaper1) tagID_Shaper1
                     respHistory_Rx (bitvector->natural vertexID_Rx))
  (set-state! state2 respHistory_Tx2 (bitvector->natural vertexID_Tx2)
                     (bitvector->natural cycleForNext_Shaper2) (bitvector->natural vertexID_Shaper2) tagID_Shaper2
                     respHistory_Rx (bitvector->natural vertexID_Rx))
  ;(println "init state1") (println state1)
  ;(println "init state2") (println state2)


  ; STEP3: assume for some cycles
  ; NOTE: HIST_SIZE cycles are implicitly assumed to be secure because we set Rx1 and Rx2 into the same state
  (println "---------------------------")
  (println "assume K cycles")
  (define (assumeK state1 state2 MAXCLK)
    (simu state1 1)
    (simu state2 1)
    (unless (equal? 2 MAXCLK) (assumeK state1 state2 (- MAXCLK 1)))
  )
  (assumeK state1 state2 MAXCLK)
  (assume (equal? (dagState-respHistory (state-dagState_Rx state1)) (dagState-respHistory (state-dagState_Rx state2))))
  (assume (equal? (scheduler-reqHistory (state-scheduler state1)) (scheduler-reqHistory (state-scheduler state2))))


  ; STEP4: assert for 1 cycle
  (println "---------------------------")
  (println "assert 1 cycle")
  (simu state1 1)
  (simu state2 1)

  (define startTime (current-seconds))
  (define sol
    (verify (assert (&& (equal? (extract (- (* 2 (+ 1 TAG_SIZE)) 1) (+ 1 TAG_SIZE) (dagState-respHistory (state-dagState_Rx state1)))
                                (extract (- (* 2 (+ 1 TAG_SIZE)) 1) (+ 1 TAG_SIZE) (dagState-respHistory (state-dagState_Rx state2))))
                        (equal? (extract (- (* 4 (+ 1 TAG_SIZE)) 1) (* 2 (+ 1 TAG_SIZE)) (scheduler-reqHistory (state-scheduler state1)))
                                (extract (- (* 4 (+ 1 TAG_SIZE)) 1) (* 2 (+ 1 TAG_SIZE)) (scheduler-reqHistory (state-scheduler state2)))))))
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

    (println "state")
    (println (evaluate state1 sol))
    (println "vs")
    (println (evaluate state2 sol))
  )

  (print "Time for SMT solver: ") (print (/ (- (current-seconds) startTime) 60.0)) (println "min")
)


(define (testMe)
  (define arg-hist 10)
  (define arg-cycle 5)
  (command-line
    #:once-each
    [("--hist")  v "The size of req/resp history for uninterpreted funciton"
                   (set! arg-hist (string->number v))]
    [("--cycle") v "Number of cycles to simulate"
                   (set! arg-cycle (string->number v))]
  )
  (print "Run with args: --hist:") (print arg-hist) (print "  --cycle:") (println arg-cycle)
  

  ;(checkSecu arg-hist arg-cycle)
  (checkSecuInduct arg-hist arg-cycle)
)

(testMe)

