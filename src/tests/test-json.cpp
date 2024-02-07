#include <catch2/catch_all.hpp>
#include <nlohmann/json.hpp>
#include <iostream>
#include <fstream>
#include <filesystem>
#if defined(_WIN32)
	#include <windows.h>
#endif

std::string getExecutableFilepath()
{
#if defined(_WIN32)
	std::string rv(MAX_PATH, '\0');
	rv.resize(::GetModuleFileNameA(nullptr, rv.data(), rv.capacity()));
#else
	std::string rv(PATH_MAX, '\0');
	rv.resize(::readlink("/proc/self/exe", rv.data(), rv.capacity()));
#endif
	return rv;
}

TEST_CASE("sf::Json", "[json]")
{
	SECTION("Json")
	{
		std::filesystem::path const path = std::filesystem::path(getExecutableFilepath())
			.parent_path().parent_path().parent_path()
			.append("src")
			.append("tests")
			.append("test.customer.json");
		std::cerr << "Json File: " << path << std::endl;
		REQUIRE(std::filesystem::exists(path));

		std::ifstream is;
		is.open(path.string());
		if (!is.is_open())
		{
			std::cerr << "File missing! " << path << std::endl;
		}
		REQUIRE(is.is_open());
		nlohmann::json j;
		std::cout << "Reading: " << path << std::endl;
		is >> j;
		is.close();
		std::cout << std::setw(2) << j;
	}
}

