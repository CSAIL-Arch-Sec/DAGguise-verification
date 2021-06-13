
.PHONY: verify debug perf


verify:
	raco test src/checkSecu.rkt

debug:
	raco symtrace src/checkSecu.rkt

perf:
	raco symprofile src/checkSecu.rkt

