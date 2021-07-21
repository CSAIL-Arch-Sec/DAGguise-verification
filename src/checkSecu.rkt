#lang rosette

(require "simu.rkt")


(define (checkSecu bitWidth MAXCLK)
  (define-symbolic sec1 sec2 pub recv (bitvector bitWidth))

  ;(define state1 (init-state (bitvector->natural sec1) (bitvector->natural pub) (bitvector->natural recv) 2))
  (define state1 (init-state 100 100 (bitvector->natural recv) 2))
  (println "init state1")
  (println state1)
  (define observation1 (init-observation))
  (simu state1 observation1 MAXCLK)

  ;(define state2 (init-state (bitvector->natural sec2) (bitvector->natural pub) (bitvector->natural recv) 2))
  (define state2 (init-state 100 100 (bitvector->natural recv) 2))
  (println "init state2")
  (println state2)
  (define observation2 (init-observation))
  (simu state2 observation2 MAXCLK)

  (verify (assert (equal? (observation-log observation1) (observation-log observation2)))))


(define (checkRosette bitWidth MAXCLK)
  (define-symbolic scheduler1 (bitvector bitWidth))
  (define state1 (init-state 2 2 2 (bitvector->natural scheduler1)))
  ;(define state1 (init-state 2 2 2 1))
  (define observation1 (init-observation))
  (simu state1 observation1 MAXCLK)

  (define-symbolic scheduler2 (bitvector bitWidth))
  (define state2 (init-state 2 2 2 (bitvector->natural scheduler2)))
  ;(define state2 (init-state 2 2 2 0))
  (define observation2 (init-observation))
  (simu state2 observation2 MAXCLK)

  (verify (assert (equal? (observation-log observation1) (observation-log observation2)))))


(define (checkInsecu bitWidth MAXCLK)
  (define-symbolic shaper1 (bitvector bitWidth))
  (define state1 (init-state 2 (bitvector->natural shaper1) 2 2))
  ;(define state1 (init-state 2 1 2 2))
  (define observation1 (init-observation))
  (simu state1 observation1 MAXCLK)

  (define-symbolic shaper2 (bitvector bitWidth))
  (define state2 (init-state 2 (bitvector->natural shaper2) 2 2))
  ;(define state2 (init-state 2 0 2 2))
  (define observation2 (init-observation))
  (simu state2 observation2 MAXCLK)

  (verify (assert (equal? (observation-log observation1) (observation-log observation2)))))


; NOTE: Becuase we cannot un-define a symbolic value,
;       we cannot run these two check one by one in a single run,
;       but have to run one each time.
(define (testMe)
  (println (checkSecu 2 12)))
  ;(println (checkRosette 2 10)))
  ;(println (checkInsecu 2 10)))

(testMe)

