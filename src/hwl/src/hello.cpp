#include "hello.h"

_HWL_FUNC std::string getHello(const std::string& who)
{
	return std::string("Hello ") + who + "!";
}

