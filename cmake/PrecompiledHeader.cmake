# Source repository available at https://github.com/LucidFusionLabs/cmake-precompiled-header
# Copy of repository available at https://github.com/Lectem/cmake-precompiled-header 
# SHA : cb56463624551ad0bb4be31d7edf1a5c330a2588
#-----------------------------------------------------------------------------------
# Function for setting up precompiled headers. Usage:
#
#   add_library/executable(target
#       pchheader.c pchheader.cpp root/path/to/pchheader.h)
#
#   add_precompiled_header(target root/path/to/pchheader.h c++-header
#       [COMPILE_OPTIONS]
#       [COMPILE_DEFINITIONS]
#       [INCLUDE_DIRECTORIES])
#
#   use_precompiled_header(target root/path/to/pchheader.h
#       [FORCEINCLUDE])
#
# Options:
#
#   FORCEINCLUDE: Add compiler flags to automatically include the
#   pchheader.h from every source file. Works with both GCC and
#   MSVC. This is recommended.
#
# License:
#
# Copyright (C) 2016 Justin F <justin@lucidfusionlabs.com>
# Copyright (C) 2009-2013 Lars Christensen <larsch@belunktum.dk>
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

include(CMakeParseArguments)

if(NOT PCH_PROJECT_SOURCE_DIR)
  set(PCH_PROJECT_SOURCE_DIR ${CMAKE_SOURCE_DIR})
endif()
if(NOT PCH_PROJECT_BINARY_DIR)
  set(PCH_PROJECT_BINARY_DIR ${CMAKE_BINARY_DIR})
endif()

macro(set_pch_vars _input)
  set(_pch_header "${PCH_PROJECT_SOURCE_DIR}/${_input}")
  get_filename_component(_name ${_input} NAME)
  get_filename_component(_dir ${_input} DIRECTORY)
  set(_pch_binary_dir "${PCH_PROJECT_BINARY_DIR}/${_dir}/${_name}_pch")
  if(USE_PRECOMPILED_HEADERS)
    set(_pchfile "${_pch_binary_dir}/${_name}")
    set(_output "${_pchfile}.gch")
  else()
    set(_pchfile ${_pch_header})
    set(_output "${_pch_binary_dir}/${_name}")
  endif()
endmacro()

function(add_precompiled_header _target _input _type)
  set_pch_vars(${_input})
  make_directory(${_pch_binary_dir})

  set(options)
  set(one_value_args)
  set(multi_value_args COMPILE_DEFINITIONS COMPILE_OPTIONS INCLUDE_DIRECTORIES)
  cmake_parse_arguments("" "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
  if(CMAKE_BUILD_TYPE MATCHES Release)
    set(_compile_options ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_RELEASE} ${_COMPILE_OPTIONS})
  else()
    set(_compile_options ${CMAKE_CXX_FLAGS} ${CMAKE_CXX_FLAGS_DEBUG} ${_COMPILE_OPTIONS})
  endif()

  if(USE_PRECOMPILED_HEADERS)
    set(_compile_options "$<$<BOOL:${_compile_options}>:$<JOIN:${_compile_options},\n>\n>")
    set(_compile_definitions "$<$<BOOL:${_COMPILE_DEFINITIONS}>:$<JOIN:${_COMPILE_DEFINITIONS},\n>\n>")
    set(_include_directories "$<$<BOOL:${_INCLUDE_DIRECTORIES}>:-I$<JOIN:${_INCLUDE_DIRECTORIES},\n-I>\n>")
    set(_pch_flags_file "${_pch_binary_dir}/compile_flags.rsp")
    file(GENERATE OUTPUT ${_pch_flags_file} CONTENT "${_compile_options}${_compile_definitions}${_include_directories}\n")
    set(_compiler_FLAGS @${_pch_flags_file})

    if(WIN32)
      add_custom_command(
        OUTPUT ${_output}
        COMMAND "${CMAKE_CXX_COMPILER}" ${_compiler_FLAGS} /Fd"${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_BUILD_TYPE}/${_target}.pdb" /TP /c /Fp${_output} /Yc ${_pch_header}
        DEPENDS ${_pch_header} ${_pch_flags_file}
        IMPLICIT_DEPENDS CXX ${_pch_header}
        COMMENT "Precompiling ${_input}")

    elseif(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_CXX_COMPILER_ID MATCHES "Apple")
      add_custom_command(
        OUTPUT "${_output}"
        COMMAND "${CMAKE_CXX_COMPILER}" ${_compiler_FLAGS} -x ${_type} -o "${_output}" "${_pch_header}"
        DEPENDS ${_pch_header} ${_pch_flags_file}
        IMPLICIT_DEPENDS CXX ${_pch_header}
        COMMENT "Precompiling ${_input}")
    endif()
  else()
    # Dummy dep to proxy IMPLICIT_DEPENDS of input
    add_custom_command(
      OUTPUT "${_output}"
      COMMAND "${CMAKE_COMMAND}" -E copy "${_pch_header}" "${_output}"
      DEPENDS ${_pch_header}
      IMPLICIT_DEPENDS CXX ${_pch_header})
  endif()
endfunction()

function(target_use_precompiled_header _target _input)
  set_pch_vars(${_input})
  cmake_parse_arguments(_PCH "FORCEINCLUDE" "" "" ${ARGN})

  if(WIN32)
    set(_pch_compile_flags)
    if(_PCH_FORCEINCLUDE)
      if(USE_PRECOMPILED_HEADERS)
        set(_pch_compile_flags /FI${_pchfile} /Yu${_pchfile} /Fp${_output})
      else()
        set(_pch_compile_flags /FI${_pchfile})
      endif()
    elseif(USE_PRECOMPILED_HEADERS)
      set(_pch_compile_flags /I ${_pch_binary_dir})
    endif()
    target_compile_options(${_target} PRIVATE ${_pch_compile_flags})

  elseif(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang"
         OR CMAKE_CXX_COMPILER_ID MATCHES "Apple")
    set(_pch_compile_flags)
    if(_PCH_FORCEINCLUDE)
      if(USE_PRECOMPILED_HEADERS)
        set(_pch_compile_flags -include-pch ${_output})
      else()
        set(_pch_compile_flags -include ${_pchfile})
      endif()
    elseif(USE_PRECOMPILED_HEADERS)
      set(_pch_compile_flags -I${_pch_binary_dir})
    endif()
    target_compile_options(${_target} PRIVATE ${_pch_compile_flags})
  
  else()
    message(FATAL_ERROR "Unknown compiler ${CMAKE_CXX_COMPILER_ID}")
  endif()

  get_property(_sources TARGET ${_target} PROPERTY SOURCES)
  foreach(_source ${_sources})
    if(_source MATCHES \\.\(cc|cxx|cpp|c|m|mm\)$)
      get_source_file_property(_object_depends "${_source}" OBJECT_DEPENDS)
      if(NOT _object_depends)
        set(_object_depends)
      endif()
      list(APPEND _object_depends "${_pch_header}")
      list(APPEND _object_depends "${_output}")
      set_source_files_properties(${_source} PROPERTIES OBJECT_DEPENDS "${_object_depends}")
    endif()
  endforeach()

endfunction()
