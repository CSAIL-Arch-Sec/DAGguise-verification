#lang rosette

(require "simu.rkt")


(define (checkSecu HIST_SIZE MAXCLK)
  (define bitWidth 2) (define-symbolic sec1 sec2 pub recv sched
                                       debug1 debug2 (bitvector bitWidth))
  (define-symbolic secPro1 secPro2 pubPro recvPro schedPro
                   debug1Pro debug2Pro (~> (bitvector HIST_SIZE) boolean?))


  (define state1 (init-state
    ;(fixRate:init-dagState CORE_Shaper 100)
    ;(fixRate:init-dagState CORE_Shaper (bitvector->natural sec1))
    (uninter:init-dagState CORE_Shaper secPro1 HIST_SIZE)

    (fixRate:init-dagState CORE_Shaper 2)
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

  (define state2 (init-state
    ;(fixRate:init-dagState CORE_Shaper 100)
    ;(fixRate:init-dagState CORE_Shaper (bitvector->natural sec2))
    (uninter:init-dagState CORE_Shaper secPro2 HIST_SIZE)

    (fixRate:init-dagState CORE_Shaper 2)
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


(define (testMe)
  (define arg-hist 10)
  (define arg-cycle 10)
  (command-line
    #:once-each
    [("--hist")  v "The size of req/resp history for uninterpreted funciton"
                   (set! arg-hist (string->number v))]
    [("--cycle") v "Number of cycles to simulate"
                   (set! arg-cycle (string->number v))]
  )


  (print "Run with args: --hist:") (print arg-hist) (print "  --cycle:") (println arg-cycle)
  (checkSecu arg-hist arg-cycle)
)

(testMe)

