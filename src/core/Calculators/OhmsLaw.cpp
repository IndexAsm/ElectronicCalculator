#include "OhmsLaw.h"
#include <imgui.h>
#include <LanguageManager.h>
#include <cerrno>

#include "pch.hpp"

void Calculator::OhmsLaw::Update() {
    ImGuiIO& io = ImGui::GetIO();


    ImGui::Begin("##ohms_law");
    ImGui::Text(languageManager("calculator.ohms_law.window.title").c_str());


    

    static int Selected = 0;
    
    // Provide easier access, because of constexpr, performance is not affected by unwanted memory read operations
    constexpr uint32_t VoltageString = 0;
    constexpr uint32_t CurrentString = 1;
    constexpr uint32_t ResistanceString = 2;
    constexpr uint32_t PowerString = 3;
    

    static std::array<char[16], 4> Strings = {};

    static uint8_t IncorrectValues = false;
    static uint8_t InsufficientInputs = false;

    ImGui::RadioButton("##radio_voltage", &Selected, 0);
    ImGui::SameLine();
    ImGui::InputText(languageManager("calculator.units.voltage").c_str(), Strings[VoltageString], 16);

    ImGui::RadioButton("##radio_current", &Selected, 1);
    ImGui::SameLine();
    ImGui::InputText(languageManager("calculator.units.current").c_str(), Strings[CurrentString], 16);

    ImGui::RadioButton("##radio_resistance", &Selected, 2);
    ImGui::SameLine();
    ImGui::InputText(languageManager("calculator.units.resistance").c_str(), Strings[ResistanceString], 16);

    ImGui::BeginDisabled();
    ImGui::RadioButton("##radio_power", &Selected, 3);
    ImGui::SameLine();
    ImGui::InputText(languageManager("calculator.units.power").c_str(), Strings[PowerString], 16);
    ImGui::EndDisabled();


    // Checks if all strings are correct
    auto ValidateInput = [&]() -> uint8_t {
        uint8_t Valid = true;
        
        for (uint32_t i {}; i < 4; i++) {
            if (i == Selected)
                continue;

            const auto s = Strings[i];
            // If empty continue
            if (*s == '\0')
                continue;

            char* end;
            errno = 0;

            double value = std::strtod(s, &end);

            if (
                end == s        || 
                *end != '\0'    || 
                errno == ERANGE ||
                !std::isfinite(value)
            )
                return false;
        }

        return true;
    };

    auto IsEmpty = [&](uint32_t id) -> uint8_t {
        return Strings[id][0] == '\0';

    };

    auto IsInputSufficient = [&]() -> uint8_t {
        uint8_t Inputs {};
        for (uint32_t i{}; i < 3; i++) {
            if (i == Selected)
                continue;
            if (Strings[i][0] != '\0')
                Inputs++;
        }
        return Inputs >= 2;

    };

    if (ImGui::Button(languageManager("calculator.calculate").c_str())) {


        // Error Detection & Input Validation
        IncorrectValues = !ValidateInput();
        InsufficientInputs = !IsInputSufficient();

        if (IncorrectValues || InsufficientInputs)
            goto if_end;




        switch (Selected)
        {
        case VoltageString: {
            double Current = std::strtod(Strings[CurrentString], nullptr);
            double Resistance = std::strtod( Strings[ResistanceString], nullptr);

            double Voltage = Resistance * Current;

            std::snprintf(
                Strings[VoltageString], 
                sizeof(Strings[VoltageString]), 
                "%.10g", 
                Voltage
            );
            
            std::snprintf(
                Strings[PowerString], 
                sizeof(Strings[PowerString]), 
                "%.10g", 
                Voltage * Current
            );

            break;
        }
        case CurrentString: {
            double Voltage = std::strtod(Strings[VoltageString], nullptr);
            double Resistance = std::strtod( Strings[ResistanceString], nullptr);
            
            double Current = Voltage / Resistance;

            std::snprintf(
                Strings[CurrentString], 
                sizeof(Strings[CurrentString]), 
                "%.10g", 
                Current
            );
            
            std::snprintf(
                Strings[PowerString], 
                sizeof(Strings[PowerString]), 
                "%.10g", 
                Voltage * Current
            );
            break;
        }
        case ResistanceString: {
            double Voltage = std::strtod(Strings[VoltageString], nullptr);
            double Current = std::strtod(Strings[CurrentString], nullptr);
            
            double Resistance = Voltage / Current;

            std::snprintf(
                Strings[ResistanceString], 
                sizeof(Strings[ResistanceString]), 
                "%.10g", 
                Resistance
            );
            
            std::snprintf(
                Strings[PowerString], 
                sizeof(Strings[PowerString]), 
                "%.10g", 
                Voltage * Current
            );
            break;
            break;
        }
        case 3: {

            break;
        }
        default:
            break;
        }
    }
    if_end:

    if (IncorrectValues)
        ImGui::Text(languageManager("calculator.error.wrong_values").c_str());
    if (InsufficientInputs)
        ImGui::Text(languageManager("calculator.error.insufficient_data").c_str());

    
    ImGui::End();
}