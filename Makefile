
.PHONY: verify debug perf


verify:
	raco test ++args "--hist 5 --cycle 5" src/checkSecu.rkt

debug:
	raco symtrace src/checkSecu.rkt

perf:
	raco symprofile src/checkSecu.rkt

doc: doc/fileHierarchy.gv
	dot -Tpdf doc/fileHierarchy.gv -o doc/fileHierarchy.pdf

