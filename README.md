# GlacierPass (MSP430 Custom Register Allocator)

A custom LLVM register allocator for MSP430 that partitions registers based on function attributes.

## Overview

This project implements a custom register allocator that reserves specific registers for functions with the `discard` attribute:

- **Functions WITH `discard` attribute**: Use only **R12-R15**
- **Functions WITHOUT `discard` attribute**: Use **R4-R11** (avoiding R12-R15)


## Quick Start

### Prerequisites

- LLVM toolchain with MSP430 support (LLVM 22+)
- CMake 3.12 or later
- Clang with MSP430 target

### Build

```bash
cd llvm-pass-skeleton
mkdir -p build
cd build
cmake ..
make
cd ..
```

### Test

```bash
./test_allocator.sh
```

Expected output:
```
✅ discard_func:   Uses r12, r13 (within R12-R15)
✅ normal_func:    Uses r10, r11 (avoids R12-R15)
✅ discard_func2:  Uses r12, r13, r14 (within R12-R15)
✅ normal_func2:   Uses r9, r10, r11 (avoids R12-R15)

Register allocator successfully partitions registers!
```

## Usage

### 1. Compile C code to LLVM IR

```bash
clang -target msp430 -S -emit-llvm your_code.c -o your_code.ll
```

### 2. Add the `discard` attribute

Manually edit the `.ll` file to add the discard attribute:

```llvm
define i16 @my_function(i16 %a, i16 %b) #0 {
  ; function body
}

attributes #0 = { "discard" }
```

### 3. Run register allocation

```bash
llc -mtriple=msp430 --load=./build/skeleton/SkeletonPass.dylib \
    -regalloc=minimal your_code.ll -o your_code.s
```

### 4. Inspect the generated assembly

```bash
cat your_code.s
```

Functions with `discard` attribute will use only r12-r15 for computation.

## Implementation Details

### Register Partitioning

| Register Range | Discard Functions | Normal Functions | Notes |
|---------------|------------------|------------------|-------|
| **R4-R9**     | ❌ Not used      | ✅ Used          | Reserved for normal functions |
| **R10-R11**   | ❌ Not used      | ✅ Used          | Reserved for normal functions |
| **R12-R15**   | ✅ Used          | ABI only         | Reserved for discard functions |

**Special Note:** R12-R15 are used by the MSP430 calling convention for argument passing and return values. Normal functions must copy arguments to other registers (R4-R11) for computation.

### Algorithm

The allocator works by filtering available registers based on function attributes:

1. Get the default register allocation order
2. Check if the function has the `discard` attribute
3. Filter registers:
   - **Discard functions**: Keep only R12-R15
   - **Normal functions**: Remove R12-R15
4. Attempt allocation from the filtered set
5. Spill to stack if necessary

### Code Location

The core implementation is in `skeleton/Skeleton.cpp`, lines 145-169:

```cpp
if (MF->getFunction().hasFnAttribute("discard")) {
    // Filter to keep only R12-R15
    ...
    outs() << "*** DISCARD MODE: Limited to R12-R15 ***\n";
} else {
    // Filter to remove R12-R15
    ...
    outs() << "*** NORMAL MODE: Using all registers except R12-R15 ***\n";
}
```

## Example

### Input C Code (`test_discard.c`)

```c
__attribute__((discard)) int discard_func(int a, int b) {
    int x = a + b;
    int y = x * 2;
    int z = y - a;
    int w = z + x;
    return w + b;
}

int normal_func(int a, int b) {
    int x = a + b;
    int y = x * 2;
    int z = y - a;
    int w = z + x;
    return w + b;
}
```

### Generated Assembly

**`discard_func` (uses R12-R15):**
```assembly
discard_func:
    sub  #12, r1
    mov  r12, 10(r1)    ; Only r12 and r13
    mov  r13, 8(r1)     ; are used for
    mov  10(r1), r13    ; all computation
    mov  8(r1), r12
    add  r12, r13
    ...
```

