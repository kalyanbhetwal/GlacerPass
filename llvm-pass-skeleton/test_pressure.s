	.build_version macos, 26, 0
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_pressure                       ; -- Begin function pressure
	.p2align	2
_pressure:                              ; @pressure
	.cfi_startproc
; %bb.0:                                ; %entry
	sub	sp, sp, #48
	.cfi_def_cfa_offset 48
	str	w0, [sp, #44]
	str	w1, [sp, #40]
	str	w2, [sp, #36]
	str	w3, [sp, #32]
	ldr	w8, [sp, #44]
	lsl	w8, w8, #1
	str	w8, [sp, #28]
	ldr	w9, [sp, #40]
	mov	w8, #3                          ; =0x3
	mul	w8, w9, w8
	str	w8, [sp, #24]
	ldr	w8, [sp, #36]
	lsl	w8, w8, #2
	str	w8, [sp, #20]
	ldr	w9, [sp, #32]
	mov	w8, #5                          ; =0x5
	mul	w8, w9, w8
	str	w8, [sp, #16]
	ldr	w9, [sp, #44]
	ldr	w8, [sp, #40]
	mul	w8, w9, w8
	str	w8, [sp, #12]
	ldr	w9, [sp, #36]
	ldr	w8, [sp, #32]
	mul	w8, w9, w8
	str	w8, [sp, #8]
	ldr	w9, [sp, #28]
	ldr	w8, [sp, #24]
	add	w10, w9, w8
	ldr	w9, [sp, #20]
	ldr	w8, [sp, #16]
	add	w8, w9, w8
	add	w10, w10, w8
	ldr	w9, [sp, #12]
	ldr	w8, [sp, #8]
	add	w9, w9, w8
	ldr	w8, [sp, #44]
	add	w8, w9, w8
	add	w10, w10, w8
	ldr	w9, [sp, #40]
	ldr	w8, [sp, #36]
	add	w9, w9, w8
	ldr	w8, [sp, #32]
	add	w8, w9, w8
	add	w0, w10, w8
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
.subsections_via_symbols
