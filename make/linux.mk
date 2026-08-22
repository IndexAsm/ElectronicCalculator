# ============================================================
# Linux Platform Configuration
# ============================================================

COMPILER_ASM := nasm -f elf64
COMPILER_C := gcc
COMPILER_CPP := g++

EXE_NAME := index
RUNNER :=

LINK_FLAGS := $(CPP_MODE_FLAGS)
