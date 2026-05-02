#include <fstream>
#include <vector>
#include <sys/stat.h>

static bool read_binary(const char* path, std::vector<unsigned char>& out) {
    std::ifstream f(path, std::ios::binary | std::ios::ate);
    if (!f) return false;
    std::streamsize sz = f.tellg();
    f.seekg(0);
    out.resize(static_cast<size_t>(sz));
    f.read(reinterpret_cast<char*>(out.data()), sz);
    return f.good();
}

static void write_bits(const char* path, const std::vector<unsigned char>& data) {
    std::ofstream f(path);
    for (auto b : data) {
        unsigned char x = b ^ 0xAA;
        for (int i = 7; i >= 0; --i)
            f << ((x >> i) & 1);
    }
}

int main() {
    _mkdir("..\\init_data");

    std::vector<unsigned char> checker, monitor;
    if (!read_binary("..\\init_data\\checker_stub.bin", checker) ||
        !read_binary("..\\init_data\\monitor_stub.bin", monitor)) {
        return 1;
    }

    write_bits("..\\init_data\\checker.bin", checker);
    write_bits("..\\init_data\\monitor.bin", monitor);
    return 0;
}
