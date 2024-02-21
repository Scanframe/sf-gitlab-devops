#include <hwl/hello.h>
#include <iostream>

int main(int argc, char** argv)
{
	std::cout << getHello("World") << std::endl;
	return 0;
}