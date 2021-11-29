
.PHONY: verify debug perf doc


verify:
	raco test ++arg --cycle ++arg 3 src/checkSecu.rkt

# NOTE: need web brower
debug:
	raco symtrace src/checkSecu.rkt

# NOTE: need web brower
perf:
	raco symprofile src/checkSecu.rkt

doc: doc/fileHierarchy.gv
	dot -Tpdf doc/fileHierarchy.gv -o doc/fileHierarchy.pdf

