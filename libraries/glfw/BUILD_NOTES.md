# Building glfw

glfw ships its own CMake build rather than this template's plain-Makefile convention, so genfw does not attempt to compile it directly.

Headers found under `vendor/` were copied to `include/`, so `#include` resolves already (this project's build system auto-adds `-Ilibraries/glfw/include` for every source file).

For the actual linkable library, easiest path: install it via your system package manager (e.g. `sudo apt install libglfw-dev` on Debian/Ubuntu), which puts it on the default linker search path and `-lglfw` in make/framework.mk will just work.

Alternatively, build the vendored copy in `vendor/` with its own CMake and either `sudo make install` it or add `-Lvendor/build` to this library's link flags yourself.
