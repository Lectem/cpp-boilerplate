project(external C CXX)

set(CMAKE_FOLDER external) # This will regroup all the external targets in a subfolder in IDEs such as Visual Studio

set(BUILD_TESTING_BCKP ${BUILD_TESTING})
set(BUILD_TESTING OFF CACHE BOOL "Force disable of tests for external dependencies" FORCE)

set(CUSTOM_COVERAGE_EXCLUDE ${CUSTOM_COVERAGE_EXCLUDE} "external" PARENT_SCOPE) # Replaced in CTestCustom.cmake.in


#Use fmtlib for formatting
add_subdirectory(fmt EXCLUDE_FROM_ALL)
target_set_warnings(fmt DISABLE ALL)              # Treat fmtlib as a system include as to ignore the warnings

#Use spdlog for logging, and tell it to use our version of fmtlib
add_subdirectory(spdlog EXCLUDE_FROM_ALL)
target_compile_definitions(spdlog INTERFACE SPDLOG_FMT_EXTERNAL)
target_set_warnings(spdlog DISABLE ALL)              # Treat spdlog as a system include as to ignore the warnings

#Doctest for unit tests
add_library(doctest INTERFACE)
target_include_directories(
    doctest
    INTERFACE
    doctest/doctest # note : will expose the parts/ folder...
)
add_library(doctest::doctest ALIAS doctest)
target_compile_features(doctest INTERFACE cxx_std_11)

set(BUILD_TESTING ${BUILD_TESTING_BCKP} CACHE BOOL "Build tests (default variable for CTest)" FORCE) #Set it back to its past value
