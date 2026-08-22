include make/config.mk

PLATFORM ?= $(CONFIG_DEFAULT_PLATFORM)
MODE     ?= $(CONFIG_DEFAULT_MODE)

ifeq ($(filter $(PLATFORM),$(CONFIG_ALLOWED_PLATFORMS)),)
$(error Unknown PLATFORM '$(PLATFORM)'. Allowed platforms: $(CONFIG_ALLOWED_PLATFORMS))
endif

ifeq ($(filter $(MODE),$(CONFIG_ALLOWED_MODES)),)
$(error Unknown MODE '$(MODE)'. Allowed modes: $(CONFIG_ALLOWED_MODES))
endif

include make/common.mk
include make/$(PLATFORM).mk
include make/rules.mk
