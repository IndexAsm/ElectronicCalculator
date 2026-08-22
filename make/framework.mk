# genfw-generated file - safe to regenerate with `genfw update`.
# framework=imgui windowing=glfw rendering=opengl3

FRAMEWORK_LINK_FLAGS_linux := -lglfw -ldl -lpthread -lGL
FRAMEWORK_LINK_FLAGS_windows := -lglfw3 -lgdi32 -lopengl32
FRAMEWORK_LINK_FLAGS := $(FRAMEWORK_LINK_FLAGS_$(PLATFORM))
