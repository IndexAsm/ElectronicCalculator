# ============================================================
# AVR Platform Configuration
# ============================================================

MCU ?= atmega328p
F_CPU ?= 16000000UL

PROGRAMMER ?= arduino
PORT ?= /dev/ttyUSB0

COMPILER_C := avr-gcc
COMPILER_CPP := avr-g++
COMPILER_ASM := avr-gcc

OBJCOPY := avr-objcopy
AVRDUDE := avrdude

ARDUINO_AVR ?= $(HOME)/.arduino15/packages/arduino/hardware/avr/1.8.8
ARDUINO_CORE_DIR := $(ARDUINO_AVR)/cores/arduino
VARIANT_DIR := $(ARDUINO_AVR)/variants/standard

EXE_NAME := firmware.elf
RUNNER :=

MCU_FLAGS := -mmcu=$(MCU) -DF_CPU=$(F_CPU)

SYSTEM_INCLUDES := -isystem /usr/avr/include

C_FLAGS += $(MCU_FLAGS) -I$(ARDUINO_CORE_DIR) -I$(VARIANT_DIR) $(SYSTEM_INCLUDES)
CPP_FLAGS += $(MCU_FLAGS) -I$(ARDUINO_CORE_DIR) -I$(VARIANT_DIR) $(SYSTEM_INCLUDES)
ASM_FLAGS += $(MCU_FLAGS) $(C_MODE_FLAGS)

RAW_ARDUINO_CORE_C   := $(wildcard $(ARDUINO_CORE_DIR)/*.c)
RAW_ARDUINO_CORE_CPP := $(wildcard $(ARDUINO_CORE_DIR)/*.cpp)
RAW_ARDUINO_CORE_ASM := $(wildcard $(ARDUINO_CORE_DIR)/*.S)

CLEAN_ARDUINO_C   := $(filter-out %/wiring_pulse.c, $(RAW_ARDUINO_CORE_C))
CLEAN_ARDUINO_CPP := $(filter-out %/main.cpp, $(RAW_ARDUINO_CORE_CPP))

ARDUINO_CORE_SOURCES := $(CLEAN_ARDUINO_C) $(CLEAN_ARDUINO_CPP) $(RAW_ARDUINO_CORE_ASM)

ALL_SOURCES += $(ARDUINO_CORE_SOURCES)

LINK_FLAGS := $(CPP_MODE_FLAGS) $(MCU_FLAGS)

OBJCOPYFLAGS := -j .text -j .data -O ihex
AVRDUDEFLAGS := -p $(MCU) -c $(PROGRAMMER) -P $(PORT) -b 115200
