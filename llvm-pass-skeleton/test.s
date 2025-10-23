	.build_version macos, 26, 0
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_add                            ; -- Begin function add
	.p2align	2
_add:                                   ; @add
	.cfi_startproc
; %bb.0:                                ; %entry
	add	w8, w1, w0
	sub	w9, w1, w0
	add	w0, w9, w8, lsl #1
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:                                ; %entry
	mov	w0, #35                         ; =0x23
	ret
	.cfi_endproc
                                        ; -- End function
.subsections_via_symbols
