/*
 *  Copyright 2021 Lumen Technologies
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

#include <benchmark/benchmark.hpp>
#include <hashing/benchmark.hpp>
#include <logger/logger.hpp>

#include <sstream>
#include <random>
#include <chrono>
#include <limits>

namespace benchmark {

using FloatingMilliseconds = std::chrono::duration<double, std::milli>;
using FloatingMicroseconds = std::chrono::duration<double, std::micro>;

/** Compute the average duration of the given list of values as microseconds represented using doubles. */
FloatingMicroseconds computeMean(const std::vector<std::chrono::microseconds> &durations) {
    std::chrono::microseconds acc{0};
    for (const auto &d : durations) {
        acc += d;
    }
    return std::chrono::duration_cast<FloatingMicroseconds>(acc) / durations.size();
}

/** Compute the variance of the durations from the given list of values as doubles. */
double computeVariance(const std::vector<std::chrono::microseconds> &durations) {
    FloatingMilliseconds mean = computeMean(durations);
    double acc{0};
    for (const auto &d : durations) {
        FloatingMilliseconds dFloat = std::chrono::duration_cast<FloatingMilliseconds>(d);
        acc += (dFloat - mean).count() * (dFloat - mean).count();
    }

    return acc / durations.size();
}

Benchmark::Benchmark() {
    std::random_device rd;
    std::mt19937 gen(rd());
    std::uniform_int_distribution<uint32_t> distrib{0, std::numeric_limits<uint8_t>::max()};

    hashing::Hasher hasher{};
    const size_t ITERATIONS{1000};
    std::vector<std::chrono::microseconds> durations;
    durations.reserve(ITERATIONS);
    const size_t BUFFER_SIZE{1024 * 1024};

    std::vector<uint8_t> buffer(BUFFER_SIZE);
    uint32_t hash{0};

    for (size_t i = 0;i < ITERATIONS;++i) {
        for (auto &v : buffer) {
            v = static_cast<uint8_t>(distrib(gen));
        }

        auto begin = std::chrono::steady_clock::now();
        hash += hasher.hash(buffer);
        auto end = std::chrono::steady_clock::now();
        durations.push_back(std::chrono::duration_cast<std::chrono::microseconds>(end - begin));
    }

    uint32_t meanHash = hash / ITERATIONS;
    FloatingMilliseconds averageDuration = computeMean(durations);
    double variance = computeVariance(durations);

    std::ostringstream stream;
    stream << "Hash of a " << BUFFER_SIZE << " bytes buffer (meanHash = " << meanHash << ") done in "
           << averageDuration.count() << "ms on average (+/- " << variance << "ms) on " << ITERATIONS << " iterations";
    logger::log(stream.str());
}

}
