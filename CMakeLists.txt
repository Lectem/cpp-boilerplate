#
# Main CMakelists for the boilerplate project.
#
# It aims to be a template and a CMake reference, and as such is documented as much as possible.
# While everything might not fit in any project, it should give good defaults and avoid CMake antipatterns.
# If you disagree with some pieces of advice given here, please discuss it with me by opening a Github Issue !
#
# Project specific options :
#   - BP_USE_DOXYGEN
#   - BP_BUILD_TESTS (requires BUILD_TESTING set to ON)
# Other options might be available through the cmake scripts including (not exhaustive):
#   - ENABLE_WARNINGS_SETTINGS
#   - ENABLE_LTO
#
cmake_minimum_required(VERSION 3.8.2)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
    message(FATAL_ERROR "Do not build in-source. Please remove CMakeCache.txt and the CMakeFiles/ directory. Then build out-of-source.")
endif()

# Put the project early since modules might need to detect the compiler
project("CPP-BoilerPlate" C CXX)

############################
##  Modules and scripts   ##
############################

# Standard CMake modules

include(CTest) # Must be called before adding tests but after calling project(). This automatically calls enable_testing() and configures ctest targets when using Make/Ninja
include(CMakeDependentOption)# This is a really useful scripts that creates options that depends on other options. It can even be used with generator expressions !

# Custom modules and scripts

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_LIST_DIR}/cmake")
include(LTO)
include(Warnings)
include(RunFixupBundle)
include(Coverage)

###############
##  OPTIONS  ##
###############

# You should try to give as much control over the project setup to the user.
# When modifying compile flags for example, if they are not mandatory, provide an option.

option(BP_USE_DOXYGEN "Add a doxygen target to generate the documentation" ON)

# Use your own option for tests, in case people use your library through add_subdirectory
cmake_dependent_option(BP_BUILD_TESTS
    "Enable Boilerplate project tests targets" ON # By default we want tests if CTest is enabled
    "BUILD_TESTING" OFF # Stay coherent with CTest variables
)

# External dependencies
add_subdirectory(external EXCLUDE_FROM_ALL)

# It is always easier to navigate in an IDE when projects are organized in folders.
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

###############
##  Project  ##
###############



# Check for LTO support (needs to be after project(...) )
find_lto(CXX)

#==========================#
#  BoilerPlate executable  #
#==========================#

set(BP_SOURCE_FILES source/main.cpp )   # Always list the files explicitly
set(BP_INCLUDE_FILES )                  # In this case we don't have headers, but always list them so that they appear in the IDE

add_executable(BoilerPlate ${BP_SOURCE_FILES} ${BP_INCLUDE_FILES})
target_link_libraries(BoilerPlate
    #PUBLIC # Useful for libraries, see https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html for more details about transitive usage requirements.
        #libraries/targets to link when linking this library
        #this will automatically setup the needed flags and dependencies when linking against this target
    PRIVATE # The following libraries are only linked for this target, and its flags/dependencies will not be used when linking against this target
        general fmt spdlog # It is possible to link some libraries for debug or optimized builds only
        #debug DEBUGLIBS
        #optimized RELEASELIBS
)

# Require c++14, this is better than setting CMAKE_CXX_STANDARD since it won't pollute other targets
# note : cxx_std_* features were added in CMake 3.8.2
target_compile_features(BoilerPlate PRIVATE cxx_std_14)

# CMake scripts extensions
target_set_warnings(BoilerPlate ENABLE ALL AS_ERROR ALL DISABLE Annoying) # Helper that can set default warning flags for you
target_enable_lto(BoilerPlate optimized) #enable lto if available for non-debug configurations
run_fixup(BoilerPlate "" "") # Copy dependencies next to the executable (DLLs for example)

# Setup our project as the startup project for Visual so that people don't need to do it manually
set_directory_properties(PROPERTIES VS_STARTUP_PROJECT BoilerPlate)

#===============#
#  Foo library  #
#===============#

# Usually libraries are listed before executables, but in this case we only use it for the tests
set(FOO_SOURCE_FILES source/foo.cpp )
set(FOO_INCLUDE_FILES source/include/foo.h)

add_library(bp_foo ${FOO_SOURCE_FILES} ${FOO_INCLUDE_FILES} )
target_include_directories(bp_foo
    PUBLIC # The folder must be used in the include path for any target using this library
        source/include
)
target_link_libraries(bp_foo
    PRIVATE # fmt is only needed to build, not to use this library
        fmt
)
# Give a 'scoped' name to libraries targets, as it can't be mistaken with system libraries
add_library(bp::foo ALIAS bp_foo)

#===========#
#   Tests   #
#===========#

if(BP_BUILD_TESTS)
    # Let the user add options to the test runner if needed
    set(TEST_RUNNER_PARAMS "--force-colors=true" CACHE STRING "Options to add to our test runners commands")
    # In a real project you most likely want to exclude test folders
    # list(APPEND CUSTOM_COVERAGE_EXCLUDE "/test/")
    add_subdirectory(tests)
    # You can setup some custom variables and add them to the CTestCustom.cmake.in template to have custom ctest settings
    # For example, you can exclude some directories from the coverage reports such as third-parties and tests
    configure_file(
        ${CMAKE_CURRENT_LIST_DIR}/cmake/CTestCustom.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/CTestCustom.cmake
        @ONLY
    )
endif()

#############
## Doxygen ##
#############

if(BP_USE_DOXYGEN AND CMAKE_VERSION VERSION_GREATER_EQUAL 3.9)
    find_package(Doxygen
        OPTIONAL_COMPONENTS dot mscgen dia
    )
    if(DOXYGEN_FOUND)
        set(DOXYGEN_USE_MDFILE_AS_MAINPAGE README.md)
        doxygen_add_docs(
            doc
            README.md source
            COMMENT "Generate man pages"
        )
    endif()
endif()
