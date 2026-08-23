#pragma once
#include <filesystem>
#include <unordered_map>





class LanguageManager {
public:
    void Load(const std::filesystem::path& path);

    const std::string& Get(const std::string& key) const;

    const std::string& operator()(const std::string& key) const {
        return Get(key);
    }

    const std::filesystem::path& GetFontPath() const {
        return m_FontPath;
    }

private:
    std::pair<std::string, std::string> currentLanguage;
    std::filesystem::path m_FontPath;
    std::unordered_map<std::string, std::string> translations;
};

extern LanguageManager languageManager;