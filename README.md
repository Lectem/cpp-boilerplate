# C++/CMake modern boilerplate

[![CMake](https://github.com/Lectem/cpp-boilerplate/actions/workflows/cmake.yml/badge.svg)](https://github.com/Lectem/cpp-boilerplate/actions/workflows/cmake.yml)
[![Appveyor build status](https://ci.appveyor.com/api/projects/status/63mnrl1am9plfc4f/branch/master?svg=true)](https://ci.appveyor.com/project/Lectem/boilerplate/branch/master)
[![Coverage](https://codecov.io/gh/Lectem/cpp-boilerplate/branch/master/graph/badge.svg)](https://codecov.io/gh/Lectem/cpp-boilerplate)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/dfaaaa975fd349b4a565500d97c8d5e1)](https://app.codacy.com/gh/Lectem/cpp-boilerplate/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)
[![CodeQL](https://github.com/Lectem/cpp-boilerplate/actions/workflows/codeql.yml/badge.svg)](https://github.com/Lectem/cpp-boilerplate/actions/workflows/codeql.yml)
[![CDash dashboard](https://img.shields.io/badge/CDash-Access-blue.svg)](http://my.cdash.org/index.php?project=cpp-boilerplate)

[![Pull requests](https://img.shields.io/github/issues-pr-raw/Lectem/cpp-boilerplate.svg)](https://github.com/Lectem/cpp-boilerplate/pulls)
[![Opened issues](https://img.shields.io/github/issues-raw/Lectem/cpp-boilerplate.svg)](https://github.com/Lectem/cpp-boilerplate/issues)
[![Documentation](https://img.shields.io/badge/Documentation-latest-blue.svg)](https://lectem.github.io/cpp-boilerplate)

This is a template for new projects, gives a good CMake base and a few dependencies you most likely want in your project. It also set ups some basic CI builds.

It uses "modern" CMake, ie 3.x paradigms, and should be a good starting point for both people willing to learn it and those that want to update/upgrade their CMakeLists.txt!

Everything will not necessarily be useful for new projects, but serves as a learning document where most of the CMake features you will need should be showcased.

If you disagree with some pieces of advice given here, please discuss it with me by opening a Github Issue! Enhancements are always welcome.  

## Usage

If you want to bootstrap a new project you only need to :

-   If you don't already have your git repository setup
    -   Simply copy/paste the folder (without the .git folder) and run the createBoilerPlate.sh file. This will create an initial git commit and add the _required_ submodules.
-   Hack CMakeLists.txt and CTestConfig.cmake to change the project name, remove unnecessary parts/comments.
-   Ready to go !

The CI providers used and that might need some setup :
-   Github actions (no setup required)
-   AppVeyor, for MSVC on Windows
-   Codecov.io, for the codecoverage reports
-   CDash, for test and coverage reports using CTest. Can also be used to build nightlies.

## Requirements :

-   CMake 3.16 (Not needed for all scripts)
-   Git (for the submodules)
-   Any of the CI providers listed above if needed.

## Some features/notes :

-   Scripts lying in the cmake/ folder can be copy/pasted for use in any CMake project
-   Uses c++14
-   CopyDllsForDebug.cmake script : A small wrapper around fixup_bundle to copy DLLs to the output directory on windows
-   LTO.cmake script : Easier link time optimization configuration (should work on all CMake 3.x versions) as it used to be painful to setup.
-   Warnings.cmake script : A wrapper around common warning settings
-   Basic unit-testing using [doctest](https://github.com/onqtam/doctest)
-   Coverage.cmake : Test coverage script to add a 'Coverage' build type to CMake
-   CodeQL already knows about cmake and can build most of the projects without any special configuration. A sample configuration is in this project, mostly due to using submodules.

## FAQ

**Q**: I'm new to this CMake stuff, where do I start ?

**A**: I would suggest reading my [blog posts](https://siliceum.com/en/blog/post/cmake_01_cmake-basics), [CGold](https://cgold.readthedocs.io) or [An introduction to Modern CMake](https://cliutils.gitlab.io/modern-cmake/README.html) or simply the latest and official [tutorial](https://cmake.org/cmake/help/latest/guide/tutorial/index.html)!

___

**Q**: Why can't I link some new libraries I put inside the external folder ?

**A**: By default targets are not at the GLOBAL scope, which means your CMakelists.txt might not see it.
In this case you can either add an alias/imported library or use find_package/library as you would if the library was not in your buildtree.

___

**Q**: Should I always put my dependencies in the folder external

**A**: Absolutely not ! It is a great place for small libraries, but you probably don't want to have to rebuild big libs every time.
For those, you can use a package manager such as [VCPKG](https://github.com/microsoft/vcpkg/), [CPM](https://github.com/cpm-cmake/CPM.cmake) or simply rely on `find_package`.

___

**Q**: I don't understand why you made the choice of XXXXXX here ?

**A**: Open a new issue !

## External dependencies (using submodules)

Those dependencies can be easily removed by changing the external/CMakelists.txt and cleaning main.cpp.

-   [libfmt](https://github.com/fmtlib/fmt) In my opinion the best formating library
-   [spdlog](https://github.com/gabime/spdlog) A logging library based on libfmt
-   [doctest](https://github.com/onqtam/doctest) A test library not as heavy as the others
