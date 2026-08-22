# ============================================================
# Common build configuration
# ============================================================

BUILD_DIR := build/$(PLATFORM)/$(MODE)
OBJ_DIR := $(BUILD_DIR)/obj
DEP_DIR := $(BUILD_DIR)/dep

CVER   ?= $(CONFIG_DEFAULT_CVER)
CPPVER ?= $(CONFIG_DEFAULT_CPPVER)

ifeq ($(MODE),debug)
	C_MODE_FLAGS := -g -O0
	CPP_MODE_FLAGS := -g -O0
	ASM_MODE_FLAGS :=
else ifeq ($(MODE),release)
	C_MODE_FLAGS := -O3
	CPP_MODE_FLAGS := -O3
	ASM_MODE_FLAGS :=
else
	$(error Unknown MODE: $(MODE))
endif

# ============================================================
# Library discovery
# Every directory under libraries/ that has its own Makefile is
# built independently (see make/lib.mk) into a static lib<Name>.a.
# ============================================================

LIBRARIES    := $(patsubst libraries/%/Makefile,%,$(wildcard libraries/*/Makefile))
LIBRARY_DIRS := $(addprefix libraries/,$(LIBRARIES))
LIB_INCLUDES := $(foreach lib,$(LIBRARIES),-Ilibraries/$(lib)/include)
LIB_ARCHIVES := $(foreach lib,$(LIBRARIES),libraries/$(lib)/build/$(PLATFORM)/$(MODE)/lib$(lib).a)

C_FLAGS := \
	-Wall \
	-std=$(CVER) \
	-Isrc \
	-Isrc/core \
	$(LIB_INCLUDES)

CPP_FLAGS := \
	-Wall \
	-std=$(CPPVER) \
	-Isrc \
	-Isrc/core \
	$(LIB_INCLUDES)

ASM_FLAGS :=

C_FLAGS += $(C_MODE_FLAGS)
CPP_FLAGS += $(CPP_MODE_FLAGS)

# ============================================================
# Dynamic Source Discovery Pipeline
# (project sources only - library sources are compiled by each
# library's own Makefile, see make/lib.mk)
# ============================================================

CORE_DIR := src/core

CORE_SOURCES := $(sort $(shell find $(CORE_DIR) -type f \( -name '*.cpp' -o -name '*.c' -o -name '*.S' \)))

PLATFORM_DIR := src/platform/$(PLATFORM)

PLATFORM_SOURCES := $(wildcard $(PLATFORM_DIR)/*.cpp) \
                    $(wildcard $(PLATFORM_DIR)/*.c)   \
                    $(wildcard $(PLATFORM_DIR)/*.S)

ALL_SOURCES = $(CORE_SOURCES) $(PLATFORM_SOURCES) $(EXTRA_SOURCES)

# Optional: platforms/frameworks can append additional sources via EXTRA_SOURCES

ABS_SRCS = $(filter /%,$(ALL_SOURCES))
REL_SRCS = $(filter-out /%,$(ALL_SOURCES))

OBJECTS = $(patsubst %.cpp,$(OBJ_DIR)/%.o,$(filter %.cpp,$(REL_SRCS))) \
          $(patsubst %.c,$(OBJ_DIR)/%.o,$(filter %.c,$(REL_SRCS))) \
          $(patsubst %.S,$(OBJ_DIR)/%.o,$(filter %.S,$(REL_SRCS))) \
          $(patsubst %.asm,$(OBJ_DIR)/%.o,$(filter %.asm,$(REL_SRCS)))

OBJECTS += $(patsubst /%.cpp,$(OBJ_DIR)/abs/%.o,$(filter %.cpp,$(ABS_SRCS))) \
           $(patsubst /%.c,$(OBJ_DIR)/abs/%.o,$(filter %.c,$(ABS_SRCS))) \
           $(patsubst /%.S,$(OBJ_DIR)/abs/%.o,$(filter %.S,$(ABS_SRCS)))

DEP_FILES = $(patsubst $(OBJ_DIR)/%.o,$(DEP_DIR)/%.d,$(OBJECTS))

AR := ar rcs
