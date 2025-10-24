	.file	"test_spill2.c"
	.text
	.globl	test                            ; -- Begin function test
	.p2align	1
	.type	test,@function
test:                                   ; @test
; %bb.0:                                ; %entry
	sub	#20, r1
	mov	r12, 0(r1)                      ; 2-byte Folded Spill
	mov	22(r1), r12
	mov	0(r1), r12                      ; 2-byte Folded Reload
	mov	r12, 18(r1)
	mov	r13, 16(r1)
	mov	r14, 14(r1)
	mov	r15, 12(r1)
	mov	18(r1), r13
	mov	16(r1), r12
	add	r12, r13
	mov	r13, 10(r1)
	mov	14(r1), r13
	mov	12(r1), r12
	add	r12, r13
	mov	r13, 8(r1)
	mov	22(r1), r13
	mov	18(r1), r12
	add	r12, r13
	mov	r13, 6(r1)
	mov	10(r1), r13
	mov	8(r1), r12
	add	r12, r13
	mov	r13, 4(r1)
	mov	6(r1), r13
	mov	4(r1), r12
	add	r12, r13
	mov	r13, 2(r1)
	mov	2(r1), r13
	mov	16(r1), r12
	add	r12, r13
	mov	14(r1), r12
	add	r12, r13
	mov	12(r1), r12
	add	r12, r13
	mov	22(r1), r12
	add	r12, r13
	mov	r13, r12
	add	#20, r1
	ret
.Lfunc_end0:
	.size	test, .Lfunc_end0-test
                                        ; -- End function
	.ident	"clang version 22.0.0git (git@github.com:llvm/llvm-project.git 7e55a4c9937dfc2184636ad7f3c9f7eccfad6186)"
	.section	".note.GNU-stack","",@progbits
