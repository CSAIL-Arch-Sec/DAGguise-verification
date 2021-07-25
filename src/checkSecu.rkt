#lang rosette

(require "simu.rkt")


(define (checkSecu HIST_SIZE MAXCLK)
  (define bitWidth 2) (define-symbolic sec1 sec2 pub recv sched
                                       debug1 debug2 (bitvector bitWidth))
  (define-symbolic secPro1 secPro2 pubPro recvPro schedPro
                   debug1Pro debug2Pro (~> (bitvector HIST_SIZE) boolean?))


  (define state1 (concrete:init-state
    ;(fixRate:init-dagState CORE_Shaper 100)
    ;(fixRate:init-dagState CORE_Shaper (bitvector->natural sec1))
    (uninter:init-dagState CORE_Shaper secPro1 HIST_SIZE)

    (fixRate:init-dagState CORE_Shaper 3)
    ;(fixRate:init-dagState CORE_Shaper (bitvector->natural pub))
    ;(uninter:init-dagState CORE_Shaper pubPro HIST_SIZE)

    ;(fixRate:init-dagState CORE_Rx 100)
    ;(fixRate:init-dagState CORE_Rx (bitvector->natural recv))
    (uninter:init-dagState CORE_Rx recvPro HIST_SIZE)

    (fixRate:init-scheduler 1)
    ;(fixRateVec:init-scheduler 1)
    ;(fixRate:init-scheduler (bitvector->natural sched))
    ;(fixRateVec:init-scheduler (bitvector->natural sched))
    ;(uninter:init-scheduler schedPro HIST_SIZE)
  ))
  ;(println "init state1") (println state1)
  (define observation1 (init-observation)) (simu state1 observation1 MAXCLK)
  (println "---------------------------")

  (define state2 (concrete:init-state
    ;(fixRate:init-dagState CORE_Shaper 100)
    ;(fixRate:init-dagState CORE_Shaper (bitvector->natural sec2))
    (uninter:init-dagState CORE_Shaper secPro2 HIST_SIZE)

    (fixRate:init-dagState CORE_Shaper 3)
    ;(fixRate:init-dagState CORE_Shaper (bitvector->natural pub))
    ;(uninter:init-dagState CORE_Shaper pubPro HIST_SIZE)

    ;(fixRate:init-dagState CORE_Rx 100)
    ;(fixRate:init-dagState CORE_Rx (bitvector->natural recv))
    (uninter:init-dagState CORE_Rx recvPro HIST_SIZE)

    (fixRate:init-scheduler 1)
    ;(fixRateVec:init-scheduler 1)
    ;(fixRate:init-scheduler (bitvector->natural sched))
    ;(fixRateVec:init-scheduler (bitvector->natural sched))
    ;(uninter:init-scheduler schedPro HIST_SIZE)
  ))
  ;(println "init state2") (println state2)
  (define observation2 (init-observation)) (simu state2 observation2 MAXCLK)
  (println "---------------------------")


  (define startTime (current-seconds))
  (println (verify (assert (equal? (observation-log observation1) (observation-log observation2)))))
  (print "Time for SMT solver: ") (print (/ (- (current-seconds) startTime) 60.0)) (println "min")
)


(define (checkSecuInduct HIST_SIZE MAXCLK)

  ; STEP1: init the state
  (define-symbolic secPro1 secPro2 recvPro
                   debug1Pro debug2Pro (~> (bitvector HIST_SIZE) boolean?))
  
  (define state1 (concrete:init-state
    (uninter:init-dagState CORE_Shaper secPro1 HIST_SIZE)
    (fixRate:init-dagState CORE_Shaper 3)
    (uninter:init-dagState CORE_Rx recvPro HIST_SIZE)
    (fixRate:init-scheduler 1)
  ))
  (define state2 (concrete:init-state
    (uninter:init-dagState CORE_Shaper secPro2 HIST_SIZE)
    (fixRate:init-dagState CORE_Shaper 3)
    (uninter:init-dagState CORE_Rx recvPro HIST_SIZE)
    (fixRate:init-scheduler 1)
  ))


  ; STEP2: set the state with symbolic value
  ; TODO: should set into a compete symbolic state
  (define-symbolic respHistory_Tx1 respHistory_Tx2 respHistory_Rx1 respHistory_Rx2 (bitvector HIST_SIZE))
  (define-symbolic cycleForNext_Shaper1 cycleForNext_Shaper2 (bitvector 2))
  (define-symbolic vertexID_Tx1 vertexID_Tx2 vertexID_Shaper1 vertexID_Shaper2 vertexID_Rx1 vertexID_Rx2 (bitvector 32))
  (define (set-state! state respHistory_Tx vertexID_Tx
                            cycleForNext_Shaper vertexID_Shaper
                            respHistory_Rx vertexID_Rx)
    (uninter:set-dagState! (state-dagState_Tx state) respHistory_Tx vertexID_Tx)
    (fixRate:set-dagState! (state-dagState_Shaper state) cycleForNext_Shaper vertexID_Shaper)
    (uninter:set-dagState! (state-dagState_Rx state) respHistory_Rx vertexID_Rx)
  )

  (set-state! state1 respHistory_Tx1 (bitvector->natural vertexID_Tx1)
                     (bitvector->natural cycleForNext_Shaper1) (bitvector->natural vertexID_Shaper1)
                     respHistory_Rx1 (bitvector->natural vertexID_Rx1))
  (set-state! state2 respHistory_Tx2 (bitvector->natural vertexID_Tx2)
                     (bitvector->natural cycleForNext_Shaper2) (bitvector->natural vertexID_Shaper2)
                     respHistory_Rx2 (bitvector->natural vertexID_Rx2))
  ;(println "init state1") (println state1)
  ;(println "init state2") (println state2)


  ; STEP3: assume for some cycles
  (println "---------------------------")
  (println "assume K cycles")
  (define (assumeK state1 observation1 state2 observation2 MAXCLK)
    (simu state1 observation1 0)
    (simu state2 observation2 0)
    (unless (equal? 0 MAXCLK) (assumeK state1 observation1 state2 observation2 (- MAXCLK 1)))
  )
  (define observation1 (init-observation))
  (define observation2 (init-observation))
  (assumeK state1 observation1 state2 observation2 MAXCLK)
  (assume (assert (equal? (observation-log observation1) (observation-log observation2))))


  ; STEP4: assert for 1 cycle
  (println "---------------------------")
  (println "assert 1 cycle")
  (simu state1 observation1 0)
  (simu state2 observation2 0)

  (define startTime (current-seconds))
  (println (verify (assert (equal? (observation-log observation1) (observation-log observation2)))))
  (print "Time for SMT solver: ") (print (/ (- (current-seconds) startTime) 60.0)) (println "min")
)


(define (testMe)
  (define arg-hist 2)
  (define arg-cycle 12)
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

