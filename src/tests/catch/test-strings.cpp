#include "gen/template.h"
#include <catch2/catch_all.hpp>

TEST_CASE("Some Unit Tests", "[generic][any]")
{
	SECTION("Strings")
	{
		std::vector<std::string> slist;
		slist.insert(slist.end(), "Hello");
		slist.insert(slist.end(), "World");
		slist.insert(slist.end(), "3");
		slist.insert(slist.end(), "4.0");
		CHECK(slist == std::vector<std::string>{"Hello", "World", "3", "4.0"});
	}

	SECTION("Template")
	{
		CHECK(MySpace::calculateOffset(0.5, -2.0, 2.0, 1000U, true) == 625);
		CHECK(MySpace::calculateOffset(1.0, -2.0, 2.0, 1000U, true) == 750);
	}
}