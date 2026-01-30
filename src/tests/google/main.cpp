#include <gtest/gtest.h>
#if WIN32
	#include <windows.h>
	#include <synchapi.h>
#else
	#include <unistd.h>
#endif

int main(int argc, char* argv[])
{
	::testing::InitGoogleTest(&argc, argv);
	auto retval = RUN_ALL_TESTS();
	// Delay to observe test order.
#if WIN32
	::Sleep(1000);
#else
	::sleep(1);
#endif
	return retval;
}
