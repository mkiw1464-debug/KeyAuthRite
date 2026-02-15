#ifndef SKCRYPT_H
#define SKCRYPT_H

#include <string>
#include <array>
#include <cstddef>

namespace skc {
    template <std::size_t N, int K>
    class skCrypt {
    private:
        std::array<char, N> _storage;
    public:
        constexpr skCrypt(const char* data) : _storage() {
            for (std::size_t i = 0; i < N; ++i)
                _storage[i] = data[i] ^ K;
        }
        std::string decrypt() {
            std::string decrypted = "";
            for (std::size_t i = 0; i < N - 1; ++i)
                decrypted += (char)(_storage[i] ^ K);
            return decrypted;
        }
    };
}

#define skCrypt(str) skc::skCrypt<sizeof(str), __LINE__>(str)

#endif
