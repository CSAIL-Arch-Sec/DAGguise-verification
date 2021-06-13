#lang rosette

(require
  "simu.rkt"
  "state.rkt"
  "observe.rkt")


(define (checkSecu bitWidth MAXCLK)
  (define-symbolic sec1 (bitvector bitWidth))
  (define state1 (initState (bitvector->natural sec1) 3 3 6))
  (define observe1 (initObserve))
  (simu state1 observe1 MAXCLK)

  (define-symbolic sec2 (bitvector bitWidth))
  (define state2 (initState (bitvector->natural sec2) 3 3 6))
  (define observe2 (initObserve))
  (simu state2 observe2 MAXCLK)

  (verify (assert (equal? (getLog observe1) (getLog observe2)))))


(define (checkInsecu bitWidth MAXCLK)
  (define-symbolic sec1 (bitvector bitWidth))
  (define state1 (initState 3 3 (bitvector->natural sec1) 6))
  ;(define state1 (initState 3 3 1 6))
  (define observe1 (initObserve))
  (simu state1 observe1 MAXCLK)

  (define-symbolic sec2 (bitvector bitWidth))
  ;(define state2 (initState 3 3 (bitvector->natural sec2) 6))
  (define state2 (initState 3 3 0 6))
  (define observe2 (initObserve))
  (simu state2 observe2 MAXCLK)

  ;(verify (assert (equal? 0 (bitvector->natural sec1)))))
  (verify (assert (equal? (getLog observe1) (getLog observe2)))))


(define (testMe)
  (checkInsecu 1 10))
  ;(checkSecu 2 20))

(testMe)

