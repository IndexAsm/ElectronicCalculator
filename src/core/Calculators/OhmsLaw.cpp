#include "OhmsLaw.h"
#include <imgui.h>
#include <LanguageManager.h>

void Calculator::OhmsLaw::Update() {
    ImGuiIO& io = ImGui::GetIO();


    ImGui::Begin("##ohms_law");
    ImGui::Text(languageManager("calculator.ohms_law.window.title").c_str());


    float voltage = 0.0f;
    float current = 0.0f;
    float resistance = 0.0f;
    float power = 0.0f;
    

    static char VoltageString[16] = "";

    ImGui::InputText(languageManager("calculator.ohms_law.voltage").c_str(), VoltageString, 16);
    ImGui::InputText(languageManager("calculator.ohms_law.current").c_str(), VoltageString, 16);
    ImGui::InputText(languageManager("calculator.units.resistance").c_str(), VoltageString, 16);
    ImGui::InputText(languageManager("calculator.ohms_law.power").c_str(), VoltageString, 16);

    
    
    ImGui::End();
}