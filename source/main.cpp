#include <fmt/format.h>

int main(int argc, char* argv[])
{
    if (argc)
    {
        fmt::print("hello world from {}!", argv[0]);
    }
    return 0;
}

