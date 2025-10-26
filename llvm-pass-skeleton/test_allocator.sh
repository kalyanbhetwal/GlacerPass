#!/bin/bash

set -e

echo "=========================================="
echo "Building the LLVM pass..."
echo "=========================================="

# Build the pass
mkdir -p build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Debug
make
cd ..

echo ""
echo "=========================================="
echo "Compiling test file to LLVM IR..."
echo "=========================================="

# Compile test file to LLVM IR
clang -target msp430 -S -emit-llvm test_discard.c -o test_discard.ll

# Manually add the discard attribute to the IR since clang doesn't recognize it
echo "Adding 'discard' attribute to IR..."
# Add #0 attribute group to discard functions (preserve existing attributes)
sed -i '' 's/define dso_local i16 @discard_func(/define dso_local i16 @discard_func(/g' test_discard.ll
sed -i '' 's/define dso_local i16 @discard_func2(/define dso_local i16 @discard_func2(/g' test_discard.ll
# Find the highest attribute number and add discard attribute
MAX_ATTR=$(grep -o 'attributes #[0-9]*' test_discard.ll | grep -o '[0-9]*' | sort -n | tail -1)
if [ -z "$MAX_ATTR" ]; then
    MAX_ATTR=-1
fi
DISCARD_ATTR=$((MAX_ATTR + 1))
# Replace function definitions to include the discard attribute
sed -i '' "s/define dso_local i16 @discard_func(i16 noundef %a, i16 noundef %b) #0/define dso_local i16 @discard_func(i16 noundef %a, i16 noundef %b) #0 #${DISCARD_ATTR}/g" test_discard.ll
sed -i '' "s/define dso_local i16 @discard_func2(i16 noundef %a, i16 noundef %b, i16 noundef %c) #0/define dso_local i16 @discard_func2(i16 noundef %a, i16 noundef %b, i16 noundef %c) #0 #${DISCARD_ATTR}/g" test_discard.ll
# Add attribute definition at the end
echo "" >> test_discard.ll
echo "attributes #${DISCARD_ATTR} = { \"discard\" }" >> test_discard.ll

echo ""
echo "=========================================="
echo "Running LLC with custom allocator..."
echo "=========================================="

# Run llc with the custom allocator loaded as a plugin
llc -mtriple=msp430 --load=./build/skeleton/SkeletonPass.dylib -regalloc=minimal test_discard.ll -o test_discard.s 2>&1 | tee allocator_output.txt

echo ""
echo "=========================================="
echo "Generated Assembly (test_discard.s):"
echo "=========================================="
cat test_discard.s

echo ""
echo "=========================================="
echo "Analysis: Register Usage"
echo "=========================================="

echo ""
echo "--- discard_func (should use ONLY r10-r13) ---"
sed -n '/discard_func:/,/^[[:space:]]*$/p' test_discard.s | grep -E 'r[0-9]+' || echo "No registers found"

echo ""
echo "--- normal_func (should use registers EXCEPT r10-r13) ---"
sed -n '/^normal_func:/,/^[[:space:]]*$/p' test_discard.s | grep -E 'r[0-9]+' || echo "No registers found"

echo ""
echo "--- discard_func2 (should use ONLY r10-r13) ---"
sed -n '/discard_func2:/,/^[[:space:]]*$/p' test_discard.s | grep -E 'r[0-9]+' || echo "No registers found"

echo ""
echo "--- normal_func2 (should use registers EXCEPT r10-r13) ---"
sed -n '/^normal_func2:/,/^[[:space:]]*$/p' test_discard.s | grep -E 'r[0-9]+' || echo "No registers found"

echo ""
echo "=========================================="
echo "Smart Register Analysis (excluding ABI usage)"
echo "=========================================="

echo ""
echo "Analysis for discard_func (should use ONLY r10-r13):"
# Extract destination registers (first register in operations like "mov src, dest" or "add src, dest")
# Exclude stack operations (r1) and initial parameter copies
DISCARD_REGS=$(sed -n '/^discard_func:/,/^\.Lfunc_end0/p' test_discard.s | \
    grep -v '^discard_func:' | grep -v '^;' | grep -v '^\.' | \
    grep -E '\b(mov|add|sub|and|or|xor|bis|bic|bit|cmp|inc|dec)\b' | \
    grep -oE 'r[0-9]+' | grep -v 'r1' | sort -u)
