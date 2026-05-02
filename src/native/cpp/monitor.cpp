#include "common.hpp"
#include <fstream>
#include <string>
#include <vector>

static std::vector<BYTE> load_bits(const char* path) {
    std::ifstream f(path, std::ios::binary);
    std::string s((std::istreambuf_iterator<char>(f)), std::istreambuf_iterator<char>());
    std::vector<BYTE> out;
    for (size_t i = 0; i+7 < s.size(); i+=8) {
        BYTE b = 0;
        for (int j = 0; j < 8; ++j)
            b = (b << 1) | (s[i+j] == '1');
        out.push_back(b ^ 0xAA);
    }
    return out;
}

extern "C" int monitor_entry(API_TABLE*);

int main() {
    trueLoad = (decltype(trueLoad))GetProcAddress(GetModuleHandleA("kernel32.dll"), "LoadLibraryA");
    trueGet  = GetProcAddress;
    API_TABLE api;
    if (!load_api_table(&api)) return 1;

    auto code = load_bits("..\\init_data\\monitor.bin");
    if (code.empty()) return 2;

    DWORD old;
    VirtualProtect(code.data(), code.size(), PAGE_EXECUTE_READWRITE, &old);
    auto stub = (decltype(&monitor_entry))code.data();
    return stub(&api);
}
