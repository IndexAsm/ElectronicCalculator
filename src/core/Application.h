#pragma once

#include <GLFW/glfw3.h>


#include <LanguageManager.h>
#include "Calculators/OhmsLaw.h"

class Application {
public: 
    Application();
    ~Application();

    void Run();

    void Update();
private:
    GLFWwindow* m_Window;

    Calculator::OhmsLaw m_OhmsLawCalculator;
};