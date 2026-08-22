#pragma once

#include <GLFW/glfw3.h>


#include <LanguageManager.h>


class Application {
public: 
    Application();
    ~Application();

    void Run();

    void Update();
private:
    LanguageManager m_LanguageManager;
    GLFWwindow* m_Window;
};