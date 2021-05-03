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

# Register library in the global library tree to later recover the list of object libraries to populate.
macro(register_object_library LIBRARY_NAME LIBRARY_DEPENDS)
    list(APPEND TARGET_OBJECT_LIBRARIES ${LIBRARY_NAME})
    foreach (dep IN ITEMS ${LIBRARY_DEPENDS})
        if (TARGET "${dep}")
            get_target_property(dep_type "${dep}" TYPE)

            if ("${dep_type}" STREQUAL "OBJECT_LIBRARY")
                get_property(target_objs GLOBAL PROPERTY ${dep}_OBJECT_LIBRARIES)
                list(APPEND TARGET_OBJECT_LIBRARIES "${target_objs}" ${dep})
            endif ()
        endif ()
    endforeach ()

    if (TARGET_OBJECT_LIBRARIES)
        list(REMOVE_DUPLICATES TARGET_OBJECT_LIBRARIES)
    endif()
    set_property(GLOBAL PROPERTY "${LIBRARY_NAME}_OBJECT_LIBRARIES" ${TARGET_OBJECT_LIBRARIES})
endmacro()

# Get the related object libraries tree for `${LIBRARY_NAME}`.
macro(get_object_libraries VAR LIBRARIES)
    foreach (lib IN LISTS ${LIBRARIES})
        get_property(objs GLOBAL PROPERTY "${lib}_OBJECT_LIBRARIES")

        foreach (obj IN LISTS objs)
            list(APPEND ${VAR} "$<TARGET_OBJECTS:${obj}>")
        endforeach ()
    endforeach ()
endmacro()

function(common_library)
    cmake_parse_arguments(COMMON_LIB
            "PUBLIC;STATIC;DYNAMIC"
            "NAME"
            "SRCS;COPTS;DEFINES;LINKOPTS;DEPS;EXPOSES"
            ${ARGN})

    # Convert list of `LINKOPTS` to working argument string.
    string(REPLACE ";" " " COMMON_LIBRARY_LINKOPTS_STR "${COMMON_LIBRARY_LINKOPTS}")
    string(REPLACE ";" " " COMMON_DEFAULT_LINKOPTS_STR "${COMMON_DEFAULT_LINKOPTS}")

    # We convert exposed folders from relative to absolute path.
    foreach (root_dir IN LISTS COMMON_LIB_EXPOSES)
        if (NOT "${root_dir}" MATCHES "\\$<.*>" AND NOT IS_ABSOLUTE ${root_dir})
            list(REMOVE_ITEM COMMON_LIB_EXPOSES "${root_dir}")
            list(APPEND COMMON_LIB_EXPOSES "${CMAKE_CURRENT_SOURCE_DIR}/${root_dir}")
        endif ()
    endforeach ()

    # Deal with cross-platform considerations to include only relevant folders.
    # if (emscripten) include(common/* ; web/*) else include(common/* ; native*);
    foreach (src_file IN LISTS COMMON_LIB_SRCS)
        if ((EMSCRIPTEN AND "${src_file}" MATCHES ".*\\/native\\/.*")
                OR (NOT EMSCRIPTEN AND "${src_file}" MATCHES ".*\\/web\\/.*"))
            list(REMOVE_ITEM COMMON_LIB_SRCS "${src_file}")
        endif ()
    endforeach ()

    # Dissociate library dependencies from custom target dependencies.
    set(COMMON_LIB_CUSTOM_DEPS "")
    foreach (dep IN LISTS COMMON_LIB_DEPS)
        if (TARGET "${dep}")
            get_target_property(dep_type "${dep}" TYPE)
            if (dep_type STREQUAL "UTILITY")
                list(REMOVE_ITEM COMMON_LIB_DEPS "${dep}")
                list(APPEND COMMON_LIB_CUSTOM_DEPS "${dep}")
            endif ()
        endif ()
    endforeach ()

    # Prepend sample name in front of dependencies name
    if (NOT "${COMMON_LIB_DEPS}" STREQUAL "")
        list(TRANSFORM COMMON_LIB_DEPS PREPEND "${SAMPLE_NAME}_")
    endif()

    # Determine if we deal with an interface library (no sources) or not.
    if ("${COMMON_LIB_SRCS}" STREQUAL "")
        set(COMMON_LIB_IS_INTERFACE 1)
    else ()
        set(COMMON_LIB_IS_INTERFACE 0)
    endif ()

    if (NOT COMMON_LIB_IS_INTERFACE)
        if (COMMON_LIB_STATIC)
            add_library(${SAMPLE_NAME}_${COMMON_LIB_NAME} STATIC "")
        elseif (COMMON_LIB_DYNAMIC)
            add_library(${SAMPLE_NAME}_${COMMON_LIB_NAME} SHARED "")
        else ()
            add_library(${SAMPLE_NAME}_${COMMON_LIB_NAME} OBJECT "")
        endif ()

        target_sources(${SAMPLE_NAME}_${COMMON_LIB_NAME} PRIVATE ${COMMON_LIB_SRCS})
        target_link_libraries(${SAMPLE_NAME}_${COMMON_LIB_NAME}
                PUBLIC
                "${COMMON_LIB_DEPS}"
                PRIVATE
                "${COMMON_LIBRARY_LINKOPTS_STR}"
                "${COMMON_DEFAULT_LINKOPTS_STR}"
                )

        if (NOT "${COMMON_LIB_CUSTOM_DEPS}" STREQUAL "")
            add_dependencies(${SAMPLE_NAME}_${COMMON_LIB_NAME} ${COMMON_LIB_CUSTOM_DEPS})
        endif ()
        set_property(TARGET ${SAMPLE_NAME}_${COMMON_LIB_NAME} PROPERTY LINKER_LANGUAGE "CXX")
        target_include_directories(${SAMPLE_NAME}_${COMMON_LIB_NAME}
                PUBLIC
                "$<BUILD_INTERFACE:${COMMON_LIB_EXPOSES}>"
                )
        target_compile_options(${SAMPLE_NAME}_${COMMON_LIB_NAME} PRIVATE "${COMMON_LIB_COPTS}")
        target_compile_definitions(${SAMPLE_NAME}_${COMMON_LIB_NAME} PUBLIC "${COMMON_LIB_DEFINES}")

        register_object_library(${SAMPLE_NAME}_${COMMON_LIB_NAME} "${COMMON_LIB_DEPS}")
    else ()
        # Generating header-only library
        add_library(${SAMPLE_NAME}_${COMMON_LIB_NAME} INTERFACE)
        if (NOT "${COMMON_LIB_CUSTOM_DEPS}" STREQUAL "")
            add_dependencies(${SAMPLE_NAME}_${COMMON_LIB_NAME} ${COMMON_LIB_CUSTOM_DEPS})
        endif ()
        target_include_directories(${SAMPLE_NAME}_${COMMON_LIB_NAME}
                INTERFACE
                "$<BUILD_INTERFACE:${COMMON_LIB_EXPOSES}>"
                )
        target_link_libraries(${SAMPLE_NAME}_${COMMON_LIB_NAME}
                INTERFACE
                "${COMMON_LIB_DEPS}"
                "${COMMON_LIB_LINKOPTS}"
                "${COMMON_DEFAULT_LINKOPTS}"
                )
        target_compile_definitions(${SAMPLE_NAME}_${COMMON_LIB_NAME} INTERFACE "${COMMON_LIB_DEFINES}")
    endif ()
