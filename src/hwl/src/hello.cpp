#include "hello.h"
#include <array>
#include <chrono>
#include <filesystem>
#include <fstream>
#include <functional>
#include <thread>
#if IS_WIN
	#if IS_GNU
		#include <windows.h>
	#else
		#include <Windows.h>
	#endif
	#include <tlhelp32.h>
#else
	#include <link.h>
#endif

std::string utcTimeString()
{
	// Example of the very popular RFC 3339 format UTC time
	std::time_t time = std::time({});
	std::array<char, 256> s_time{};
	auto sz = std::strftime(s_time.data(), s_time.size(), "%Y-%m-%dT%H:%M:%S", std::gmtime(&time));
	s_time.at(sz) = 0;
	return s_time.data();
}

bool isQemu()
{
#if !IS_WIN
	// QEMU often uses virtio devices.
	if (std::filesystem::exists("/sys/bus/virtio"))
		return true;
#endif
	return false;
}

bool isWine()
{
#if IS_WIN
	static const bool underWine = [] {
		HMODULE ntdll = ::GetModuleHandleW(L"ntdll.dll");
		return ntdll && ::GetProcAddress(ntdll, "wine_get_version") != nullptr;
	}();
	return underWine;
#else
	return false;
#endif
}

std::string getWineVersion()
{
	std::string retval;
#if IS_WIN
	static const char* version = reinterpret_cast<const char*>(UINTPTR_MAX);
	// Sentry for Wine version detection.
	if (reinterpret_cast<uintptr_t>(version) == UINTPTR_MAX)
	{
		HMODULE ntdll = ::GetModuleHandleA("ntdll.dll");
		if (ntdll)
		{
			// using wine_get_version_t = const char* (*)();
			auto wine_get_version = reinterpret_cast<const char* (*)()>(GetProcAddress(ntdll, "wine_get_version"));
			version = wine_get_version ? wine_get_version() : nullptr;
		}
		else
		{
			version = nullptr;
		}
	}
	return version ? version : "";
#else
	return "";
#endif
}

std::string getCpuArchitecture()
{
#if defined(__x86_64__) || defined(__amd64__) || defined(_M_X64)
	return {"x86-64/amd64"};
#elif defined(__i386__) || defined(_M_IX86)
	return {"i386/i32"};
#elif defined(__aarch64__) || defined(_M_ARM64)
	return {"aarch/arm64"};
#elif defined(__arm__) || defined(__ARM__) || defined(_M_ARM)
	return {"arm/arm32"};
#elif defined(__riscv) || defined(__riscv__)
	#if __riscv_xlen == 64
	return "riscv64";
	#else
	return "riscv32";
	#endif
#elif defined(__powerpc64__)
	return {"ppc64"};
#elif defined(__powerpc__)
	return {"ppc32"};
#else
	return {"Unknown/generic"};
#endif
}

#define _STRINGIFY_(x) #x
#define _TOSTRING_(x) _STRINGIFY_(x)

std::string getApplicationVersion()
{
	return _TOSTRING_(SF_VERSION);
}

std::string getCompilerVersion()
{
#if defined(_MSC_VER)
	return std::string("MSVC ") + std::to_string(_MSC_VER % 100) + "." + std::to_string(_MSC_VER / 100) + "." + std::to_string(_MSC_FULL_VER % 100000);
#elif defined(__GNUC__)
	return std::string("GCC ") + std::to_string(__GNUC__) + "." + std::to_string(__GNUC_MINOR__) + "." + std::to_string(__GNUC_PATCHLEVEL__);
#else
	return {"Unknown ?.?.?"};
#endif
}

std::string getCppStandardVersion()
{
#if __cplusplus == 199711L
	return {"C++98/03"};
#elif __cplusplus == 201103L
	return {"C++11"};
#elif __cplusplus == 201402L
	return {"C++14"};
#elif __cplusplus == 201703L
	return {"C++17"};
#elif __cplusplus == 202002L
	return {"C++20"};
#elif __cplusplus == 202302L
	return {"C++23"};
#else
	return {"Unknown C++ standard"};
#endif
}

std::string getHello(int how)
{
	std::string rv;
	if (how > 0)
	{
		rv = "Hello Universe!";
	}
	else
	{
		rv = "Hello World!";
	}
	return rv;
}

void listLoadedLibraries(std::ostream& os)
{
#if !IS_WIN
	// Callback function executed for each loaded library.
	auto callback = [](dl_phdr_info* info, size_t, void* data) -> int {
		auto& os = *static_cast<std::ostream*>(data);
		// The first entry is usually the main executable itself, which has an empty name.
		if (info->dlpi_name && info->dlpi_name[0] != '\0')
		{
			os << "Library: " << info->dlpi_name << " (Base Address: 0x" << std::hex << info->dlpi_addr << std::dec << ")\n";
		}
		else
		{
			os << "Executable: 0x" << std::hex << info->dlpi_addr << "\n";
		}
		return 0;
	};
	dl_iterate_phdr(callback, &os);
#endif
}
