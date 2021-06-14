#lang rosette
; rosette? rosette/safe?

(require "packet.rkt")

(provide
  init-scheduler

  updateWithReq!
  updateClk_scheduler!
  willAccept
  getResp
  
  (all-from-out "packet.rkt"))


(struct scheduler (servingPacket interval) #:mutable #:transparent)
(define (init-scheduler interval) (scheduler (list) interval))


(define (updateWithReq! scheduler packet)
  (assert (not (findf
    (lambda (pair) (equal? (car pair) packet))
    (scheduler-servingPacket scheduler))))
  (set-scheduler-servingPacket! scheduler
    (append (scheduler-servingPacket scheduler)
      (list (cons packet (scheduler-interval scheduler))))))

(define (updateClk_scheduler! scheduler)
  (define (notZero pair) (not (equal? 0 (cdr pair))))
  (define (countDown pair)
    (assert (not (equal? 0 (cdr pair))))
    (cons (car pair) (- (cdr pair) 1)))

  ; independent replay begin
  ;(set-scheduler-servingPacket! scheduler
  ;  (map countDown (filter notZero (scheduler-servingPacket scheduler)))))
  ; independent replay end

  ; dependent replay begin
  (define rest (filter notZero (scheduler-servingPacket scheduler)))
  (set-scheduler-servingPacket! scheduler
    (append (list (countDown (first rest))) (list-tail rest 1))))
  ; dependent replay end

;(match-define (list a b) (f))
;(do-something-with a b)
(define (willAccept scheduler req_SH req_RC)
  (list req_SH req_RC))

(define (getResp scheduler)
  (define (shouldResp coreID)
    (lambda (pair)
      (and (equal? coreID (packet-coreID (car pair)))
               (equal? 0 (cdr pair)))))

  (define respSH (filter (shouldResp CORE_SH) (scheduler-servingPacket scheduler)))
  (define respRC (filter (shouldResp CORE_RC) (scheduler-servingPacket scheduler)))
  ; Currently, at most 1 request per cycle, then, at most 1 response per cycle
  (assert (> 2 (length respSH)))
  (assert (> 2 (length respRC)))

  (list 
    (if (equal? 0 (length respSH)) (void) (car (first respSH)))
    (if (equal? 0 (length respRC)) (void) (car (first respRC)))))


(define (testMe)
  (define scheduler (init-scheduler 3))

  (println (willAccept scheduler #t #f))
  (println "-------------------")
  
  (updateWithReq! scheduler (packet 0 0 0 0))
  (updateClk_scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (updateWithReq! scheduler (packet 0 0 0 1))
  (updateWithReq! scheduler (packet 1 0 0 1))
  (updateClk_scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (updateClk_scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (println (getResp scheduler))
  (updateClk_scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (println (getResp scheduler))
  (updateClk_scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (updateClk_scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (updateClk_scheduler! scheduler)
  (println scheduler)
  (println "-------------------")
  (updateClk_scheduler! scheduler)
  (println scheduler)
  (println "-------------------"))

;(testMe)

