--- |
  ; ModuleID = 'test1.mir'
  source_filename = "test1.ll"
  target datalayout = "e-m:o-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-n32:64-S128-Fn32"
  
  define i32 @add(i32 %a, i32 %b) {
  entry:
    %sum = add i32 %a, %b
    ret i32 %sum
  }
...
---
name:            add
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
liveins:
  - { reg: '$w0', virtual-reg: '' }
  - { reg: '$w1', virtual-reg: '' }
frameInfo:
  isFrameAddressTaken: false
  isReturnAddressTaken: false
  hasStackMap:     false
  hasPatchPoint:   false
  stackSize:       0
  offsetAdjustment: 0
  maxAlignment:    1
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
  localFrameSize:  0
fixedStack:      []
stack:           []
entry_values:    []
callSites:       []
debugValueSubstitutions: []
constants:       []
machineFunctionInfo:
  hasRedZone:      false
  stackSizeSVE:    0
body:             |
  bb.0.entry:
    liveins: $w0, $w1
  
    $w0 = ADDWrs killed renamable $w0, killed renamable $w1, 0
    RET undef $lr, implicit killed $w0
...
