#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include "doctest.h"

static int the_answer_to_life(){return (1<<1) + (1<<3) + (1<<5);}

TEST_CASE("Main test") {
    CHECK(the_answer_to_life() == 42);
}