# C++/CMake modern boilerplate [![Build Status](https://travis-ci.org/Lectem/boilerplate.svg?branch=master)](https://travis-ci.org/Lectem/boilerplate)[![Build status](https://ci.appveyor.com/api/projects/status/63mnrl1am9plfc4f/branch/master?svg=true)](https://ci.appveyor.com/project/Lectem/boilerplate/branch/master)

This is a template for new projects, gives a good CMake base and a few dependencies you most likely want in your project. It also set ups some basic CI builds.
It uses "modern" CMake, ie 3.x paradigms, and should be a good starting point for people willing to learn it.

Simply copy/paste the folder and run the .bat file (renaming to .sh should work for linux).

Requirements :

 * CMake 3.8.2 (Not needed for all scripts)
 * Git (for the submodules)

Some features/notes :

 * RunFixupBundle.cmake script : A small wrapper around fixup_bundle
 * LTO.cmake script : Easier link time optimization configuration (should work on all CMake 3.x versions) as it used to be painful to setup.
 * Warnings.cmake script : A wrapper around common warning settings
 * Travis and Appveyor support