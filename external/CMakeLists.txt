project(external C CXX)

#Use fmtlib for formatting
add_subdirectory(fmt EXCLUDE_FROM_ALL)

#Use spdlog for logging, and tell it to use our version of fmtlib
add_subdirectory(spdlog EXCLUDE_FROM_ALL)
target_compile_definitions(spdlog INTERFACE SPDLOG_FMT_EXTERNAL)

#Add new external (non-interface) targets to this list
set_target_properties(fmt PROPERTIES FOLDER "external")