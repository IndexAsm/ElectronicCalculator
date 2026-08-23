#pragma once
#include <imgui.h>

namespace Calculator {
    class Base
    {
    public:
        virtual ~Base() = default;

        virtual void Update() = 0;

    };
}