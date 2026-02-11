#!/bin/bash

# Restaurant Billing System - Assembly
# Compilation Instructions

echo "========================================"
echo "  COMPILING RESTAURANT BILLING SYSTEM"
echo "========================================"

# Compile with NASM
echo "[1/3] Assembling with NASM..."
nasm -f elf32 -o restaurant.o restaurant.asm

# Link with GCC
echo "[2/3] Linking with GCC..."
gcc -m32 -no-pie -o restaurant restaurant.o -lc

# Check if compilation successful
if [ -f restaurant ]; then
    echo "[3/3] ✅ Compilation successful!"
    echo ""
    echo "========================================"
    echo "  TO RUN THE PROGRAM:"
    echo "  ./restaurant"
    echo "========================================"
else
    echo "[3/3] ❌ Compilation failed!"
    echo ""
    echo "Please install NASM and GCC:"
    echo "  Ubuntu/Debian: sudo apt install nasm gcc-multilib"
    echo "  Fedora: sudo dnf install nasm gcc"
    echo "  Arch: sudo pacman -S nasm gcc"
fi
