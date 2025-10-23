--- |
  ; ModuleID = 'glacier1.mir'
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
noVRegs:         true
hasFakeUses:     false
callsEHReturn:   false
callsUnwindInit: false
hasEHContTarget: false
hasEHScopes:     false
hasEHFunclets:   false
isOutlined:      false
debugInstrRef:   false
failsVerification: false
tracksDebugUserValues: true
registers:       []
liveins:         []
frameInfo:
  isFrameAddressTaken: false
  isReturnAddressTaken: false
  hasStackMap:     false
  hasPatchPoint:   false
  stackSize:       16
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
  isCalleeSavedInfoValid: true
  localFrameSize:  12
fixedStack:      []
stack:
  - { id: 0, name: retval, type: default, offset: -4, size: 4, alignment: 4, 
      stack-id: default, callee-saved-register: '', callee-saved-restored: true, 
      local-offset: -4, debug-info-variable: '', debug-info-expression: '', 
      debug-info-location: '' }
  - { id: 1, name: a, type: default, offset: -8, size: 4, alignment: 4, 
      stack-id: default, callee-saved-register: '', callee-saved-restored: true, 
      local-offset: -8, debug-info-variable: '', debug-info-expression: '', 
      debug-info-location: '' }
  - { id: 2, name: b, type: default, offset: -12, size: 4, alignment: 4, 
      stack-id: default, callee-saved-register: '', callee-saved-restored: true, 
      local-offset: -12, debug-info-variable: '', debug-info-expression: '', 
      debug-info-location: '' }
entry_values:    []
callSites:       []
debugValueSubstitutions: []
constants:       []
machineFunctionInfo:
  hasRedZone:      false
  stackSizeSVE:    0
body:             |
  bb.0.entry:
    $sp = frame-setup SUBXri $sp, 16, 0
    frame-setup CFI_INSTRUCTION def_cfa_offset 16
    STRWui $wzr, $sp, 3 :: (store (s32) into %stack.0.retval)
    renamable $w8 = LDRWui $sp, 2 :: (load (s32) from %stack.1.a)
    renamable $w9 = LDRWui $sp, 1 :: (load (s32) from %stack.2.b)
    $w8 = ADDWrs killed renamable $w8, killed renamable $w9, 0
    STRWui killed renamable $w8, $sp, 2 :: (store (s32) into %stack.1.a)
    $w0 = MOVZWi 1, 0
    $sp = frame-destroy ADDXri $sp, 16, 0
    RET undef $lr, implicit killed $w0
...
