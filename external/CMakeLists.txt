project(external C CXX)

set(BUILD_TESTING OFF CACHE BOOL "Force disable of tests for external dependencies" FORCE)

#Use fmtlib for formatting
add_subdirectory(fmt EXCLUDE_FROM_ALL)

#Use spdlog for logging, and tell it to use our version of fmtlib
add_subdirectory(spdlog EXCLUDE_FROM_ALL)
target_compile_definitions(spdlog INTERFACE SPDLOG_FMT_EXTERNAL)

#Doctest for unit tests
add_library(doctest INTERFACE)
target_include_directories(
    doctest
    INTERFACE
    doctest/doctest # note : will expose the parts/ folder...
)

#Add new external (non-interface) targets to this list
set_target_properties(fmt PROPERTIES FOLDER "external")

unset(BUILD_TESTING CACHE) # We will define our own option for tests