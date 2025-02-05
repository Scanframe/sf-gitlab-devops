#include "hello.h"
#include <array>
#include <ctime>

std::string utcTimeString()
{
	// Example of the very popular RFC 3339 format UTC time
	std::time_t time = std::time({});
	std::array<char, 256> s_time{};
	auto sz = std::strftime(s_time.data(), s_time.size(), "%Y-%m-%dT%H:%M:%S", std::gmtime(&time));
	s_time.at(sz) = 0;
	return s_time.data();
}

std::string getGCCVersion()
{
#ifdef __GNUC__
	return std::to_string(__GNUC__) + "." +
		std::to_string(__GNUC_MINOR__) + "." +
		std::to_string(__GNUC_PATCHLEVEL__);
#else
	return "?.?.?";
#endif
}

std::string getCppStandardVersion()
{
#if __cplusplus == 199711L
	return "C++98/03";
#elif __cplusplus == 201103L
	return "C++11";
#elif __cplusplus == 201402L
	return "C++14";
#elif __cplusplus == 201703L
	return "C++17";
#elif __cplusplus == 202002L
	return "C++20";
#elif __cplusplus == 202302L
	return "C++23";
#else
	return "Unknown C++ standard";
#endif
}

std::string getHello(int how)
{
	std::string rv;
	if (how > 0)
	{
		rv = std::string("Hello Universe!");
	}
	else
	{
		rv = std::string("Hello World!");
	}
	return rv;
}