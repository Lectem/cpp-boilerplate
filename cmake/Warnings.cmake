# Helper script to set warnings
# Usage :
#  target_set_warnings(target
#    [ENABLE [ALL] [list of warning names]]
#    [DISABLE [ALL/Annoying] [list of warning names]]
#    [AS_ERROR ALL]
#  )
#
#  ENABLE
#    * ALL: means all the warnings possible to enable through a one parameter switch.
#      Note that for some compilers, this does not mean every single warning will be enabled (GCC for instance).
#    * Any other name: enable the warning with the given name
#
#  DISABLE
#    * ALL: will override any other settings and this target INTERFACE includes will be considered as system includes by targets linking it.
#    * Annoying: Warnings that the author thinks should only be used as static analysis tools not in production. On MSVC, also sets _CRT_SECURE_NO_WARNINGS.
#    * Any other name: disable the warning with the given name
#
#  AS_ERROR
#    * ALL: is the only option available as not all compilers let us set specific warnings as error from command line (MSVC).
#
#
# License:
#
# Copyright (C) 2019 Lectem <lectem@gmail.com>
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


cmake_minimum_required(VERSION 3.1)

option(ENABLE_WARNINGS_SETTINGS "Allow target_set_warnings to add flags and defines. Set this to OFF if you want to provide your own warning parameters." ON)

function(target_set_warnings)
    if(NOT ENABLE_WARNINGS_SETTINGS)
        return()
    endif()
    if ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "MSVC")
      set(WMSVC TRUE)
      set(WARNING_ENABLE_PREFIX "/w1") # Means the warning will be available at all levels that do emit warnings
      set(WARNING_DISABLE_PREFIX "/wd")
    elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
      set(WGCC TRUE)
      set(WARNING_ENABLE_PREFIX "-W")
      set(WARNING_DISABLE_PREFIX "-Wno-")
    elseif ("${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
      set(WCLANG TRUE)
      set(WARNING_ENABLE_PREFIX "-W")
      set(WARNING_DISABLE_PREFIX "-Wno-")
    endif()
    set(multiValueArgs ENABLE DISABLE AS_ERROR)
    cmake_parse_arguments(this "" "" "${multiValueArgs}" ${ARGN})
    list(FIND this_ENABLE "ALL" enable_all)
    list(FIND this_DISABLE "ALL" disable_all)
    list(FIND this_AS_ERROR "ALL" as_error_all)
    if(NOT ${enable_all} EQUAL -1)
      if(WMSVC)
        # Not all the warnings, but WAll is unusable when using libraries
        # Unless you'd like to support MSVC in the code with pragmas, this is probably the best option
        list(APPEND WarningFlags "/W4")
      elseif(WGCC)
        list(APPEND WarningFlags "-Wall" "-Wextra" "-Wpedantic")
      elseif(WCLANG)
        list(APPEND WarningFlags "-Wall" "-Weverything" "-Wpedantic")
      endif()
    elseif(NOT ${disable_all} EQUAL -1)
      set(SystemIncludes TRUE) # Treat includes as if coming from system
      if(WMSVC)
        list(APPEND WarningFlags "/w" "/W0")
      elseif(WGCC OR WCLANG)
        list(APPEND WarningFlags "-w")
      endif()
    endif()

    list(FIND this_DISABLE "Annoying" disable_annoying)
    if(NOT ${disable_annoying} EQUAL -1)
      if(WMSVC)
        # bounds-checked functions require to set __STDC_WANT_LIB_EXT1__ which we usually don't need/want
        list(APPEND WarningDefinitions -D_CRT_SECURE_NO_WARNINGS)
        # disable C4514 C4710 C4711... Those are useless to add most of the time
        #list(APPEND WarningFlags "/wd4514" "/wd4710" "/wd4711")
        #list(APPEND WarningFlags "/wd4365") #signed/unsigned mismatch
        #list(APPEND WarningFlags "/wd4668") # is not defined as a preprocessor macro, replacing with '0' for
      elseif(WGCC OR WCLANG)
        list(APPEND WarningFlags -Wno-switch-enum)
        if(WCLANG)
          list(APPEND WarningFlags -Wno-unknown-warning-option -Wno-padded -Wno-undef -Wno-reserved-id-macro -Wno-inconsistent-missing-destructor-override -fcomment-block-commands=test,retval)
          if(NOT CMAKE_CXX_STANDARD EQUAL 98)
              list(APPEND WarningFlags -Wno-c++98-compat -Wno-c++98-compat-pedantic)
          endif()
          if ("${CMAKE_CXX_SIMULATE_ID}" STREQUAL "MSVC") # clang-cl has some VCC flags by default that it will not recognize...
              list(APPEND WarningFlags -Wno-unused-command-line-argument)
          endif()
        endif(WCLANG)
      endif()
    endif()

    if(NOT ${as_error_all} EQUAL -1)
      if(WMSVC)
        list(APPEND WarningFlags "/WX")
      elseif(WGCC OR WCLANG)
        list(APPEND WarningFlags "-Werror")
      endif()
    endif()

    if(this_ENABLE)
      list(REMOVE_ITEM this_ENABLE ALL)
      foreach(warning-name IN LISTS this_ENABLE)
        list(APPEND WarningFlags "${WARNING_ENABLE_PREFIX}${warning-name}")
      endforeach()
    endif()


    if(this_DISABLE)
      list(REMOVE_ITEM this_DISABLE ALL Annoying)
      foreach(warning-name IN LISTS this_DISABLE)
        list(APPEND WarningFlags "${WARNING_DISABLE_PREFIX}${warning-name}")
      endforeach()
    endif()

    foreach(target IN LISTS this_UNPARSED_ARGUMENTS)
      if(WarningFlags)
        target_compile_options(${target} PRIVATE ${WarningFlags})
      endif()
      if(WarningDefinitions)
        target_compile_definitions(${target} PRIVATE ${WarningDefinitions})
      endif()
      if(SystemIncludes)
        set_target_properties(${target} PROPERTIES
            INTERFACE_SYSTEM_INCLUDE_DIRECTORIES $<TARGET_PROPERTY:${target},INTERFACE_INCLUDE_DIRECTORIES>)
      endif()
    endforeach()
endfunction(target_set_warnings)
