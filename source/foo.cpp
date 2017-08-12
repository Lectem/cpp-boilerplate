
#include "foo.h"
#include <fmt/format.h>


int foo(bool branch)
{
    if(branch)
    {
        fmt::print("This line will be untested, so that coverage is not 100%\n");
    }
    else
    {
        fmt::print("This is the default behaviour and will be tested\n");
    }
    return 0;
}
