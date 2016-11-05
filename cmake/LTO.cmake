# Usage :
#
# Variable : ENABLE_LTO | Enable or disable LTO support for this build
#
# find_lto(lang)
# - lang is C or CXX (the language to test LTO for)
# - call it after project() so that the compiler is already detected
#
# This will check for LTO support and populate the 'enable_lto' INTERFACE target as needed.
#
# if ENABLE_LTO is set to false or no LTO support is found, then an empty enable_lto will be created
#
# Then to enable LTO for your target use
#
# target_link_libraries(mytarget enable_lto)
#
# It is however recommended to use it only for non debug builds (see https://cmake.org/cmake/help/latest/command/target_link_libraries.html) :
#
# target_link_libraries(mytarget optimized enable_lto)
#
# WARNING : This module will override CMAKE_AR CMAKE_RANLIB and CMAKE_NM by the gcc versions if found when building with gcc


# License:
#
# Copyright (C) 2016 Lectem <lectem@gmail.com>
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the 'Software') deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


cmake_minimum_required(VERSION 3.0)

option(ENABLE_LTO "enable link time optimization (GCC/CLANG)" OFF)

macro(find_lto lang)
    if(ENABLE_LTO AND NOT LTO_${lang}_CHECKED)

      message(STATUS "Checking for LTO Compatibility")
      # Since GCC 4.9 we need to use gcc-ar / gcc-ranlib / gcc-nm
      if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
          if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND NOT CMAKE_GCC_AR OR NOT CMAKE_GCC_RANLIB OR NOT CMAKE_GCC_NM)
              find_program(CMAKE_GCC_AR NAMES
                "${_CMAKE_TOOLCHAIN_PREFIX}gcc-ar"
                "${_CMAKE_TOOLCHAIN_PREFIX}gcc-ar-${_version}"
                DOC "gcc provided wrapper for ar which adds the --plugin option"
              )
              find_program(CMAKE_GCC_RANLIB NAMES
                "${_CMAKE_TOOLCHAIN_PREFIX}gcc-ranlib"
                "${_CMAKE_TOOLCHAIN_PREFIX}gcc-ranlib-${_version}"
                DOC "gcc provided wrapper for ranlib which adds the --plugin option"
              )
              # Not needed, but at least stay coherent
              find_program(CMAKE_GCC_NM NAMES
                "${_CMAKE_TOOLCHAIN_PREFIX}gcc-nm"
                "${_CMAKE_TOOLCHAIN_PREFIX}gcc-nm-${_version}"
                DOC "gcc provided wrapper for nm which adds the --plugin option"
              )
              mark_as_advanced(CMAKE_GCC_AR CMAKE_GCC_RANLIB CMAKE_GCC_NM)
			  set(CMAKE_LTO_AR ${CMAKE_GCC_AR})
			  set(CMAKE_LTO_RANLIB ${CMAKE_GCC_RANLIB})
			  set(CMAKE_LTO_NM ${CMAKE_GCC_NM})
          endif()
		  if("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
			  set(CMAKE_LTO_AR ${CMAKE_AR})
			  set(CMAKE_LTO_RANLIB ${CMAKE_RANLIB})
			  set(CMAKE_LTO_NM ${CMAKE_NM})
		  endif()

          if(CMAKE_LTO_AR AND CMAKE_LTO_RANLIB)
            set(__lto_flags -flto)

            if(NOT CMAKE_${lang}_COMPILER_VERSION VERSION_LESS 4.7)
              list(APPEND __lto_flags -fno-fat-lto-objects)
            endif()

            if(NOT DEFINED CMAKE_${lang}_PASSED_LTO_TEST)
              set(__output_dir "${CMAKE_PLATFORM_INFO_DIR}/LtoTest1${lang}")
              file(MAKE_DIRECTORY "${__output_dir}")
              set(__output_base "${__output_dir}/lto-test-${lang}")

              execute_process(
                COMMAND ${CMAKE_COMMAND} -E echo "void foo() {}"
                COMMAND ${CMAKE_${lang}_COMPILER} ${__lto_flags} -c -xc -
                  -o "${__output_base}.o"
                RESULT_VARIABLE __result
                ERROR_QUIET
                OUTPUT_QUIET
              )

              if("${__result}" STREQUAL "0")
                execute_process(
                  COMMAND ${CMAKE_LTO_AR} cr "${__output_base}.a" "${__output_base}.o"
                  RESULT_VARIABLE __result
                  ERROR_QUIET
                  OUTPUT_QUIET
                )
              endif()

              if("${__result}" STREQUAL "0")
                execute_process(
                  COMMAND ${CMAKE_LTO_RANLIB} "${__output_base}.a"
                  RESULT_VARIABLE __result
                  ERROR_QUIET
                  OUTPUT_QUIET
                )
              endif()

              if("${__result}" STREQUAL "0")
                execute_process(
                  COMMAND ${CMAKE_COMMAND} -E echo "void foo(); int main() {foo();}"
                  COMMAND ${CMAKE_${lang}_COMPILER} ${__lto_flags} -xc -
                    -x none "${__output_base}.a" -o "${__output_base}"
                  RESULT_VARIABLE __result
                  ERROR_QUIET
                  OUTPUT_QUIET
                )
              endif()

              if("${__result}" STREQUAL "0")
                set(__lto_found TRUE)
              endif()

              set(CMAKE_${lang}_PASSED_LTO_TEST
                ${__lto_found} CACHE INTERNAL
                "If the compiler passed a simple LTO test compile")
            endif()
            if(CMAKE_${lang}_PASSED_LTO_TEST)
              message(STATUS "Checking for LTO Compatibility - works")
              set(LTO_${lang}_SUPPORT TRUE CACHE BOOL "Do we have LTO support ?")
              set(LTO_COMPILE_FLAGS -flto CACHE STRING "Link Time Optimization compile flags")
              set(LTO_LINK_FLAGS -flto CACHE STRING "Link Time Optimization link flags")
            else()
              message(STATUS "Checking for LTO Compatibility - not working")
            endif()

          endif()
		elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
			message(STATUS "Checking for LTO Compatibility - works (assumed for clang)")
			set(LTO_${lang}_SUPPORT TRUE CACHE BOOL "Do we have LTO support ?")
			set(LTO_COMPILE_FLAGS -flto CACHE STRING "Link Time Optimization compile flags")
			set(LTO_LINK_FLAGS -flto CACHE STRING "Link Time Optimization link flags")
        elseif(MSVC)
            message(STATUS "Checking for LTO Compatibility - works")
            set(LTO_${lang}_SUPPORT TRUE CACHE BOOL "Do we have LTO support ?")
            set(LTO_COMPILE_FLAGS /GL CACHE STRING "Link Time Optimization compile flags")
            set(LTO_LINK_FLAGS -LTCG:INCREMENTAL CACHE STRING "Link Time Optimization link flags")
        else()
            message(STATUS "Checking for LTO Compatibility - compiler not handled by module")
        endif()
        mark_as_advanced(LTO_${lang}_SUPPORT LTO_COMPILE_FLAGS LTO_LINK_FLAGS)


        set(LTO_${lang}_CHECKED TRUE CACHE INTERNAL "" )
    endif(ENABLE_LTO AND NOT LTO_${lang}_CHECKED)
	if(CMAKE_GCC_AR AND CMAKE_GCC_RANLIB AND CMAKE_GCC_NM)
		# THIS IS HACKY BUT THERE IS NO OTHER SOLUTION ATM
		set(CMAKE_AR ${CMAKE_GCC_AR} CACHE FILEPATH "Forcing gcc-ar instead of ar" FORCE)
		set(CMAKE_NM ${CMAKE_GCC_NM} CACHE FILEPATH "Forcing gcc-nm instead of nm" FORCE)
		set(CMAKE_RANLIB ${CMAKE_GCC_RANLIB} CACHE FILEPATH "Forcing gcc-ranlib instead of ranlib" FORCE)
	endif()
    if(NOT TARGET enable_lto)
        add_library(enable_lto INTERFACE)
        if(ENABLE_LTO AND LTO_${lang}_SUPPORT)
            target_compile_options(enable_lto INTERFACE ${LTO_COMPILE_FLAGS})
            target_link_libraries(enable_lto INTERFACE ${LTO_LINK_FLAGS} )
        endif()
    endif()
endmacro()
