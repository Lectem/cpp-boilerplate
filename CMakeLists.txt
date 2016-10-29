cmake_minimum_required(VERSION 3.6)	

if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
	message(FATAL_ERROR "Do not build in-source. Please remove CMakeCache.txt and the CMakeFiles/ directory. Then build out-of-source.")
endif()

include(cmake/Warnings.cmake)

project(BoilerPlateProject C CXX)

# External dependencies
add_subdirectory(external EXCLUDE_FROM_ALL)

# We want at least c++14
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(MSVC)
	add_definitions(/DNOMINMAX)
endif()

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

set(SOURCE_FILES source/main.cpp source/precomp.cpp)
set(INCLUDE_FILES include/precomp.h)

add_executable(BoilerPlate ${SOURCE_FILES} ${INCLUDE_FILES})
target_link_libraries(BoilerPlate fmt spdlog)
target_include_directories(BoilerPlate PRIVATE include/)
target_set_warnings(BoilerPlate ENABLE ALL AS_ERROR ALL)
set_directory_properties(PROPERTIES VS_STARTUP_PROJECT BoilerPlate)