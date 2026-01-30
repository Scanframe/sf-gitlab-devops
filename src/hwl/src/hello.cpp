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
	HMODULE handle = ::GetModuleHandleA("ntdll.dll");
	if (handle && ::GetProcAddress(handle, "wine_get_version"))
	{
		return true;
	}
#endif
	return false;
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

std::string getCompilerVersion()
{
#if defined(_MSC_VER)
	return std::string("MSVC ") + std::to_string(_MSC_VER % 100) + "." + std::to_string(_MSC_VER / 100) + "." + std::to_string(_MSC_FULL_VER % 100000);
#elif defined(__GNUC__)
	return std::string("GCC ") + std::to_string(__GNUC__) + "." + std::to_string(__GNUC_MINOR__) + "." + std::to_string(__GNUC_PATCHLEVEL__);
#else
	return {"Unknown ?.?.?"}
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

void killOtherThreads()
{
#if IS_WIN
	if (isWine())
	{
		const auto pid = ::GetCurrentProcessId();
		auto snapshot = ::CreateToolhelp32Snapshot(TH32CS_SNAPTHREAD, 0);
		THREADENTRY32 te;
		te.dwSize = sizeof(te);
		if (::Thread32First(snapshot, &te) != 0)
		{
			do
			{
				if (te.th32OwnerProcessID == pid && te.th32ThreadID != ::GetCurrentThreadId())
				{
					if (auto hThread = ::OpenThread(THREAD_TERMINATE, FALSE, te.th32ThreadID))
					{
						::TerminateThread(hThread, 0);
						::CloseHandle(hThread);
					}
				}
			} while (::Thread32Next(snapshot, &te) != 0);
		}
		CloseHandle(snapshot);
	}
#endif
}
