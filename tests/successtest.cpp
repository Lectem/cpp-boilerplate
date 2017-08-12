#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include "doctest.h"
#include <foo.h>

static int the_answer_to_life(){return (1<<1) + (1<<3) + (1<<5);}

TEST_CASE("Main test") {
    CHECK(the_answer_to_life() == 42);
}

int untested_function(){ return 666; } // This should show as not tested in coverage

TEST_CASE("Foo test") {
    CHECK(foo() == 0);
    // We are not testing this correctly on purpose to test coverage
    // Should check foo(true) too for full coverage
}
