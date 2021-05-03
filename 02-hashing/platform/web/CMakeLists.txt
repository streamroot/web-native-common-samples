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

common_executable(
    NAME
        ${SAMPLE_NAME}
    SRCS
        entry_point.cpp
    DEPS
        benchmark
    LINKOPTS
        "-Oz
        -flto
        --bind
        --closure 1
        --no-entry
        --extern-post-js ${CMAKE_CURRENT_SOURCE_DIR}/post.js
        --extern-pre-js ${CMAKE_CURRENT_SOURCE_DIR}/pre.js
        $<$<CONFIG:Debug>:--profiling-funcs>
        $<$<CONFIG:Debug>:--memoryprofiler>
        -s ALLOW_MEMORY_GROWTH=1
        -s ASSERTIONS=0
        -s DEMANGLE_SUPPORT=0
        -s DISABLE_EXCEPTION_CATCHING=0
        -s ENVIRONMENT=web
        -s FETCH=1
        -s MODULARIZE=1
        -s SUPPORT_LONGJMP=0"
)

set_property(TARGET ${SAMPLE_NAME} PROPERTY RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${SAMPLE_NAME}/bin)
set_target_properties(${SAMPLE_NAME} PROPERTIES OUTPUT_NAME "${SAMPLE_NAME}")
set_target_properties(${SAMPLE_NAME} PROPERTIES SUFFIX ".js")





