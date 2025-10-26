# MSP430 Register Allocator - Final Implementation Summary

## Implementation Goal ✅
Reserve and only use **R12-R15** for functions with the `discard` attribute, while normal functions use all other available registers (excluding R12-R15).

## Final Verification Results

### Test Case 1: `discard_func` (with `discard` attribute)
**Expected:** Use only R12-R15
**Actual:** Uses **r12, r13**
**Result:** ✅ PASS

**Assembly (lines 6-31 in test_discard.s):**
```assembly
discard_func:
    sub  #12, r1
    mov  r12, 10(r1)    ; r12 used
    mov  r13, 8(r1)     ; r13 used
    mov  10(r1), r13    ; All computation
    mov  8(r1), r12     ; uses only
    add  r12, r13       ; r12 and r13
    ...
```

---

### Test Case 2: `normal_func` (without `discard` attribute)
**Expected:** Avoid R12-R15, use R4-R11
**Actual:** Uses **r10, r11**
**Result:** ✅ PASS

**Assembly (lines 33-64 in test_discard.s):**
```assembly
normal_func:
    push r10            ; r10 saved
    sub  #12, r1
    mov  r13, r10       ; ABI: copy param to r10
    mov  r12, r11       ; ABI: copy param to r11
    mov  r11, 10(r1)    ; All computation
    mov  r10, 8(r1)     ; uses only
    mov  10(r1), r10    ; r10 and r11
    mov  8(r1), r11     ; (avoiding R12-R15)
    add  r11, r10       ;
    ...
    mov  r10, r12       ; ABI: copy result back
    pop  r10
```

**Note:** r12, r13 appear only for ABI compliance (parameter passing/return)

---

### Test Case 3: `discard_func2` (with `discard` attribute)
**Expected:** Use only R12-R15
**Actual:** Uses **r12, r13, r14**
**Result:** ✅ PASS

**Assembly (lines 69-104 in test_discard.s):**
```assembly
discard_func2:
    sub  #10, r1
    mov  r12, 8(r1)     ; r12 used
    mov  r13, 6(r1)     ; r13 used
    mov  r14, 4(r1)     ; r14 used
    ...
    mov  0(r1), r12     ; Loop uses
    mov  8(r1), r13     ; r12, r13, r14
    cmp  r13, r12       ; only
    ...
```

---

### Test Case 4: `normal_func2` (without `discard` attribute)
**Expected:** Avoid R12-R15, use R4-R11
**Actual:** Uses **r9, r10, r11**
**Result:** ✅ PASS

**Assembly (lines 110-156 in test_discard.s):**
```assembly
normal_func2:
    push r9             ; r9 saved
    push r10            ; r10 saved
    sub  #10, r1
    mov  r14, r9        ; ABI: copy params
    mov  r13, r10       ; to r9, r10, r11
    mov  r12, r11       ;
    mov  r11, 8(r1)     ; All computation
    mov  r10, 6(r1)     ; uses only
    mov  r9, 4(r1)      ; r9, r10, r11
    ...
    mov  r11, r12       ; ABI: copy result back
    pop  r10
    pop  r9
```

---

## Register Partitioning Summary

### Distribution
| Register Range | Discard Functions | Normal Functions |
|---------------|------------------|------------------|
| **R4-R9**     | ❌ Not used      | ✅ Used          |
| **R10-R11**   | ❌ Not used      | ✅ Used          |
| **R12-R15**   | ✅ Used          | ❌ Not used (except ABI) |

### Actual Usage
| Function | Computation Registers | Notes |
|----------|---------------------|-------|
| `discard_func` | r12, r13 | ✅ Within R12-R15 |
| `normal_func` | r10, r11 | ✅ Avoids R12-R15 |
| `discard_func2` | r12, r13, r14 | ✅ Within R12-R15 |
| `normal_func2` | r9, r10, r11 | ✅ Avoids R12-R15 |

---

## Implementation Details

### Code Changes (`skeleton/Skeleton.cpp`)

**Lines 145-169:**
```cpp
// For functions with "discard" attribute, only use R12-R15
// For functions without "discard" attribute, use all registers EXCEPT R12-R15
if (MF->getFunction().hasFnAttribute("discard")) {
    SmallVector<MCPhysReg, 16> FilteredRegs;
    for (const MCPhysReg &PhysReg : Hints) {
        StringRef RegName = TRI->getRegAsmName(PhysReg);
        if (RegName == "R12" || RegName == "R13" || RegName == "R14" || RegName == "R15") {
            FilteredRegs.push_back(PhysReg);
        }
    }
    Hints.clear();
    Hints.append(FilteredRegs.begin(), FilteredRegs.end());
    outs() << "*** DISCARD MODE: Limited to R12-R15 ***\n";
} else {
    SmallVector<MCPhysReg, 16> FilteredRegs;
    for (const MCPhysReg &PhysReg : Hints) {
        StringRef RegName = TRI->getRegAsmName(PhysReg);
        if (RegName != "R12" && RegName != "R13" && RegName != "R14" && RegName != "R15") {
            FilteredRegs.push_back(PhysReg);
        }
    }
    Hints.clear();
    Hints.append(FilteredRegs.begin(), FilteredRegs.end());
    outs() << "*** NORMAL MODE: Using all registers except R12-R15 ***\n";
}
```

### Debug Output Examples

**Discard function:**
```
*** DISCARD MODE: Limited to R12-R15 ***
Hint Registers: [R12, R12, R13, R14, R15, ]
Allocating physical register R12
```

**Normal function:**
```
*** NORMAL MODE: Using all registers except R12-R15 ***
Hint Registers: [R11, R10, R9, R8, R7, R6, R5, R4, ]
Allocating physical register R11
```

---

## Testing

### How to Run
```bash
cd /Users/kb/Documents/myllvmfor-msp430/GlacierPass/llvm-pass-skeleton
./test_allocator.sh
```

### Test Files
- `test_discard.c` - Source code with 4 test functions
- `test_discard.ll` - Generated LLVM IR (with discard attributes)
- `test_discard.s` - Generated MSP430 assembly
- `allocator_output.txt` - Full allocator debug output
- `test_allocator.sh` - Automated build and test script

---

## Key Observations

### ABI Compliance
The MSP430 calling convention uses R12-R15 for:
- **R12-R15:** Function arguments (up to 4 words)
- **R12:** Return value

Therefore:
- **Discard functions:** Naturally use R12-R15 (good fit for both ABI and allocation)
- **Normal functions:** Must copy arguments from R12-R15 to other registers (R9-R11) for computation

### Register Pressure
- **Discard functions:** Have 4 registers (R12-R15) available
- **Normal functions:** Have 8 registers (R4-R11) available
- Both have sufficient registers for typical operations

---

## Conclusion

✅ **Implementation Successful**

The register allocator correctly:
1. Detects the `discard` function attribute
2. Limits discard functions to R12-R15 only
3. Prevents normal functions from using R12-R15 (except for ABI)
4. Respects MSP430 ABI requirements
5. Properly partitions register usage between function classes

**Result:** Registers R12-R15 are exclusively reserved for computation in functions with the `discard` attribute.
