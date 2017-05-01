cmake_minimum_required(VERSION 3.6)
# Note : must be included by master CMakeLists.txt
# Tests in static libraries will not be registered, see https://github.com/onqtam/doctest/blob/master/doc/markdown/faq.md#why-are-my-tests-in-a-static-library-not-getting-registered
# For this reason, and because it is interesting to have individual 
# test executables for each library, it is suggested not to put tests directly in the libraries (even though doctest advocates this usage)

add_executable(failtest failtest.cpp)
target_link_libraries(failtest doctest)

add_test(NAME failtest
         COMMAND failtest
)

add_executable(successtest successtest.cpp)
target_link_libraries(successtest doctest)

add_test(NAME successtest
         COMMAND successtest
)

