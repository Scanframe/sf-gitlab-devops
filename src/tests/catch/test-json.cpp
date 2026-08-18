#include <catch2/catch_all.hpp>
#if defined(_WIN32)
	#include <windows.h>
#endif
#include <climits>
#include <csignal>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <nlohmann/json.hpp>

static std::string getExecutableFilepath()
{
#if defined(_WIN32)
	std::string retval(MAX_PATH, '\0');
	retval.resize(::GetModuleFileNameA(nullptr, retval.data(), retval.capacity()));
#else
	std::string retval(PATH_MAX, '\0');
	retval.resize(::readlink("/proc/self/exe", retval.data(), retval.capacity()));
#endif
	return retval;
}

TEST_CASE("sf::Json", "[json]")
{
	SECTION("Json")
	{
		std::filesystem::path const path =//
			std::filesystem::path(getExecutableFilepath())
				.parent_path()
				.parent_path()
				.parent_path()
				.append("src")
				.append("tests")
				.append("catch")
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
		std::clog << "Reading: " << path << std::endl;
		is >> j;
		is.close();
		std::clog << std::setw(2) << j;
	}
}
