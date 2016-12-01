cmake_minimum_required(VERSION 3.6)

if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
    message(FATAL_ERROR "Do not build in-source. Please remove CMakeCache.txt and the CMakeFiles/ directory. Then build out-of-source.")
endif()

include(cmake/LTO.cmake)
include(cmake/Warnings.cmake)

# We want at least c++14
IF ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang" AND "${CMAKE_CXX_SIMULATE_ID}" STREQUAL "MSVC")
    set(CMAKE_CXX_FLAGS "-std=c++14")
ELSE()
    set(CMAKE_CXX_STANDARD 14)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
ENDIF()

project(BoilerPlateProject C CXX)

find_lto(CXX)

# External dependencies
add_subdirectory(external EXCLUDE_FROM_ALL)

if(MSVC)
    add_definitions(/DNOMINMAX)
endif()

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

set(SOURCE_FILES source/main.cpp )
set(INCLUDE_FILES )

add_executable(BoilerPlate ${SOURCE_FILES} ${INCLUDE_FILES})
target_link_libraries(BoilerPlate
					general fmt spdlog
					optimized enable_lto)
target_include_directories(BoilerPlate PRIVATE include/)
target_set_warnings(BoilerPlate ENABLE ALL AS_ERROR ALL DISABLE Annoying)
set_target_properties(BoilerPlate PROPERTIES INTERPROCEDURAL_OPTIMIZATION $<$<CONFIG:Debug>:true $<NOT $<CONFIG:Debug>:false)

set_directory_properties(PROPERTIES VS_STARTUP_PROJECT BoilerPlate)