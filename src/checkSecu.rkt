#lang rosette

(require
  "simu.rkt"
  "state.rkt"
  "observation.rkt")


(define (checkSecu bitWidth MAXCLK)
  (define-symbolic pub recv (bitvector bitWidth))

  (define-symbolic sec1 (bitvector bitWidth))
  (define state1 (init-state (bitvector->natural sec1) (bitvector->natural pub) (bitvector->natural recv) 2))
  (define observe1 (init-observation))
  (simu state1 observe1 MAXCLK)

  (define-symbolic sec2 (bitvector bitWidth))
  (define state2 (init-state (bitvector->natural sec2) (bitvector->natural pub) (bitvector->natural recv) 2))
  (define observe2 (init-observation))
  (simu state2 observe2 MAXCLK)

  (verify (assert (equal? (getLog observe1) (getLog observe2)))))


(define (checkRosette bitWidth MAXCLK)
  (define-symbolic scheduler1 (bitvector bitWidth))
  (define state1 (init-state 2 2 2 (bitvector->natural scheduler1)))
  ;(define state1 (init-state 2 2 2 1))
  (define observe1 (init-observation))
  (simu state1 observe1 MAXCLK)

  (define-symbolic scheduler2 (bitvector bitWidth))
  (define state2 (init-state 2 2 2 (bitvector->natural scheduler2)))
  ;(define state2 (init-state 2 2 2 0))
  (define observe2 (init-observation))
  (simu state2 observe2 MAXCLK)

  (verify (assert (equal? (getLog observe1) (getLog observe2)))))


(define (checkInsecu bitWidth MAXCLK)
  (define-symbolic shaper1 (bitvector bitWidth))
  (define state1 (init-state 2 (bitvector->natural shaper1) 2 2))
  ;(define state1 (init-state 2 1 2 2))
  (define observe1 (init-observation))
  (simu state1 observe1 MAXCLK)

  (define-symbolic shaper2 (bitvector bitWidth))
  (define state2 (init-state 2 (bitvector->natural shaper2) 2 2))
  ;(define state2 (init-state 2 0 2 2))
  (define observe2 (init-observation))
  (simu state2 observe2 MAXCLK)

  (verify (assert (equal? (getLog observe1) (getLog observe2)))))


; NOTE: Becuase we cannot un-define a symbolic value,
;       we cannot run these two check one by one in a single run,
;       but have to run one each time.
(define (testMe)
  (println (checkSecu 2 10)))
  ;(println (checkRosette 2 10)))
  ;(println (checkInsecu 2 10)))

(testMe)

