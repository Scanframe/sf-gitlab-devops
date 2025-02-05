#include <catch2/catch_all.hpp>
#include <hwl/hello.h>

TEST_CASE("sf::Hello", "[generic][hello]")
{
	SECTION("World")
	{
		CHECK(getHello(0) == "Hello World!");
	}

	SECTION("Universe")
	{
		CHECK(getHello(2) == "Hello Universe!");
	}
}