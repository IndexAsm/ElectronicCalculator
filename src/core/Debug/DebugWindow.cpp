#include "DebugWindow.h"

#include "pch.hpp"
#include <LanguageManager.h>

namespace Debug {
    void RenderDebugWindow(ImGuiIO& io) {

        static bool ShowDemoWindow = 1;

        if (ShowDemoWindow) {
            ImGui::ShowDemoWindow(&ShowDemoWindow);
        }

        ImGui::Begin(languageManager("debug.title").c_str());

        ImGui::Text("Time: %.3f ms (%.1f FPS)", 1000.0f / io.Framerate, io.Framerate);

        ImGui::Checkbox(languageManager("debug.demo_checkbox").c_str(), &ShowDemoWindow);


        
        ImGui::End();
    }
}
