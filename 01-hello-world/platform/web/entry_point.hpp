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

#pragma once

#include <hello_world/hello_world.hpp>

#include <emscripten.h>
#include <emscripten/bind.h>
#include <emscripten/val.h>

class EntryPoint final {
public:
    EntryPoint();
    ~EntryPoint() = default;

private:
    HelloWorld mHelloWorld;
};

EMSCRIPTEN_BINDINGS(hello_world) {
    emscripten::class_<EntryPoint>("HelloWorld")
            .constructor<>();
}