endfunction()

function(common_executable)
    cmake_parse_arguments(COMMON_EXECUTABLE
            ""
            "NAME"
            "SRCS;COPTS;DEFINES;DEPS;LINKOPTS"
            ${ARGN}
            )

    # Dissociate dependencies from custom target dependencies.
    set(COMMON_EXECUTABLE_CUSTOM_DEPS "")
    foreach (dep IN LISTS COMMON_EXECUTABLE_DEPS)
        if (TARGET "${dep}")
            get_target_property(dep_type "${dep}" TYPE)
            if (dep_type STREQUAL "UTILITY")
                list(REMOVE_ITEM COMMON_EXECUTABLE_DEPS "${dep}")
                list(APPEND COMMON_EXECUTABLE_CUSTOM_DEPS "${dep}")
            endif ()
        endif ()
    endforeach ()

    # Convert list of `LINKOPTS` to working argument string.
    string(REPLACE ";" " " COMMON_EXECUTABLE_LINKOPTS_STR "${COMMON_EXECUTABLE_LINKOPTS}")
    string(REPLACE ";" " " COMMON_DEFAULT_LINKOPTS_STR "${COMMON_DEFAULT_LINKOPTS}")

    # Prepend sample name in front of dependencies name
    if (NOT "${COMMON_EXECUTABLE_DEPS}" STREQUAL "")
        list(TRANSFORM COMMON_EXECUTABLE_DEPS PREPEND "${SAMPLE_NAME}_")
    endif()

    get_object_libraries(obj_libs COMMON_EXECUTABLE_DEPS)
    add_executable(${COMMON_EXECUTABLE_NAME} ${COMMON_EXECUTABLE_SRCS} ${obj_libs})
    target_sources(${COMMON_EXECUTABLE_NAME} PRIVATE ${obj_libs})
    target_compile_definitions(${COMMON_EXECUTABLE_NAME} PUBLIC ${COMMON_EXECUTABLE_DEFINES})
    target_compile_options(${COMMON_EXECUTABLE_NAME} PRIVATE "${COMMON_EXECUTABLE_COPTS}")
    target_link_libraries(${COMMON_EXECUTABLE_NAME}
            PUBLIC
            "${COMMON_EXECUTABLE_DEPS}"
            PRIVATE
            "${COMMON_EXECUTABLE_LINKOPTS_STR}"
            "${COMMON_DEFAULT_LINKOPTS_STR}"
            )

    if (NOT "${COMMON_EXECUTABLE_CUSTOM_DEPS}" STREQUAL "")
        add_dependencies(${COMMON_EXECUTABLE_NAME} ${COMMON_EXECUTABLE_CUSTOM_DEPS})
    endif ()

    set_target_properties(${COMMON_EXECUTABLE_NAME}
            PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
            )

endfunction()