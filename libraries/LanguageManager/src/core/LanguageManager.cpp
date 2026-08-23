#include "LanguageManager.h"

#include <iostream>
#include <fstream>


void LanguageManager::Load(const std::filesystem::path &path) {

    translations.clear();

    std::ifstream file(path);

    if (file.fail()) {
        std::cerr << "Failed to open language file: " << path << std::endl;
        return;
    }

    std::getline(file, currentLanguage.first);
    std::getline(file, currentLanguage.second);

    std::string fontPath;
    std::getline(file, fontPath);
    m_FontPath = std::filesystem::path(fontPath);


    std::string key, value;

    while (std::getline(file, key))
    {
        if (!std::getline(file, value)) {
            std::cerr << "Malformed language file: " << path << std::endl;
            return;
        }
        
        translations[key] = value;

    }
    
}

const std::string &LanguageManager::Get(const std::string &key) const
{
    if (translations.find(key) == translations.end()) {
        return key; 
    }
    return translations.at(key);
}

LanguageManager languageManager;