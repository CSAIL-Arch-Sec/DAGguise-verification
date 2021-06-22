#lang rosette

(require
  "simu.rkt"
  "state.rkt"
  "observation.rkt")


(define (checkSecu bitWidth MAXCLK)
  (define-symbolic pub (bitvector bitWidth))

  (define-symbolic sec1 (bitvector bitWidth))
  (define state1 (init-state (bitvector->natural sec1) (bitvector->natural pub) 3 3))
  (define observe1 (init-observation))
  (simu state1 observe1 MAXCLK)

  (define-symbolic sec2 (bitvector bitWidth))
  (define state2 (init-state (bitvector->natural sec2) (bitvector->natural pub) 3 3))
  (define observe2 (init-observation))
  (simu state2 observe2 MAXCLK)

  (verify (assert (equal? (getLog observe1) (getLog observe2)))))


(define (checkInsecu bitWidth MAXCLK)
  (define-symbolic sec1 (bitvector bitWidth))
  (define state1 (init-state 3 3 (bitvector->natural sec1) 6))
  ;(define state1 (init-state 3 3 1 6))
  (define observe1 (init-observation))
  (simu state1 observe1 MAXCLK)

  (define-symbolic sec2 (bitvector bitWidth))
  (define state2 (init-state 3 3 (bitvector->natural sec2) 6))
  ;(define state2 (init-state 3 3 0 6))
  (define observe2 (init-observation))
  (simu state2 observe2 MAXCLK)

  ;(verify (assert (equal? 0 (bitvector->natural sec1)))))
  (verify (assert (equal? (getLog observe1) (getLog observe2)))))


; NOTE: Becuase we cannot un-define a symbolic value,
;       we cannot run these two check one by one in a single run,
;       but have to run one each time.
(define (testMe)
  ;(println (checkInsecu 3 20)))
  (println (checkSecu 2 10)))

(testMe)

