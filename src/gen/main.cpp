#include <hwl/hello.h>
#include <iostream>
#include <unistd.h>

int main(int argc, char** argv)
{
	std::cout << "Timestamp: " + utcTimeString() << std::endl;
	std::cout << "GCC Version: " << getGCCVersion() << std::endl;
	std::cout << "Standard: " << getCppStandardVersion() << std::endl;
	std::cout << getHello(0) << std::endl;
	std::cout << getHello(1) << std::endl;
	if (argc > 1)
	{
		auto seconds = std::atoi(argv[1]);
		std::cout << "Sleeping for " << seconds << " seconds" << std::endl;
		::sleep(seconds);
	}
	return 0;
}