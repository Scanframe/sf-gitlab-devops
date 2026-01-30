#include <gtest/gtest.h>
#include <hwl/hello.h>

TEST(Hello, World)
{
	SCOPED_TRACE("World...");
	EXPECT_EQ(getHello(0), "Hello World!");
}

TEST(Hello, Universe)
{
	SCOPED_TRACE("Universe...");
	EXPECT_EQ(getHello(2), "Hello Universe!");
}

TEST(Hello, Environment)
{
	SCOPED_TRACE("Environment...");
	std::stringstream is;
	is << std::string(50, '=') << std::endl;
	is << "Timestamp: " + utcTimeString() << std::endl;
	is << "Qemu Virtualization: " << (isQemu() ? "Yes" : "No") << std::endl;
	is << "Wine Compatibility Layer: " << (isWine() ? "Yes" : "No") << std::endl;
	is << "CPU Architecture: " << getCpuArchitecture() << std::endl;
	is << "Compiler: " << getCompilerVersion() << std::endl;
	is << "Standard: " << getCppStandardVersion() << std::endl;
	is << getHello(0) << std::endl;
	is << getHello(1) << std::endl;
	is << std::string(50, '=') << std::endl;
	std::cout << is.str();
	EXPECT_GT(is.str().length(), 0);
}
