@echo off
REM Restaurant Billing System - Assembly
REM Compilation Instructions for Windows (with NASM and MinGW)

echo ========================================
echo   COMPILING RESTAURANT BILLING SYSTEM
echo ========================================

REM Compile with NASM
echo [1/3] Assembling with NASM...
nasm -f win32 -o restaurant.obj restaurant.asm

REM Link with GCC
echo [2/3] Linking with GCC...
gcc -m32 -o restaurant.exe restaurant.obj -lc

REM Check if compilation successful
if exist restaurant.exe (
    echo [3/3] ✅ Compilation successful!
    echo.
    echo ========================================
    echo   TO RUN THE PROGRAM:
    echo   restaurant.exe
    echo ========================================
) else (
    echo [3/3] ❌ Compilation failed!
    echo.
    echo Please install NASM and MinGW:
    echo   1. Download NASM: https://www.nasm.us/pub/nasm/releasebuilds/
    echo   2. Download MinGW: https://www.mingw-w64.org/
)