**`normal_func` (uses R10-R11):**
```assembly
normal_func:
    push r10
    sub  #12, r1
    mov  r13, r10       ; Copy args from r12-r13
    mov  r12, r11       ; to r10-r11 for computation
    mov  r11, 10(r1)
    mov  r10, 8(r1)
    add  r11, r10       ; All computation uses r10-r11
    ...
    mov  r10, r12       ; Copy result back to r12
    pop  r10
```

## Verification Results

All test cases pass:

| Function | Attribute | Expected Registers | Actual Registers | Result |
|----------|-----------|-------------------|------------------|--------|
| `discard_func` | `discard` | R12-R15 | r12, r13 | ✅ PASS |
| `normal_func` | none | R4-R11 | r10, r11 | ✅ PASS |
| `discard_func2` | `discard` | R12-R15 | r12, r13, r14 | ✅ PASS |
| `normal_func2` | none | R4-R11 | r9, r10, r11 | ✅ PASS |

## Debugging

To see detailed allocator output:

```bash
llc -mtriple=msp430 --load=./build/skeleton/SkeletonPass.dylib \
    -regalloc=minimal test_discard.ll -o test_discard.s 2>&1 | less
```

Look for debug messages:
- `*** DISCARD MODE: Limited to R12-R15 ***`
- `*** NORMAL MODE: Using all registers except R12-R15 ***`
- `Available registers before filtering: [...]`
- `Hint Registers: [...]`
- `Allocating physical register R12`

## Files

### Core Implementation
- `skeleton/Skeleton.cpp` - Custom register allocator implementation
- `skeleton/CMakeLists.txt` - Build configuration

### Test Files
- `test_discard.c` - Test cases with discard and normal functions
- `test_allocator.sh` - Automated build and test script
- `test_discard.ll` - Generated LLVM IR (with discard attributes)
- `test_discard.s` - Generated MSP430 assembly output
- `allocator_output.txt` - Full allocator debug output

### Documentation
- `README.md` - This file
- `FINAL_SUMMARY.md` - Detailed verification results and analysis
- `TESTING_GUIDE.md` - Complete testing guide with examples
- `VERIFICATION_SUMMARY.md` - Assembly-level verification

## Known Limitations

1. **Attribute Addition**: The `discard` attribute must be manually added to LLVM IR since Clang doesn't recognize it as a valid attribute. Consider creating a Clang plugin for source-level support.

2. **ABI Constraints**: The MSP430 calling convention requires R12-R15 for parameter passing and return values. This is respected but may cause additional register moves in normal functions.

3. **Register Pressure**: Discard functions have only 4 registers (R12-R15) available, which may increase spilling for complex computations.

4. **LLVM Version**: Built for LLVM 22+. May require adjustments for other versions.

## Future Enhancements

- [ ] Clang plugin to recognize `discard` attribute at source level
- [ ] Support for configurable register sets
- [ ] Performance optimization to reduce spilling
- [ ] Integration with MSP430 interrupt handlers
- [ ] Support for more fine-grained register allocation policies

## Technical Details

### MSP430 Register Set
- **R0-R3**: Special purpose (PC, SP, SR, CG)
- **R4-R15**: General purpose
- **R12-R15**: Used for function arguments/returns (ABI)

### Register Allocation Strategy
- **Discard functions**: 4 registers (R12-R15)
- **Normal functions**: 8 registers (R4-R11)
- **Stack pointer**: R1 (used by all)

### ABI Compliance
Both function types respect the MSP430 calling convention:
- Function arguments: R12-R15 (up to 4 words)
- Return value: R12
- Callee-saved: R4-R10
- Caller-saved: R11-R15

## References

- LLVM Register Allocator Documentation
- MSP430 ABI Specification
- LLVM Machine Code Framework

---

**Author**: Custom implementation for MSP430 register partitioning
**Last Updated**: 2025
**LLVM Version**: 22.0.0git
