#include <catch2/catch_all.hpp>
#include <nlohmann/json.hpp>
#include <iostream>
#include <fstream>
#include <filesystem>

TEST_CASE("sf::Json", "[json]")
{
	SECTION("Json")
	{
		std::filesystem::path const path = std::filesystem::current_path().parent_path().append("test.customer.json");
		std::ifstream is;
		is.open(path.string());
		if (!is.is_open())
		{
			std::cerr << "File missing! " << path << std::endl;
		}
		CHECK(is.is_open());
		nlohmann::json j;
		std::cout << "Reading:" << path << std::endl;
		is >> j;
		is.close();
		std::cout <<  std::setw(2) << j;
	}
}




