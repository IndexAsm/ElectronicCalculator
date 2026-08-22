# ============================================================
# Build Rules
# ============================================================

.PHONY: all build run flash clean graph graph-html graph-view watch profile libs libs-clean

# Framework-provided link flags (written by genfw into make/framework.mk).
# Included here - after common.mk and <platform>.mk have both been
# processed - so it can safely append to LINK_FLAGS without being
# clobbered by a platform file's `LINK_FLAGS := ...` simple assignment.
-include make/framework.mk
LINK_FLAGS += $(FRAMEWORK_LINK_FLAGS)

all: $(EXE_NAME)

$(OBJ_DIR) $(DEP_DIR):
	@mkdir -p $@

libs:
ifneq ($(strip $(LIBRARY_DIRS)),)
	@for d in $(LIBRARY_DIRS); do \
		echo "Building library $$d ($(PLATFORM)/$(MODE))..."; \
		$(MAKE) -C $$d PLATFORM=$(PLATFORM) MODE=$(MODE) $(if $(PREFIX),PREFIX=$(PREFIX)) build || exit 1; \
	done
endif

libs-clean:
ifneq ($(strip $(LIBRARY_DIRS)),)
	@for d in $(LIBRARY_DIRS); do \
		$(MAKE) -C $$d clean; \
	done
endif

$(EXE_NAME): libs $(OBJ_DIR) $(DEP_DIR) $(OBJECTS)
	@echo "Linking $(EXE_NAME) for $(PLATFORM)..."
	$(COMPILER_CPP) $(OBJECTS) $(LIB_ARCHIVES) $(LINK_FLAGS) -o $@
ifeq ($(PLATFORM),avr)
	@echo "Creating HEX file for $(EXE_NAME)..."
	$(OBJCOPY) $(OBJCOPYFLAGS) $@ $@.hex
endif

$(OBJ_DIR)/%.o: %.cpp | $(OBJ_DIR) $(DEP_DIR)
	@mkdir -p $(dir $@) $(dir $(DEP_DIR)/$*.d)
	@echo "Compiling $<..."
	$(COMPILER_CPP) $(CPP_FLAGS) -MMD -MP -MF $(DEP_DIR)/$*.d -c $< -o $@

$(OBJ_DIR)/%.o: %.c | $(OBJ_DIR) $(DEP_DIR)
	@mkdir -p $(dir $@) $(dir $(DEP_DIR)/$*.d)
	@echo "Compiling $<..."
	$(COMPILER_C) $(C_FLAGS) -MMD -MP -MF $(DEP_DIR)/$*.d -c $< -o $@

$(OBJ_DIR)/%.o: %.S | $(OBJ_DIR) $(DEP_DIR)
	@mkdir -p $(dir $@) $(dir $(DEP_DIR)/$*.d)
	@echo "Assembling $<..."
	$(COMPILER_ASM) $(ASM_FLAGS) -x assembler-with-cpp -MMD -MP -MF $(DEP_DIR)/$*.d -c $< -o $@

$(OBJ_DIR)/abs/%.o: /%.S | $(OBJ_DIR) $(DEP_DIR)
	@mkdir -p $(dir $@) $(dir $(DEP_DIR)/abs/$*.d)
	@echo "Assembling Core Assembly: /$*.S..."
	$(COMPILER_ASM) $(ASM_FLAGS) -x assembler-with-cpp -MMD -MP -MF $(DEP_DIR)/abs/$*.d -c /$*.S -o $@

$(OBJ_DIR)/abs/%.o: /%.cpp | $(OBJ_DIR) $(DEP_DIR)
	@mkdir -p $(dir $@) $(dir $(DEP_DIR)/abs/$*.d)
	@echo "Compiling Core File: /$*.cpp..."
	$(COMPILER_CPP) $(CPP_FLAGS) -MMD -MP -MF $(DEP_DIR)/abs/$*.d -c /$*.cpp -o $@

