#include "CalculatorMenu.h"
#include <imgui.h>

#include "pch.hpp"

#include <LanguageManager.h>

void Calculator::Menu::Update() {
    ImGui::Begin("Menu");

    if (ImGui::Button(languageManager("calculator.ohms_law.window.title").c_str(), ImVec2(200, 25))) {

    }

    if (ImGui::Button(languageManager("calculator.voltage_divider.window.title").c_str(), ImVec2(200, 25))) {

    }



    ImGui::End();
}