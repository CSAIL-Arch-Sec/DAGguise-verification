#lang rosette

(require
  "packet.rkt"
  (prefix-in fixRate: "schedulerFixRate.rkt")
  (prefix-in fixRateVec: "schedulerFixRateVec.rkt")
  (prefix-in uninter: "schedulerUninter.rkt"))

(provide
  fixRate:init-scheduler
  fixRateVec:init-scheduler
  uninter:init-scheduler

  symopt-scheduler!
  simuReqFor-scheduler!
  incClkFor-scheduler!
  scheduler-canAccept
  scheduler-resp
  scheduler-reqHistory
  
  (all-from-out "packet.rkt"))


(define (symopt-scheduler! . args)
  (match (car args)
    [(struct fixRate:scheduler _) (apply fixRate:symopt-scheduler! args)]
    [(struct fixRateVec:scheduler _) (apply fixRateVec:symopt-scheduler! args)]
    [(struct uninter:scheduler _) (apply uninter:symopt-scheduler! args)])
)

(define (simuReqFor-scheduler! . args)
  (match (car args)
    [(struct fixRate:scheduler _) (apply fixRate:simuReqFor-scheduler! args)]
    [(struct fixRateVec:scheduler _) (apply fixRateVec:simuReqFor-scheduler! args)]
    [(struct uninter:scheduler _) (apply uninter:simuReqFor-scheduler! args)])
)


(define (incClkFor-scheduler! . args)
  (match (car args)
    [(struct fixRate:scheduler _) (apply fixRate:incClkFor-scheduler! args)]
    [(struct fixRateVec:scheduler _) (apply fixRateVec:incClkFor-scheduler! args)]
    [(struct uninter:scheduler _) (apply uninter:incClkFor-scheduler! args)])
)

(define (scheduler-canAccept . args)
  (match (car args)
    [(struct fixRate:scheduler _) (apply fixRate:scheduler-canAccept args)]
    [(struct fixRateVec:scheduler _) (apply fixRateVec:scheduler-canAccept args)]
    [(struct uninter:scheduler _) (apply uninter:scheduler-canAccept args)])
)

(define (scheduler-resp . args)
  (match (car args)
    [(struct fixRate:scheduler _) (apply fixRate:scheduler-resp args)]
    [(struct fixRateVec:scheduler _) (apply fixRateVec:scheduler-resp args)]
    [(struct uninter:scheduler _) (apply uninter:scheduler-resp args)])
)

(define (scheduler-reqHistory . args)
  (match (car args)
    [(struct fixRate:scheduler _) (apply fixRate:scheduler-reqHistory args)])
)


(define (testMe)
  (define (testScheduler scheduler)
    (println (scheduler-canAccept scheduler #t #f))
    (println "-------------------")
    
    (simuReqFor-scheduler! scheduler (packet 0 0 0 0))
    (incClkFor-scheduler! scheduler)
    (println scheduler)
    (println "-------------------")
    (simuReqFor-scheduler! scheduler (packet 0 0 0 1))
    (simuReqFor-scheduler! scheduler (packet 1 0 0 1))
    (incClkFor-scheduler! scheduler)
    (println scheduler)
    (println "-------------------")
    (println (scheduler-resp scheduler))
    (incClkFor-scheduler! scheduler)
    (println scheduler)
    (println "-------------------")
    (println (scheduler-resp scheduler))
    (incClkFor-scheduler! scheduler)
    (println scheduler)
    (println "-------------------")
    (println (scheduler-resp scheduler))
    (incClkFor-scheduler! scheduler)
    (println scheduler)
    (println "-------------------")
    (println (scheduler-resp scheduler))
    (incClkFor-scheduler! scheduler)
    (println scheduler)
    (println "-------------------")
    (println (scheduler-resp scheduler))
    (incClkFor-scheduler! scheduler)
    (println scheduler)
    (println "-------------------")
    (println (scheduler-resp scheduler))
    (incClkFor-scheduler! scheduler)
    (println scheduler)
    (println "-------------------")
    (println (scheduler-resp scheduler))
    (incClkFor-scheduler! scheduler)
    (println scheduler)
    (println "-------------------")
    (println (scheduler-resp scheduler))
    (incClkFor-scheduler! scheduler)
    (println scheduler)
    (println "-------------------")
    (println (scheduler-resp scheduler))
    (incClkFor-scheduler! scheduler)
    (println scheduler)
    (println "-------------------")
    (println (scheduler-resp scheduler))
    (incClkFor-scheduler! scheduler)
    (println scheduler)
    (println "-------------------")
  )

  (testScheduler (fixRate:init-scheduler 3))

  (println "------------------------------------------------------")

  (testScheduler (fixRateVec:init-scheduler 3))

  (println "------------------------------------------------------")

  (define HIST_SIZE 10) (define-symbolic sched (~> (bitvector HIST_SIZE) boolean?))
  (testScheduler (uninter:init-scheduler sched HIST_SIZE))
)

;(testMe)