$(OBJ_DIR)/abs/%.o: /%.c | $(OBJ_DIR) $(DEP_DIR)
	@mkdir -p $(dir $@) $(dir $(DEP_DIR)/abs/$*.d)
	@echo "Compiling Core File: /$*.c..."
	$(COMPILER_C) $(C_FLAGS) -MMD -MP -MF $(DEP_DIR)/abs/$*.d -c /$*.c -o $@

-include $(DEP_FILES)

build: $(EXE_NAME)
	@echo "Build complete for $(PLATFORM) ($(MODE)) - $(EXE_NAME)"

ifeq ($(PLATFORM),ch32)
run: post_link
	@echo "Uploading $(TARGET).bin to CH32 device..."
	$(FLASH_COMMAND)
else
run: $(EXE_NAME)
ifeq ($(PLATFORM),avr)
	@echo "Uploading to AVR device..."
	$(AVRDUDE) $(AVRDUDEFLAGS) -U flash:w:$(EXE_NAME).hex:i
else
	@echo "Running $(EXE_NAME)..."
	$(RUNNER) ./$(EXE_NAME)
endif
endif

flash: run

GRAPH_DOT := build/graph.dot
GRAPH_PNG := build/graph.png
GRAPH_HTML := build/graph.html
BUILD_LOG := build/build_times.log

graph: $(GRAPH_PNG)
	@echo "Build graph written to $(GRAPH_PNG)"

$(GRAPH_PNG): $(GRAPH_DOT)
	@mkdir -p build
	dot -Tpng $(GRAPH_DOT) -o $(GRAPH_PNG)

$(GRAPH_DOT):
	@mkdir -p build
	@echo "digraph build {" > $(GRAPH_DOT)
	@echo "rankdir=LR;" >> $(GRAPH_DOT)
	@echo "node [shape=box];" >> $(GRAPH_DOT)
	@echo "node [style=filled, fillcolor=lightblue];" >> $(GRAPH_DOT)
	@for src in $(ALL_SOURCES); do \
		obj=$$(echo "$$src" | sed "s/\.cpp/\.o/g;s/\.c/\.o/g;s/\.S/\.o/g;s/\.asm/\.o/g"); \
		obj="$(OBJ_DIR)/$$obj"; \
		echo "\"$$src\" [label=\"$$src\"];" >> $(GRAPH_DOT); \
		echo "\"$$obj\" [label=\"$$(basename $$obj)\"];" >> $(GRAPH_DOT); \
		echo "\"$$src\" -> \"$$obj\" [label=\"compile\"];" >> $(GRAPH_DOT); \
	done
	@echo "\"$(EXE_NAME)\" [label=\"$(EXE_NAME)\", style=filled, fillcolor=lightgreen];" >> $(GRAPH_DOT)
	@for o in $(OBJECTS); do \
		echo "\"$$o\" -> \"$(EXE_NAME)\" [label=\"link\"];" >> $(GRAPH_DOT); \
	done
	@echo "}" >> $(GRAPH_DOT)

graph-html: graph
	@mkdir -p build
	@python3 tools/dot_to_html.py $(GRAPH_DOT) $(GRAPH_HTML) 2>/dev/null || \
		echo "Note: graph-html requires tools/dot_to_html.py"
	@echo "HTML graph written to $(GRAPH_HTML)"

graph-view: graph
	@command -v xdg-open >/dev/null 2>&1 && xdg-open $(GRAPH_PNG) || \
		command -v open >/dev/null 2>&1 && open $(GRAPH_PNG) || \
		echo "Please open $(GRAPH_PNG) manually"

clean: libs-clean
	@echo "Cleaning build artifacts for $(PLATFORM)..."
	rm -rf build
	rm -f $(EXE_NAME) $(EXE_NAME).hex
	@echo "Clean complete"

watch:
	@python3 tools/watch.py || echo "Watch requires tools/watch.py"

profile:
	@if [ -f $(BUILD_LOG) ]; then \
		echo "=== BUILD PROFILE ==="; \
		cat $(BUILD_LOG); \
		echo "====================="; \
	else \
		echo "No build log found. Run 'make build' first."; \
	fi
