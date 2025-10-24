	.file	"test_spill.c"
	.text
	.globl	complex_function                ; -- Begin function complex_function
	.p2align	1
	.type	complex_function,@function
complex_function:                       ; @complex_function
; %bb.0:                                ; %entry
	sub	#28, r1
	mov	r12, 26(r1)
	mov	r13, 24(r1)
	mov	r14, 22(r1)
	mov	r15, 20(r1)
	mov	26(r1), r13
	mov	24(r1), r12
	add	r12, r13
	mov	r13, 18(r1)
	mov	22(r1), r13
	mov	20(r1), r12
	add	r12, r13
	mov	r13, 16(r1)
	mov	18(r1), r12
	mov	16(r1), r13
	call	#__mspabi_mpyi
	mov	r12, 14(r1)
	mov	26(r1), r13
	mov	24(r1), r12
	sub	r12, r13
	mov	r13, 12(r1)
	mov	22(r1), r13
	mov	20(r1), r12
	sub	r12, r13
	mov	r13, 10(r1)
	mov	12(r1), r12
	mov	10(r1), r13
	call	#__mspabi_mpyi
	mov	r12, 8(r1)
	mov	14(r1), r13
	mov	8(r1), r12
	add	r12, r13
	mov	r13, 6(r1)
	mov	18(r1), r13
	mov	16(r1), r12
	sub	r12, r13
	mov	r13, 4(r1)
	mov	6(r1), r13
	mov	4(r1), r12
	add	r12, r13
	mov	r13, 2(r1)
	mov	2(r1), r12
	add	r12, r12
	mov	r12, 0(r1)
	mov	0(r1), r13
	mov	14(r1), r12
	add	r12, r13
	mov	8(r1), r12
	add	r12, r13
	mov	r13, r12
	add	#28, r1
	ret
.Lfunc_end0:
	.size	complex_function, .Lfunc_end0-complex_function
                                        ; -- End function
	.ident	"clang version 22.0.0git (git@github.com:llvm/llvm-project.git 7e55a4c9937dfc2184636ad7f3c9f7eccfad6186)"
	.section	".note.GNU-stack","",@progbits
