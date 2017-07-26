cmake_minimum_required(VERSION 3.8.2)

if("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
    message(FATAL_ERROR "Do not build in-source. Please remove CMakeCache.txt and the CMakeFiles/ directory. Then build out-of-source.")
endif()

###############################
### Our modules and scripts ###
###############################

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_CURRENT_LIST_DIR}/cmake")
include(LTO)
include(Warnings)
include(RunFixupBundle)

###################
##### OPTIONS #####
###################

option(BP_BUILD_TESTS "Enable the tests targets" OFF)

# External dependencies
add_subdirectory(external EXCLUDE_FROM_ALL)

# Usually add_definitions should be avoided at all cost, but DNOMINMAX is a must on windows.
if(MSVC)
    add_definitions(/DNOMINMAX)
endif()

# It is always easier to navigate in an IDE when projects are organized in folders.
set_property(GLOBAL PROPERTY USE_FOLDERS ON)

###################
#### Project ######
###################

project(BoilerPlateProject C CXX)

# Check for LTO support (needs to be after project(...) )
find_lto(CXX)

set(SOURCE_FILES source/main.cpp ) 	# Always list the files explicitly
set(INCLUDE_FILES )					# In this case we don't have headers, but always list them so that they appear in the IDE

add_executable(BoilerPlate ${SOURCE_FILES} ${INCLUDE_FILES})
target_link_libraries(BoilerPlate
	#PUBLIC # Useful for libraries, see https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html for more details about transitive usage requirements.
		#libraries/targets to link when linking this library
		#this will automatically setup the needed flags and dependencies when linking against this target
	PRIVATE # The following libraries are only linked for this target, and its flags/dependencies will not be used when linking against this target
		general fmt spdlog # It is possible to link some libraries for debug or optimized builds only
		#debug DEBUGLIBS
		#optimized RELEASELIBS
)
target_include_directories(BoilerPlate PRIVATE include/)
# Require c++14, this is better than setting CMAKE_CXX_STANDARD since it won't pollute other targets
# note : cxx_std_* features were added in CMake 3.8.2
target_compile_features(BoilerPlate PRIVATE cxx_std_14)

# CMake scripts extensions
target_set_warnings(BoilerPlate ENABLE ALL AS_ERROR ALL DISABLE Annoying)
target_enable_lto(BoilerPlate optimized) #enable lto if available for non-debug configurations
run_fixup(BoilerPlate "" "") # Copy dependencies next to the executable (DLLs for example)

# Setup our project as the startup project for Visual so that people don't need to do it manually
set_directory_properties(PROPERTIES VS_STARTUP_PROJECT BoilerPlate)

#############
### Tests ###
#############
if(BP_BUILD_TESTS)
    enable_testing() # Must be in top CMakeLists.txt to be work with ctest
    add_subdirectory(tests)
endif()