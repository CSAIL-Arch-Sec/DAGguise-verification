#lang rosette
; rosette? rosette/safe?

(require "packet.rkt")

(provide
  initSCH

  updateWithReq
  updateClk_SCH
  willAccept
  getResp
  
  (all-from-out "packet.rkt"))

; different name for different purpose
(struct SCH_t (cycleForNext interval) #:mutable #:transparent)
(define (initSCH interval) (SCH_t (make-hash) interval))
; rosette crash at hash funciton example


(define (updateWithReq SCH packet)
  (hash-set! (SCH_t-cycleForNext SCH) packet (SCH_t-interval SCH)))

(define (updateClk_SCH SCH)
  (define (countDown key value)
    (if (equal? 0 (hash-ref (SCH_t-cycleForNext SCH) key))
      (hash-remove! (SCH_t-cycleForNext SCH) key)
      (hash-set! (SCH_t-cycleForNext SCH) key (- value 1))))
  (hash-for-each (SCH_t-cycleForNext SCH) countDown))

;(match-define (list a b) (f))
;(do-something-with a b)
(define (willAccept SCH req_SH req_RC)
  (list req_SH req_RC))

; check serval how distinguish type and instance
(define (getResp SCH)
  (define (getSH key value)
    (if (and (equal? core_SH (packet_t-coreID key)) (equal? 0 value))
      key
      (void)))
  (define respSH (filter (lambda (x) (not (void? x))) (hash-map (SCH_t-cycleForNext SCH) getSH)))
  (assert (> 2 (length respSH)))

  (define (getRC key value)
    (if (and (equal? core_RC (packet_t-coreID key)) (equal? 0 value))
      key
      (void)))
  (define respRC (filter (lambda (x) (not (void? x))) (hash-map (SCH_t-cycleForNext SCH) getRC)))
  (assert (> 2 (length respRC)))

  (append 
    (if (equal? 0 (length respSH)) (list (void)) respSH)
    (if (equal? 0 (length respRC)) (list (void)) respRC)))


(define (testMe)
  (define SCH (initSCH 3))

  (println (willAccept SCH #t #f))
  (println "-------------------")
  
  (updateWithReq SCH (packet_t 0 0 0 0))
  (updateClk_SCH SCH)
  (println SCH)
  (println "-------------------")
  (updateWithReq SCH (packet_t 0 0 0 1))
  (updateWithReq SCH (packet_t 1 0 0 1))
  (updateClk_SCH SCH)
  (println SCH)
  (println "-------------------")
  (updateClk_SCH SCH)
  (println SCH)
  (println "-------------------")
  (println (getResp SCH))
  (updateClk_SCH SCH)
  (println SCH)
  (println "-------------------")
  (println (getResp SCH))
  (updateClk_SCH SCH)
  (println SCH)
  (println "-------------------")
  (updateClk_SCH SCH)
  (println SCH)
  (println "-------------------"))

;(testMe)

