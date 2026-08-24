#include "DebugWindow.h"

#include "pch.hpp"
#include <LanguageManager.h>

namespace Debug {
    void RenderDebugWindow(ImGuiIO& io) {

        static bool ShowDemoWindow = 0;

        if (ShowDemoWindow) {
            ImGui::ShowDemoWindow(&ShowDemoWindow);
        }

        ImGui::Begin("Debug");

        ImGui::Text("Time: %.3f ms (%.1f FPS)", 1000.0f / io.Framerate, io.Framerate);


        ImGui::Checkbox(languageManager("debug.demo_checkbox").c_str(), &ShowDemoWindow);

        const char* languages[] = {
            "English",
            "Polski",
            "Русский"
        };


        static int currentLanguage = 0;

        if (ImGui::Combo("Language", &currentLanguage, languages, IM_ARRAYSIZE(languages)))
        {
            switch (currentLanguage)
            {
                case 0:
                    languageManager.Load("assets/lang/en.lang");
                    break;
            
                case 1:
                    languageManager.Load("assets/lang/pl.lang");
                    break;
            
                case 2:
                    languageManager.Load("assets/lang/ru.lang");
                    break;
            }
        }


        
        ImGui::End();
    }
}
