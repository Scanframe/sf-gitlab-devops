#include <catch2/catch_all.hpp>

TEST_CASE("sf::StringSplit", "[generic][strings]")
{
	using Catch::Matchers::Equals;

	SECTION("Strings")
	{
		std::vector<std::string> sl;
		sl.insert(sl.end(), "Hello");
		sl.insert(sl.end(), "World");
		sl.insert(sl.end(), "3");
		sl.insert(sl.end(), "4.0");
		CHECK(sl == std::vector<std::string>{"Hello", "World", "3", "4.0"});
	}
}