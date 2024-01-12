#include <catch2/catch_all.hpp>

TEST_CASE("sf::StringSplit", "[generic][strings]")
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
}