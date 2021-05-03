/**
 * Copyright (c) 2016 Austin Appleby
 * https://github.com/aappleby/smhasher/blob/master/src/MurmurHash3.cpp
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
 * associated documentation files (the "Software"), to deal in the Software without restriction,
 * including without limitation the rights to use, copy, modify, merge, publish, distribute,
 * sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or
 * substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
 * NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 * DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#include "murmurhash3.hpp"

namespace hashing {

/**
 * Platform-specific functions and macros.
 */
#ifdef __GNUC__
#define FORCE_INLINE __attribute__((always_inline)) inline
#else
#define FORCE_INLINE inline
#endif

static constexpr FORCE_INLINE uint32_t rotl32(uint32_t x, int8_t r) noexcept {
    return (x << r) | (x >> (32 - r));
}

#define ROTL32(x, y) rotl32(x, y)

/**
* Block read - if your platform needs to do endian-swapping or can only handle aligned reads, do
* the conversion here.
*/
#define getblock(p, i) (p[i])

/**
* Finalization mix - force all bits of a hash block to avalanche.
*/
static FORCE_INLINE uint32_t fmix32(uint32_t h) {
    h ^= h >> 16;
    h *= 0x85ebca6b;
    h ^= h >> 13;
    h *= 0xc2b2ae35;
    h ^= h >> 16;
    return h;
}

constexpr auto SEED{0};

uint32_t murmurhash3(const void *key, size_t len) {
    const auto *data{(const uint8_t *) key};
    const int nBlocks{static_cast<int>(len / 4)};
    int i;

    uint32_t h1{SEED};

    static constexpr uint32_t c1{0xcc9e2d51};
    static constexpr uint32_t c2{0x1b873593};

    /**
     * Body.
     */
    const auto *blocks{(const uint32_t *) (data + nBlocks * 4)};

    for (i = -nBlocks; i; i++) {
        uint32_t k1 = getblock(blocks, i);

        k1 *= c1;
        k1 = ROTL32(k1, 15);
        k1 *= c2;

        h1 ^= k1;
        h1 = ROTL32(h1, 13);
        h1 = h1 * 5 + 0xe6546b64;
    }

    /**
     * Tail.
     */
    const auto *tail{(const uint8_t *) (data + nBlocks * 4)};
    uint32_t k1{0};

    switch (len & 3) {
        case 3:
            k1 ^= tail[2] << 16;
            /* FALLTHROUGH */
        case 2:
            k1 ^= tail[1] << 8;
            /* FALLTHROUGH */
        case 1:
            k1 ^= tail[0];
            k1 *= c1;
            k1 = ROTL32(k1, 15);
            k1 *= c2;
            h1 ^= k1;
    };

    /**
     * Finalization.
     */
    h1 ^= len;
    h1 = fmix32(h1);

    return h1;
}
}