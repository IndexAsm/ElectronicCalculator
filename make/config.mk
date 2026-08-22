# ============================================================
# Project Configuration
# ============================================================
# Central place for values that describe the project itself
# (as opposed to make/<platform>.mk, which describes HOW to
# build for a given platform).
#
# CONVENTION FOR FUTURE ENTRIES:
#   - Prefix every variable with CONFIG_ to keep this file's
#     exports namespaced and easy to grep for.
#   - Lists are space-separated (standard Make list style),
#     e.g. CONFIG_ALLOWED_PLATFORMS := linux windows avr ch32
#   - Single values just get CONFIG_<NAME> := value.
#   - Add new sections with a "# ---- <Name> ----" header so the
#     file stays scannable as it grows.
#   - This file must stay pure data: no $(shell ...), no rules,
#     no platform-specific logic. Anything that needs logic
#     belongs in make/*.mk instead.
#
# NOTE: genfw (the framework generator) reads CONFIG_ALLOWED_PLATFORMS
# out of this exact file to validate --platforms. Keep the variable
# name and space-separated list format stable.
# ============================================================

# ---- Platforms ----
CONFIG_ALLOWED_PLATFORMS := linux windows avr ch32
CONFIG_DEFAULT_PLATFORM  := linux

# ---- Build modes ----
CONFIG_ALLOWED_MODES := debug release
CONFIG_DEFAULT_MODE  := debug

# ---- Language defaults ----
CONFIG_DEFAULT_CVER   := c17
CONFIG_DEFAULT_CPPVER := c++23

# ---- Framework (filled in by genfw; empty means "no framework, bare template") ----
CONFIG_FRAMEWORK := imgui
