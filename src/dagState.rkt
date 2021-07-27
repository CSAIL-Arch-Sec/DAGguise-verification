#lang rosette

(require
  "packet.rkt"
  (prefix-in fixRate: "dagStateFixRate.rkt")
  (prefix-in sym: "dagStateSym.rkt")
  (prefix-in uninter: "dagStateUninter.rkt"))

(provide
  fixRate:init-dagState
  fixRate:set-dagState!
  sym:init-dagState
  sym:set-dagState!
  uninter:init-dagState
  uninter:set-dagState!

  symopt-dagState!
  simuRespFor-dagState!
  incClkFor-dagState!
  dagState-req
  dagState-respHistory
  
  (all-from-out "packet.rkt"))


(define (symopt-dagState! . args)
  (match (car args)
    [(struct fixRate:dagState _) (apply fixRate:symopt-dagState! args)]
    [(struct sym:dagState _) (apply sym:symopt-dagState! args)]
    [(struct uninter:dagState _) (apply uninter:symopt-dagState! args)])
)

(define (simuRespFor-dagState! . args)
  (match (car args)
    [(struct fixRate:dagState _) (apply fixRate:simuRespFor-dagState! args)]
    [(struct sym:dagState _) (apply sym:simuRespFor-dagState! args)]
    [(struct uninter:dagState _) (apply uninter:simuRespFor-dagState! args)])
)

(define (incClkFor-dagState! . args)
  (match (car args)
    [(struct fixRate:dagState _) (apply fixRate:incClkFor-dagState! args)]
    [(struct sym:dagState _) (apply sym:incClkFor-dagState! args)]
    [(struct uninter:dagState _) (apply uninter:incClkFor-dagState! args)])
)

(define (dagState-req . args)
  (match (car args)
    [(struct fixRate:dagState _) (apply fixRate:dagState-req args)]
    [(struct sym:dagState _) (apply sym:dagState-req args)]
    [(struct uninter:dagState _) (apply uninter:dagState-req args)])
)

(define (dagState-respHistory . args)
  (match (car args)
    [(struct sym:dagState _) (apply sym:dagState-respHistory args)]
    [(struct uninter:dagState _) (apply uninter:dagState-respHistory args)])
)


(define (testMe)
  (define (testDagState dagState)
    (simuRespFor-dagState! dagState 11111)
  
    (println (dagState-req dagState))
    (incClkFor-dagState! dagState)
    (println (dagState-req dagState))
    (incClkFor-dagState! dagState)
    (println (dagState-req dagState))
    (incClkFor-dagState! dagState)
    (println (dagState-req dagState))
    (incClkFor-dagState! dagState)
    (println (dagState-req dagState))
    (incClkFor-dagState! dagState))

  (define dagState1 (fixRate:init-dagState 22 3))
  (testDagState dagState1)

  (println "------------------")

  (define dagState2 (uninter:init-dagState 22))
  (testDagState dagState2))

;(testMe)
