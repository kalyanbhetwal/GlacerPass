--- |
  ; ModuleID = 'glacier_rest.mir'
  source_filename = "glacier.c"
  target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
  target triple = "arm64-apple-macosx26.0.0"
  
  ; Function Attrs: noinline nounwind optnone ssp uwtable(sync)
  define i32 @main() #0 {
  entry:
    %retval = alloca i32, align 4
    %a = alloca i32, align 4
    %b = alloca i32, align 4
    store i32 0, ptr %retval, align 4
    %0 = load i32, ptr %a, align 4
    %1 = load i32, ptr %b, align 4
    %add = add nsw i32 %0, %1
    store i32 %add, ptr %a, align 4
    ret i32 1
  }
  
  attributes #0 = { noinline nounwind optnone ssp uwtable(sync) "frame-pointer"="non-leaf" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="apple-m1" "target-features"="+aes,+altnzcv,+ccdp,+ccidx,+ccpp,+complxnum,+crc,+dit,+dotprod,+flagm,+fp-armv8,+fp16fml,+fptoint,+fullfp16,+jsconv,+lse,+neon,+pauth,+perfmon,+predres,+ras,+rcpc,+rdm,+sb,+sha2,+sha3,+specrestrict,+ssbs,+v8.1a,+v8.2a,+v8.3a,+v8.4a,+v8a" }
  
  !llvm.module.flags = !{!0, !1, !2, !3}
  !llvm.ident = !{!4}
  
  !0 = !{i32 1, !"wchar_size", i32 4}
  !1 = !{i32 8, !"PIC Level", i32 2}
  !2 = !{i32 7, !"uwtable", i32 1}
  !3 = !{i32 7, !"frame-pointer", i32 1}
  !4 = !{!"clang version 22.0.0git (git@github.com:llvm/llvm-project.git 7e55a4c9937dfc2184636ad7f3c9f7eccfad6186)"}
...
---
name:            main
alignment:       4
exposesReturnsTwice: false
legalized:       false
regBankSelected: false
selected:        false
failedISel:      false
tracksRegLiveness: true
hasWinCFI:       false
noPhis:          true
isSSA:           false
noVRegs:         false
hasFakeUses:     false
callsEHReturn:   false
callsUnwindInit: false
hasEHContTarget: false
hasEHScopes:     false
hasEHFunclets:   false
isOutlined:      false
debugInstrRef:   false
failsVerification: false
tracksDebugUserValues: false
registers:
  - { id: 0, class: gpr32, preferred-register: '', flags: [  ] }
  - { id: 1, class: gpr32, preferred-register: '', flags: [  ] }
  - { id: 2, class: gpr32, preferred-register: '', flags: [  ] }
  - { id: 3, class: gpr32, preferred-register: '', flags: [  ] }
  - { id: 4, class: gpr32, preferred-register: '', flags: [  ] }
  - { id: 5, class: gpr32, preferred-register: '', flags: [  ] }
  - { id: 6, class: gpr32, preferred-register: '', flags: [  ] }
liveins:         []
frameInfo:
  isFrameAddressTaken: false
  isReturnAddressTaken: false
  hasStackMap:     false
  hasPatchPoint:   false
  stackSize:       0
  offsetAdjustment: 0
  maxAlignment:    4
  adjustsStack:    false
  hasCalls:        false
  stackProtector:  ''
  functionContext: ''
  maxCallFrameSize: 0
  cvBytesOfCalleeSavedRegisters: 0
  hasOpaqueSPAdjustment: false
  hasVAStart:      false
  hasMustTailInVarArgFunc: false
  hasTailCall:     false
  isCalleeSavedInfoValid: false
  localFrameSize:  12
fixedStack:      []
stack:
  - { id: 0, name: retval, type: default, offset: 0, size: 4, alignment: 4, 
      stack-id: default, callee-saved-register: '', callee-saved-restored: true, 
      local-offset: -4, debug-info-variable: '', debug-info-expression: '', 
      debug-info-location: '' }
  - { id: 1, name: a, type: default, offset: 0, size: 4, alignment: 4, 
      stack-id: default, callee-saved-register: '', callee-saved-restored: true, 
      local-offset: -8, debug-info-variable: '', debug-info-expression: '', 
      debug-info-location: '' }
  - { id: 2, name: b, type: default, offset: 0, size: 4, alignment: 4, 
      stack-id: default, callee-saved-register: '', callee-saved-restored: true, 
      local-offset: -12, debug-info-variable: '', debug-info-expression: '', 
      debug-info-location: '' }
entry_values:    []
callSites:       []
debugValueSubstitutions: []
constants:       []
machineFunctionInfo: {}
body:             |
  bb.0.entry:
    STRWui $wzr, %stack.0.retval, 0 :: (store (s32) into %stack.0.retval)
    %6:gpr32 = LDRWui %stack.1.a, 0 :: (load (s32) from %stack.1.a)
    %5:gpr32 = LDRWui %stack.2.b, 0 :: (load (s32) from %stack.2.b)
    %4:gpr32 = ADDWrr killed %6, killed %5
    STRWui killed %4, %stack.1.a, 0 :: (store (s32) into %stack.1.a)
    %0:gpr32 = MOVi32imm 1
    $w0 = COPY killed %0
    RET_ReallyLR implicit killed $w0
...
