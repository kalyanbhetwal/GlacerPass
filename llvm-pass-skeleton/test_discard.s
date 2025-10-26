	.file	"test_discard.c"
	.text
	.globl	discard_func                    ; -- Begin function discard_func
	.p2align	1
	.type	discard_func,@function
discard_func:                           ; @discard_func
; %bb.0:                                ; %entry
	sub	#12, r1
	mov	r12, 10(r1)
	mov	r13, 8(r1)
	mov	10(r1), r13
	mov	8(r1), r12
	add	r12, r13
	mov	r13, 6(r1)
	mov	6(r1), r12
	add	r12, r12
	mov	r12, 4(r1)
	mov	4(r1), r13
	mov	10(r1), r12
	sub	r12, r13
	mov	r13, 2(r1)
	mov	2(r1), r13
	mov	6(r1), r12
	add	r12, r13
	mov	r13, 0(r1)
	mov	0(r1), r13
	mov	8(r1), r12
	add	r12, r13
	mov	r13, r12
	add	#12, r1
	ret
.Lfunc_end0:
	.size	discard_func, .Lfunc_end0-discard_func
                                        ; -- End function
	.globl	normal_func                     ; -- Begin function normal_func
	.p2align	1
	.type	normal_func,@function
normal_func:                            ; @normal_func
; %bb.0:                                ; %entry
	sub	#12, r1
	mov	r13, r15
	mov	r12, r14
	mov	r14, 10(r1)
	mov	r15, 8(r1)
	mov	10(r1), r15
	mov	8(r1), r14
	add	r14, r15
	mov	r15, 6(r1)
	mov	6(r1), r14
	add	r14, r14
	mov	r14, 4(r1)
	mov	4(r1), r15
	mov	10(r1), r14
	sub	r14, r15
	mov	r15, 2(r1)
	mov	2(r1), r15
	mov	6(r1), r14
	add	r14, r15
	mov	r15, 0(r1)
	mov	0(r1), r15
	mov	8(r1), r14
	add	r14, r15
	mov	r15, r12
	add	#12, r1
	ret
.Lfunc_end1:
	.size	normal_func, .Lfunc_end1-normal_func
                                        ; -- End function
	.globl	discard_func2                   ; -- Begin function discard_func2
	.p2align	1
	.type	discard_func2,@function
discard_func2:                          ; @discard_func2
; %bb.0:                                ; %entry
	sub	#10, r1
	mov	r14, r11
	mov	r12, 8(r1)
	mov	r13, 6(r1)
	mov	r11, 4(r1)
	clr	2(r1)
	clr	0(r1)
	jmp	.LBB2_1
.LBB2_1:                                ; %for.cond
                                        ; =>This Inner Loop Header: Depth=1
	mov	0(r1), r12
	mov	8(r1), r13
	cmp	r13, r12
	jge	.LBB2_4
	jmp	.LBB2_2
.LBB2_2:                                ; %for.body
                                        ;   in Loop: Header=BB2_1 Depth=1
	mov	6(r1), r12
	mov	4(r1), r13
	call	#__mspabi_mpyi
	mov	2(r1), r13
	add	r12, r13
	mov	r13, 2(r1)
	jmp	.LBB2_3
.LBB2_3:                                ; %for.inc
                                        ;   in Loop: Header=BB2_1 Depth=1
	mov	0(r1), r12
	inc	r12
	mov	r12, 0(r1)
	jmp	.LBB2_1
.LBB2_4:                                ; %for.end
	mov	2(r1), r12
	add	#10, r1
	ret
.Lfunc_end2:
	.size	discard_func2, .Lfunc_end2-discard_func2
                                        ; -- End function
	.globl	normal_func2                    ; -- Begin function normal_func2
	.p2align	1
	.type	normal_func2,@function
normal_func2:                           ; @normal_func2
; %bb.0:                                ; %entry
	push	r9
	sub	#10, r1
	mov	r14, r9
	mov	r13, r15
	mov	r12, r14
	mov	r14, 8(r1)
	mov	r15, 6(r1)
	mov	r9, 4(r1)
	clr	2(r1)
	clr	0(r1)
	jmp	.LBB3_1
.LBB3_1:                                ; %for.cond
                                        ; =>This Inner Loop Header: Depth=1
	mov	0(r1), r14
	mov	8(r1), r15
	cmp	r15, r14
	jge	.LBB3_4
	jmp	.LBB3_2
.LBB3_2:                                ; %for.body
                                        ;   in Loop: Header=BB3_1 Depth=1
	mov	6(r1), r14
	mov	4(r1), r15
	mov	r14, r12
	mov	r15, r13
	call	#__mspabi_mpyi
	mov	r12, r14
	mov	2(r1), r15
	add	r14, r15
	mov	r15, 2(r1)
	jmp	.LBB3_3
.LBB3_3:                                ; %for.inc
                                        ;   in Loop: Header=BB3_1 Depth=1
	mov	0(r1), r14
	inc	r14
	mov	r14, 0(r1)
	jmp	.LBB3_1
.LBB3_4:                                ; %for.end
	mov	2(r1), r14
	mov	r14, r12
	add	#10, r1
	pop	r9
	ret
.Lfunc_end3:
	.size	normal_func2, .Lfunc_end3-normal_func2
                                        ; -- End function
	.ident	"clang version 22.0.0git (git@github.com:llvm/llvm-project.git 7e55a4c9937dfc2184636ad7f3c9f7eccfad6186)"
	.section	".note.GNU-stack","",@progbits
