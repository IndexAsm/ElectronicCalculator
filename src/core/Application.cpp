#include "Application.h"
#include "Window.h"


#include "imgui.h"
#include "imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"


#include "pch.hpp"
#include "Debug/DebugWindow.h"



Application::Application() {
    languageManager.Load("assets/lang/en.lang");


    m_Window = createWindow(1280, 720, languageManager("app.title"));

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;
    io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;

    std::print("{}",languageManager.GetFontPath().string());
    // Setting the font according to language
    ImFont* font = io.Fonts->AddFontFromFileTTF(
        languageManager.GetFontPath().string().c_str(),
        18.0f
    );


    ImGui::StyleColorsDark();

    ImGui_ImplGlfw_InitForOpenGL(m_Window, true);
    ImGui_ImplOpenGL3_Init("#version 330");

}

Application::~Application(){
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();

    glfwDestroyWindow(m_Window);
    glfwTerminate();
}

void Application::Run() {
    ImGuiIO& io = ImGui::GetIO();

    while (!glfwWindowShouldClose(m_Window)) {
        glfwPollEvents();

        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();
        ImGui::DockSpaceOverViewport(0, ImGui::GetMainViewport());

        

        Debug::RenderDebugWindow(io);
        

        Update();


        ImGui::Render();
        
        
        glClearColor(0.20f, 0.20f, 0.20f, 1.00f);
        glClear(GL_COLOR_BUFFER_BIT);

        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());

        glfwSwapBuffers(m_Window);


    }
}

void Application::Update() {

    m_OhmsLawCalculator.Update();
}
