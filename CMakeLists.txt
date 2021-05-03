#
#  Copyright 2021 Lumen Technologies
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

cmake_minimum_required(VERSION 3.8 FATAL_ERROR)

set(CMAKE_CXX_STANDARD 14)
set(PROJECT_NAME "web-native-common-samples")

project(${PROJECT_NAME} LANGUAGES CXX)

enable_language(C)
enable_language(CXX)

# Platform specific includes
include(cmake/emscripten.cmake)

# Utility includes
include(cmake/library.cmake)

add_subdirectory(01-hello-world)
add_subdirectory(02-hashing)