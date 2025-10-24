	.build_version macos, 26, 0
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_test                           ; -- Begin function test
	.p2align	2
_test:                                  ; @test
	.cfi_startproc
; %bb.0:                                ; %entry
	add	w8, w1, w0
	add	w9, w2, w3
	add	w8, w8, w9
	add	w8, w8, w4
	lsl	w0, w8, #1
	ret
	.cfi_endproc
                                        ; -- End function
.subsections_via_symbols
