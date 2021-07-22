#lang rosette

(require "simu.rkt")


(define (checkSecu)
  (define MAXCLK 10)
  (define bitWidth 2) (define-symbolic sec1 sec2 pub recv (bitvector bitWidth))
  (define HIST_SIZE 10) (define-symbolic secPro1 secPro2 pubPro recvPro (~> (bitvector HIST_SIZE) boolean?))


  (define state1 (init-state
    ;(fixRate:init-dagState CORE_Shaper 100)
    ;(fixRate:init-dagState CORE_Shaper 100)
    ;(fixRate:init-dagState CORE_Rx 100)
    
    ;(fixRate:init-dagState CORE_Shaper (bitvector->natural sec1))
    ;(fixRate:init-dagState CORE_Shaper (bitvector->natural pub))
    ;(fixRate:init-dagState CORE_Rx (bitvector->natural recv))
    
    (uninter:init-dagState CORE_Shaper secPro1 HIST_SIZE)
    (uninter:init-dagState CORE_Shaper pubPro HIST_SIZE)
    (uninter:init-dagState CORE_Rx recvPro HIST_SIZE)
    0))
  (println "init state1") (println state1)
  (define observation1 (init-observation)) (simu state1 observation1 MAXCLK)


  (define state2 (init-state
    ;(fixRate:init-dagState CORE_Shaper 100)
    ;(fixRate:init-dagState CORE_Shaper 100)
    ;(fixRate:init-dagState CORE_Rx 100)
    
    ;(fixRate:init-dagState CORE_Shaper (bitvector->natural sec2))
    ;(fixRate:init-dagState CORE_Shaper (bitvector->natural pub))
    ;(fixRate:init-dagState CORE_Rx (bitvector->natural recv))
    
    (uninter:init-dagState CORE_Shaper secPro2 HIST_SIZE)
    (uninter:init-dagState CORE_Shaper pubPro HIST_SIZE)
    (uninter:init-dagState CORE_Rx recvPro HIST_SIZE)
    0))
  (println "init state2") (println state2)
  (define observation2 (init-observation)) (simu state2 observation2 MAXCLK)


  (verify (assert (equal? (observation-log observation1) (observation-log observation2)))))


(define (testMe)
  (println (checkSecu)))

(testMe)