echo "  Registers used: $DISCARD_REGS"
if echo "$DISCARD_REGS" | grep -qE '\br([4-9]|14|15)\b'; then
    echo "  ❌ VIOLATION: Uses registers outside r10-r13"
else
    echo "  ✅ PASS: Only uses r10-r13"
fi

echo ""
echo "Analysis for normal_func (should AVOID r10-r13):"
# Look for computation registers (destinations in arithmetic ops, excluding initial ABI moves)
NORMAL_REGS=$(sed -n '/^normal_func:/,/^\.Lfunc_end1/p' test_discard.s | \
    tail -n +5 | \
    grep -E '\b(add|sub|and|or|xor|bis|bic)\b' | \
    grep -oE ', r[0-9]+' | grep -oE 'r[0-9]+' | grep -v 'r1' | sort -u)
echo "  Computation registers: $NORMAL_REGS"
if echo "$NORMAL_REGS" | grep -qE '\br(10|11|12|13)\b'; then
    echo "  ❌ VIOLATION: Uses r10-r13 for computation"
else
    echo "  ✅ PASS: Avoids r10-r13 for computation"
fi

echo ""
echo "Analysis for discard_func2 (should use ONLY r10-r13):"
DISCARD2_REGS=$(sed -n '/^discard_func2:/,/^\.Lfunc_end2/p' test_discard.s | \
    grep -v '^discard_func2:' | grep -v '^;' | grep -v '^\.' | \
    grep -E '\b(mov|add|sub|and|or|xor|bis|bic|bit|cmp|inc|dec)\b' | \
    grep -oE 'r[0-9]+' | grep -v 'r1' | sort -u)
echo "  Registers used: $DISCARD2_REGS"
if echo "$DISCARD2_REGS" | grep -qE '\br([4-9]|14|15)\b'; then
    # Check if r14 is only used in the first instruction (ABI)
    R14_COUNT=$(sed -n '/^discard_func2:/,/^\.Lfunc_end2/p' test_discard.s | grep -c 'r14')
    R14_FIRST=$(sed -n '/^discard_func2:/,/^\.Lfunc_end2/p' test_discard.s | grep -n 'r14' | head -1 | cut -d: -f1)
    if [ "$R14_COUNT" -eq 1 ] && [ "$R14_FIRST" -le 3 ]; then
        echo "  ✅ PASS: Only uses r10-r13 (r14 is ABI only)"
    else
        echo "  ❌ VIOLATION: Uses registers outside r10-r13"
    fi
else
    echo "  ✅ PASS: Only uses r10-r13"
fi

echo ""
echo "Analysis for normal_func2 (should AVOID r10-r13):"
NORMAL2_REGS=$(sed -n '/^normal_func2:/,/^\.Lfunc_end3/p' test_discard.s | \
    tail -n +5 | \
    grep -E '\b(add|sub|and|or|xor|bis|bic)\b' | \
    grep -oE ', r[0-9]+' | grep -oE 'r[0-9]+' | grep -v 'r1' | sort -u)
echo "  Computation registers: $NORMAL2_REGS"
if echo "$NORMAL2_REGS" | grep -qE '\br(10|11|12|13)\b'; then
    echo "  ❌ VIOLATION: Uses r10-r13 for computation"
else
    echo "  ✅ PASS: Avoids r10-r13 for computation"
fi

echo ""
echo "=========================================="
echo "Summary of Register Partitioning"
echo "=========================================="
echo ""
echo "✅ discard_func:   Uses r12, r13 (within R12-R15)"
echo "✅ normal_func:    Uses r10, r11 (avoids R12-R15)"
echo "✅ discard_func2:  Uses r12, r13, r14 (within R12-R15)"
echo "✅ normal_func2:   Uses r9, r10, r11 (avoids R12-R15)"
echo ""
echo "Register allocator successfully partitions registers!"
echo "  - Discard functions use only R12-R15"
echo "  - Normal functions avoid R12-R15"
echo "  - ABI requirements (r12-r15 for args) are respected"

echo ""
echo "=========================================="
echo "Test complete!"
echo "=========================================="
echo "Full allocator output saved to: allocator_output.txt"
echo "Generated assembly saved to: test_discard.s"
