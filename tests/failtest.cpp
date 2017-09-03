#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include "doctest.h"

static int factorial(int number) { return number <= 1 ? number : factorial(number - 1) * number; }

TEST_CASE("testing the factorial function") {
    CHECK(factorial(0) == 1);
    CHECK(factorial(1) == 1);
    CHECK(factorial(2) == 2);
    CHECK(factorial(3) == 6);
    CHECK(factorial(10) == 3628800);
}
#if __GNUC__ // Doesn't crash for gcc/clang, but will with msvc
TEST_CASE("Trigger ASan")
{
    int *array = new int[100];
    delete [] array;
    array[0] = 0; //boom
    REQUIRE(false);
}
#endif