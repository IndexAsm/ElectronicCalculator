# ============================================================
# Generic static-library build rules.
# Included by libraries/<Name>/Makefile, which must set LIB_NAME
# before including this file. Builds ONLY a lib<Name>.a - never
# an executable.
# ============================================================

ifndef LIB_NAME
$(error LIB_NAME must be set before including make/lib.mk)
endif

include ../../make/config.mk

PLATFORM ?= $(CONFIG_DEFAULT_PLATFORM)
MODE     ?= $(CONFIG_DEFAULT_MODE)

ifeq ($(filter $(PLATFORM),$(CONFIG_ALLOWED_PLATFORMS)),)
$(error Unknown PLATFORM '$(PLATFORM)'. Allowed platforms: $(CONFIG_ALLOWED_PLATFORMS))
endif

ifeq ($(filter $(MODE),$(CONFIG_ALLOWED_MODES)),)
$(error Unknown MODE '$(MODE)'. Allowed modes: $(CONFIG_ALLOWED_MODES))
endif

CVER   ?= $(CONFIG_DEFAULT_CVER)
CPPVER ?= $(CONFIG_DEFAULT_CPPVER)

INC_DIR  := include
CORE_DIR := src/core
PLAT_DIR := src/platform/$(PLATFORM)

BUILD_DIR := build/$(PLATFORM)/$(MODE)
OBJ_DIR   := $(BUILD_DIR)/obj
OUT_LIB   := $(BUILD_DIR)/lib$(LIB_NAME).a

ifeq ($(MODE),debug)
	MODE_FLAGS := -g -O0
else ifeq ($(MODE),release)
	MODE_FLAGS := -O3
endif

ifeq ($(PLATFORM),linux)
	COMPILER_C   := gcc
	COMPILER_CPP := g++
	COMPILER_ASM := nasm -f elf64
else ifeq ($(PLATFORM),windows)
	COMPILER_C   := x86_64-w64-mingw32-gcc
	COMPILER_CPP := x86_64-w64-mingw32-g++
	COMPILER_ASM := wine ../../build-tools/nasm/nasm.exe -f win64
else ifeq ($(PLATFORM),avr)
	COMPILER_C   := avr-gcc
	COMPILER_CPP := avr-g++
	COMPILER_ASM := avr-gcc
else ifeq ($(PLATFORM),ch32)
	PREFIX       ?= riscv64-unknown-elf
	COMPILER_C   := $(PREFIX)-gcc
	COMPILER_CPP := $(PREFIX)-g++
	COMPILER_ASM := $(PREFIX)-gcc
endif

AR := ar rcs

# EXTRA_INC lets a library (e.g. a backend like GLFW) add extra
# -I paths (such as a vendored dependency's own include/ dir).
C_FLAGS   := -Wall -std=$(CVER)   -I$(INC_DIR) -I$(CORE_DIR) $(EXTRA_INC) $(MODE_FLAGS)
CPP_FLAGS := -Wall -std=$(CPPVER) -I$(INC_DIR) -I$(CORE_DIR) $(EXTRA_INC) $(MODE_FLAGS)
ASM_FLAGS :=

CORE_SOURCES := $(sort $(shell find $(CORE_DIR) -type f \( -name '*.cpp' -o -name '*.c' -o -name '*.S' \) 2>/dev/null))
PLAT_SOURCES := $(wildcard $(PLAT_DIR)/*.cpp) $(wildcard $(PLAT_DIR)/*.c) $(wildcard $(PLAT_DIR)/*.S)

ALL_SOURCES := $(CORE_SOURCES) $(PLAT_SOURCES) $(EXTRA_SOURCES)

OBJECTS := $(patsubst %.cpp,$(OBJ_DIR)/%.o,$(filter %.cpp,$(ALL_SOURCES))) \
           $(patsubst %.c,$(OBJ_DIR)/%.o,$(filter %.c,$(ALL_SOURCES))) \
           $(patsubst %.S,$(OBJ_DIR)/%.o,$(filter %.S,$(ALL_SOURCES)))

.PHONY: all build clean
all: build

build: $(OUT_LIB)
	@echo "Built static library $(OUT_LIB)"

$(OUT_LIB): $(OBJECTS)
	@mkdir -p $(dir $@)
	$(AR) $@ $(OBJECTS)

$(OBJ_DIR)/%.o: %.cpp
	@mkdir -p $(dir $@)
	@echo "Compiling $(LIB_NAME): $<..."
	$(COMPILER_CPP) $(CPP_FLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: %.c
	@mkdir -p $(dir $@)
	@echo "Compiling $(LIB_NAME): $<..."
	$(COMPILER_C) $(C_FLAGS) -c $< -o $@

$(OBJ_DIR)/%.o: %.S
	@mkdir -p $(dir $@)
	@echo "Assembling $(LIB_NAME): $<..."
	$(COMPILER_ASM) $(ASM_FLAGS) -x assembler-with-cpp -c $< -o $@

clean:
	rm -rf build
