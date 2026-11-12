#include "cli/template.h"
#include <catch2/catch_all.hpp>

TEST_CASE("Template Unit Tests", "[generic][any]")
{
	SECTION("Template")
	{
		CHECK(MySpace::calculateOffset(0.5, -2.0, 2.0, 1000U, true) == 625);
		CHECK(MySpace::calculateOffset(1.0, -2.0, 2.0, 1000U, true) == 750);
	}
}