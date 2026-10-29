#if WIN32
	#include <windows.h>
	#include <synchapi.h>
#else
	#include <unistd.h>
#endif
#include <hwl/hello.h>
#include <iostream>

int main(int argc, char** argv)
{
	listLoadedLibraries(std::cout);
	std::cout << "Application: " + getApplicationVersion() << std::endl;
	std::cout << "Timestamp: " + utcTimeString() << std::endl;
	std::cout << "Qemu Virtualization: " << (isQemu() ? "Yes" : "No") << std::endl;
#if WIN32
	std::cout << "Wine Version: " << getWineVersion() << std::endl;
#endif
	std::cout << "CPU Architecture: " << getCpuArchitecture() << std::endl;
	std::cout << "Compiler: " << getCompilerVersion() << std::endl;
	std::cout << "Standard: " << getCppStandardVersion() << std::endl;
	std::cout << getHello(0) << std::endl;
	std::cout << getHello(1) << std::endl;
	if (argc > 1)
	{
		const auto seconds = std::stoi(argv[1], nullptr, 10);
		std::cout << "Sleeping for " << seconds << " seconds" << std::endl;
#if WIN32
		::Sleep(seconds * 1000);
#else
		::sleep(seconds);
#endif
	}
	return 0;
}
