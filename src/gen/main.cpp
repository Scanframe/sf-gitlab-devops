#include <hwl/hello.h>
#include <iostream>

int main(int argc, char** argv)
{
	std::cout << getHello(0) << std::endl;
	std::cout << getHello(1) << std::endl;
	return 0;
}