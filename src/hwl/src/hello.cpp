#include "hello.h"

_HWL_FUNC std::string getHello(int how)
{
	std::string rv;
	if (how > 0) {
		rv = std::string("Hello Universe!");
	}
	else {
		rv = std::string("Hello World!");
	}
	return rv;
}