#include <gtest/gtest.h>
#include <unistd.h>

int main(int argc, char* argv[])
{
	::testing::InitGoogleTest(&argc, argv);
	auto retval = RUN_ALL_TESTS();
	// Delay to observe test order.
	::sleep(1);
	return retval;
}
