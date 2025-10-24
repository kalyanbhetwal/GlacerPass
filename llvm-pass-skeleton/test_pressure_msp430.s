	.file	"test_pressure.c"
	.text
	.globl	pressure                        ; -- Begin function pressure
	.p2align	1
	.type	pressure,@function
pressure:                               ; @pressure
; %bb.0:                                ; %entry
	sub	#20, r1
	mov	r12, 18(r1)
	mov	r13, 16(r1)
	mov	r14, 14(r1)
	mov	r15, 12(r1)
	mov	18(r1), r12
	add	r12, r12
	mov	r12, 10(r1)
	mov	16(r1), r12
	mov	#3, r13
	call	#__mspabi_mpyi
	mov	r12, 8(r1)
	mov	14(r1), r12
	add	r12, r12
	add	r12, r12
	mov	r12, 6(r1)
	mov	12(r1), r12
	mov	#5, r13
	call	#__mspabi_mpyi
	mov	r12, 4(r1)
	mov	18(r1), r12
	mov	16(r1), r13
	call	#__mspabi_mpyi
	mov	r12, 2(r1)
	mov	14(r1), r12
	mov	12(r1), r13
	call	#__mspabi_mpyi
	mov	r12, 0(r1)
	mov	10(r1), r13
	mov	8(r1), r12
	add	r12, r13
	mov	6(r1), r12
	add	r12, r13
	mov	4(r1), r12
	add	r12, r13
	mov	2(r1), r12
	add	r12, r13
	mov	0(r1), r12
	add	r12, r13
	mov	18(r1), r12
	add	r12, r13
	mov	16(r1), r12
	add	r12, r13
	mov	14(r1), r12
	add	r12, r13
	mov	12(r1), r12
	add	r12, r13
	mov	r13, r12
	add	#20, r1
	ret
.Lfunc_end0:
	.size	pressure, .Lfunc_end0-pressure
                                        ; -- End function
	.ident	"clang version 22.0.0git (git@github.com:llvm/llvm-project.git 7e55a4c9937dfc2184636ad7f3c9f7eccfad6186)"
	.section	".note.GNU-stack","",@progbits
