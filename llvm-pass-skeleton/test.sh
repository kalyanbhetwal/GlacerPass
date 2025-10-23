#!/bin/bash

# Path to your LLVM installation
LLVM_DIR="/Users/kb/Documents/myllvmfor-msp430/llvm-install"

echo "1. Compiling C to LLVM IR..."
$LLVM_DIR/bin/clang -O1 -emit-llvm -S test.c -o test.ll

echo ""
echo "2. Compiling to machine code with your minimal register allocator..."
$LLVM_DIR/bin/llc -load=./build/skeleton/SkeletonPass.dylib \
    -regalloc=minimal \
    -debug-only=minimal \
    test.ll -o test.s

echo ""
echo "3. Done! Check the output above for your allocator's debug messages."
echo "   Generated assembly in test.s"
