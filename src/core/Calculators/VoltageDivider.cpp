#include "VoltageDivider.h"

#include <imgui.h>
#include <LanguageManager.h>
#include <cerrno>

#include "pch.hpp"

void Calculator::VoltageDivider::Update() {
    ImGuiIO& io = ImGui::GetIO();


    ImGui::Begin("##voltage_divider");
    ImGui::Text(languageManager("calculator.voltage_divider.window.title").c_str());


    

    static int Selected = 0;
    
    // Provide easier access, because of constexpr, performance is not affected by unwanted memory read operations
    constexpr uint32_t InVoltageString = 0;
    constexpr uint32_t R1String = 1;
    constexpr uint32_t R2String = 2;
    constexpr uint32_t OutVoltageString = 3;
    

    static std::array<char[16], 4> Strings = {};

    static uint8_t IncorrectValues = false;
    static uint8_t InsufficientInputs = false;

    // Temporary array
    static std::string strUnits[] = {
        languageManager("calculator.units.resistance"),
        "k" + languageManager("calculator.units.resistance"),
        "M" + languageManager("calculator.units.resistance"),

    };

    static const char* Units[] = {
        strUnits[0].c_str(),
        strUnits[1].c_str(),
        strUnits[2].c_str(),
    };

    static int32_t CurrentR1Units = 0;
    static int32_t CurrentR2Units = 0;


    constexpr float labelWidth = 60.0f;
    constexpr float inputWidth = 300.0f;

    ImGui::RadioButton("Vi##radio_voltage", &Selected, 0);
    ImGui::SameLine(0.0f, -1.0f);
    ImGui::SetCursorPosX(labelWidth);
    ImGui::SetNextItemWidth(inputWidth);
    ImGui::InputText((languageManager("calculator.units.voltage") + "##voltage_divider0").c_str(), Strings[InVoltageString], 16);

    ImGui::RadioButton("R1##radio_r1", &Selected, 1);
    ImGui::SameLine();
    ImGui::SetCursorPosX(labelWidth);
    ImGui::SetNextItemWidth(inputWidth);
    ImGui::InputText("##voltage_divider1", Strings[R1String], 16);
    ImGui::SameLine();
    ImGui::SetNextItemWidth(60.0f);
    ImGui::Combo("##R1_Units", &CurrentR1Units, Units, IM_ARRAYSIZE(Units));


    ImGui::RadioButton("R2##radio_r2", &Selected, 2);
    ImGui::SameLine();
    ImGui::SetCursorPosX(labelWidth);
    ImGui::SetNextItemWidth(inputWidth);
    ImGui::InputText("##voltage_divider2", Strings[R2String], 16);
    ImGui::SameLine();
    ImGui::SetNextItemWidth(60.0f);
    ImGui::Combo("##R2_Units", &CurrentR2Units, Units, IM_ARRAYSIZE(Units));

    ImGui::RadioButton("Vo##radio_voltage", &Selected, 3);
    ImGui::SameLine(0.0f, -1.0f);
    ImGui::SetCursorPosX(labelWidth);
    ImGui::SetNextItemWidth(inputWidth);
    ImGui::InputText((languageManager("calculator.units.voltage") + "##voltage_divider3").c_str(), Strings[OutVoltageString], 16);


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
        for (uint32_t i{}; i < 4; i++) {
            if (i == Selected)
                continue;
            if (Strings[i][0] != '\0')
                Inputs++;
        }
        return Inputs >= 3;

    };

    auto ConvertRUnits = [](double& u, uint32_t selected, uint32_t current = 0) -> void {
        if (selected == 0)
            switch (current)
            {
                case 1: {
                    u *= 1000.0;
                    break;
                }
                case 2: {
                    u *= 1000000.0;
                    break;
                }
                default:
                    break;
            }
        else if (selected == 1)
            switch (current)
            {
                case 0: {
                    u /= 1000.0;
                    break;
                }
                case 2: {
                    u *= 1000.0;
                    break;
                }
                default:
                    break;
            }
        else if (selected == 2)
            switch (current)
            {
                case 0: {
                    u /= 1000000.0;
                    break;
                }
                case 1: {
                    u /= 1000.0;
                    break;
                }
                default:
                    break;
            }
    };

    if (ImGui::Button(languageManager("calculator.calculate").c_str())) {


        // Error Detection & Input Validation
        IncorrectValues = !ValidateInput();
        InsufficientInputs = !IsInputSufficient();

        if (IncorrectValues || InsufficientInputs)
            goto if_end;



        
        switch (Selected)
        {
        case InVoltageString: {

            // Get Data
            double R1 = std::strtod(Strings[R1String], nullptr);
            double R2 = std::strtod(Strings[R2String], nullptr);
            double Vout = std::strtod(Strings[OutVoltageString], nullptr);

            // Normalize units
            ConvertRUnits(R1, 0, CurrentR1Units);
            ConvertRUnits(R2, 0, CurrentR2Units);

            

            

            double Vin = Vout * ((R1 + R2) / R2);
            std::snprintf(
                Strings[InVoltageString], 
                sizeof(Strings[InVoltageString]), 
                "%.6g", 
                Vin
            );
        
            break;
        }
        case R1String: {
            double Vin = std::strtod(Strings[InVoltageString], nullptr);
            double R2 = std::strtod(Strings[R2String], nullptr);
            double Vout = std::strtod(Strings[OutVoltageString], nullptr);
            ConvertRUnits(R2, 0, CurrentR2Units);
            
            double R1 = R2 * ((Vin - Vout) / Vout);
            ConvertRUnits(R1, CurrentR1Units);

            std::snprintf(
                Strings[R1String], 
                sizeof(Strings[R1String]), 
                "%.6g", 
                R1
            );
            break;
        }
        case R2String: {
            double Vin = std::strtod(Strings[InVoltageString], nullptr);
            double R1 = std::strtod(Strings[R1String], nullptr);
            double Vout = std::strtod(Strings[OutVoltageString], nullptr);
            ConvertRUnits(R1, 0, CurrentR1Units);
            
            double R2 = R1 * (Vout / (Vin - Vout));
            ConvertRUnits(R2, CurrentR2Units);

            std::snprintf(
                Strings[R2String], 
                sizeof(Strings[R2String]), 
                "%.6g", 
                R2
            );
            break;
        }
        case OutVoltageString: {
            double Vin = std::strtod(Strings[InVoltageString], nullptr);
            double R1 = std::strtod(Strings[R1String], nullptr);
            double R2 = std::strtod(Strings[R2String], nullptr);

            // Normalize units
            ConvertRUnits(R1, 0, CurrentR1Units);
            ConvertRUnits(R2, 0, CurrentR2Units);

            

            

            double Vout = Vin * (R2 / (R1 + R2));
            std::snprintf(
                Strings[OutVoltageString], 
                sizeof(Strings[OutVoltageString]), 
                "%.6g", 
                Vout
            );
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