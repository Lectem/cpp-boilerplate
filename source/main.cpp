/** @file main.cpp
 * Just a simple hello world using libfmt
 */
// The previous block is needed in every file for which you want to generate documentation

#include <fmt/format.h>

/**
 * @brief A function that does nothing but generate documentation
 * @param bar Any float value.
 * @return The answer to life, the universe and everything
 */
int foo(float bar) { return 42; }

int main(int argc, char* argv[])
{
    if (argc)
    {
        fmt::print("hello world from {}!", argv[0]);
    }
    return 0;
}
