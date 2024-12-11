#include <gtest/gtest.h>
#include <hwl/hello.h>

TEST(Hello, World)
{
	SCOPED_TRACE("World...");
	/*
	EXPECT_EQ(getHello(0), "Hello World!.");
	if (::testing::Test::HasFailure())
		GTEST_SKIP_("Bailing out here...");
	*/
	EXPECT_EQ(getHello(0), "Hello World!");
}

TEST(Hello, Universe)
{
	SCOPED_TRACE("Universe...");
	EXPECT_EQ(getHello(2), "Hello Universe!");
}
