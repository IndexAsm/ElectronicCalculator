LIB_NAME := imgui

# imgui ships as loose sources rather than our include/ + src/core/
# convention, so we point lib.mk's EXTRA_* hooks at the vendored tree
# instead of relying on its normal auto-discovery. The extra -I below
# reaches the windowing backend's own headers (e.g. GLFW), whether it
# was vendored alongside (git fetch) or is a system package (harmless
# no-op -I in that case).
EXTRA_INC := -Ivendor -Ivendor/backends -I../glfw/include
EXTRA_SOURCES := $(wildcard vendor/*.cpp) vendor/backends/imgui_impl_glfw.cpp vendor/backends/imgui_impl_opengl3.cpp

include ../../make/lib.mk
