# ============================================================
# Windows Platform Configuration
# ============================================================

COMPILER_ASM := wine build-tools/nasm/nasm.exe -f win64
COMPILER_C := x86_64-w64-mingw32-gcc
COMPILER_CPP := x86_64-w64-mingw32-g++

EXE_NAME := index.exe
RUNNER := wine

LINK_FLAGS := $(CPP_MODE_FLAGS) -static -static-libgcc -static-libstdc++
