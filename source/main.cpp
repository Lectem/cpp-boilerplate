#include <fmt/format.h>

#if defined(_WIN32) && !defined(_WIN64)
#pragma message("I am targeting 32 - bit Windows.")
#endif

#ifdef _WIN64
#pragma message("I am targeting 64 - bit Windows.")
#endif

#ifdef __clang__
#pragma message("I am Clang, version: %s\n")
#endif

#if defined(__clang__) && defined(__c2__)
#pragma message("I am Clang / C2.")
#endif

#if defined(__clang__) && defined(__llvm__)
#pragma message("I am Clang / LLVM.")
#endif

// Not tested: __EDG__, __GNUC__, etc.


int main(int argc, char* argv[])
{
    if (argc)
    {
        fmt::print("hello world from {}!", argv[0]);
    }
    return 0;
}

