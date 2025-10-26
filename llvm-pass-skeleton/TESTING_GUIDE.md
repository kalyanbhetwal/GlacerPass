# Custom MSP430 Register Allocator - Testing Guide

## Overview

This project implements a custom register allocator for MSP430 that partitions registers based on function attributes:

- **Functions with `discard` attribute**: Use only registers **R10-R13**
- **Functions without `discard` attribute**: Use all registers **EXCEPT R10-R13** (i.e., R4-R9, R14-R15)

This allows for register isolation between different classes of functions, useful for security, real-time constraints, or other specialized compilation requirements.

## What We've Done

### 1. Modified Register Allocator (`skeleton/Skeleton.cpp`)

**Key Changes:**

- **Lines 243-248**: Detect if a function has the `discard` attribute
  ```cpp
  bool hasDiscardAttr = MF.getFunction().hasFnAttribute("discard");
  ```

- **Lines 138-169**: Filter available registers based on the attribute
  - For `discard` functions: Keep only R10, R11, R12, R13
  - For normal functions: Keep all except R10, R11, R12, R13

- **Lines 313-342**: Removed the stack-only allocation mode to enable register allocation for all functions

### 2. Verification Results

After compilation, the generated assembly shows:

#### `discard_func` (with `discard` attribute)
**Registers used:** r12, r13
- ✅ Only uses R10-R13 range
- Lines 6-33 in test_discard.s

#### `normal_func` (without `discard` attribute)
**Registers used:** r12 (args only), r13 (args only), r14, r15
- ✅ Uses R14-R15 for computation (avoids R10-R13)
- r12/r13 appear only at function entry/exit for ABI compliance
- Lines 38-67 in test_discard.s

#### `discard_func2` (with `discard` attribute)
**Registers used:** r11, r12, r13, r14 (arg only)
- ✅ Uses R10-R13 for computation
- r14 appears only at function entry for ABI compliance
- Lines 72-109 in test_discard.s

#### `normal_func2` (without `discard` attribute)
**Registers used:** r9, r12 (args only), r13 (args only), r14, r15
- ✅ Uses R9, R14-R15 for computation (avoids R10-R13)
- r12/r13 appear only at function entry/exit for ABI compliance
- Lines 114-158 in test_discard.s

**Note:** Registers r12-r15 are used by the MSP430 calling convention for argument passing and return values. The allocator respects this ABI requirement while enforcing register partitioning for all other register uses.

## How to Test

### Prerequisites

- LLVM toolchain with MSP430 support
- CMake 3.12+
- Build tools (make, clang)

### Running the Test

```bash
cd /Users/kb/Documents/myllvmfor-msp430/GlacierPass/llvm-pass-skeleton
./test_allocator.sh
```

### What the Test Does

1. **Builds the pass**: Compiles `skeleton/Skeleton.cpp` into `SkeletonPass.dylib`

2. **Compiles test code**: Converts `test_discard.c` to LLVM IR (`test_discard.ll`)

3. **Adds discard attribute**: Manually adds the `discard` attribute to IR since Clang doesn't recognize it

4. **Runs register allocation**: Executes `llc` with the custom allocator:
   ```bash
   llc -mtriple=msp430 --load=./build/skeleton/SkeletonPass.dylib -regalloc=minimal test_discard.ll -o test_discard.s
   ```

5. **Verifies output**: Analyzes the generated assembly to confirm register usage

### Manual Testing

You can also test manually:

```bash
# 1. Build the pass
mkdir -p build && cd build
cmake ..
make
cd ..

# 2. Compile test file
clang -target msp430 -S -emit-llvm test_discard.c -o test.ll

# 3. Manually add discard attribute to test.ll
# Add 'attributes #N = { "discard" }' at the end
# Add '#N' to function definitions you want to mark as discard

# 4. Run register allocation
llc -mtriple=msp430 --load=./build/skeleton/SkeletonPass.dylib -regalloc=minimal test.ll -o test.s

# 5. Inspect the assembly
cat test.s
```

## Test Files

- **`test_discard.c`**: Test cases with 2 discard functions and 2 normal functions
- **`test_allocator.sh`**: Automated test script
- **`test_discard.ll`**: Generated LLVM IR (with discard attribute)
- **`test_discard.s`**: Generated MSP430 assembly
- **`allocator_output.txt`**: Full output from the allocator showing register selection

## Register Usage Summary

| Function Type | Allowed Registers | Excluded Registers |
|--------------|-------------------|-------------------|
| With `discard` | R10, R11, R12, R13 | R4-R9, R14-R15 |
| Without `discard` | R4-R9, R14-R15 | R10-R13 |
| All (ABI) | R12-R15 for args/returns | - |

**Special Registers:**
- **R1**: Stack pointer (used by all)
- **R12-R15**: Used for function arguments and return values (ABI requirement)

## Implementation Details

The allocator works by:

1. Getting the default register allocation order for each virtual register
2. Checking if the current function has the `discard` attribute
3. Filtering the available registers:
   - Discard functions: Keep only R10-R13
   - Normal functions: Remove R10-R13
4. Attempting to allocate from the filtered set
5. Spilling to stack if no registers are available

## Debugging

To see detailed allocator output:

```bash
llc -mtriple=msp430 --load=./build/skeleton/SkeletonPass.dylib -regalloc=minimal test_discard.ll -o test_discard.s 2>&1 | less
```

Look for:
- `*** DISCARD MODE: Limited to R10-R13 ***`
- `*** NORMAL MODE: Using all registers except R10-R13 ***`
- `Available registers before filtering: [...]`
- `Hint Registers: [...]`

## Known Limitations

1. The `discard` attribute must be added manually to LLVM IR (Clang doesn't recognize it as a valid attribute)
2. ABI constraints may force the use of R12-R15 for parameter passing
3. Very register-constrained functions may spill more frequently

## Summary of Changes Made

1. **Modified `skeleton/Skeleton.cpp`**:
   - Added discard attribute detection
   - Implemented register filtering based on function attribute
   - Changed from uppercase (R10) to lowercase (r10) was attempted but MSP430 uses uppercase register names internally

2. **Created test infrastructure**:
   - `test_discard.c` with sample functions
   - `test_allocator.sh` automated test script

3. **Verified functionality**:
   - discard_func: Uses r12, r13 ✅
   - normal_func: Uses r14, r15 ✅
   - discard_func2: Uses r11, r12, r13 ✅
   - normal_func2: Uses r9, r14, r15 ✅

The register allocator successfully partitions registers between discard and normal functions as intended!
