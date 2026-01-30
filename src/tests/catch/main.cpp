#include <catch2/catch_all.hpp>
#include <iostream>
#if WIN32
	#include <windows.h>
	#include <synchapi.h>
#else
	#include <unistd.h>
#endif

namespace
{
// Some user variable you want to be able to set from the command line.
int debug_level = 0;
}// namespace

int main(int argc, char* argv[])
{
	// Function calling catch command line processor.
	auto func = [&]() -> int {
		// There must be exactly one instance
		Catch::Session session;
		// Build a new parser on top of Catch's
		using namespace Catch::Clara;
		auto cli
			// Get Catch's composite command line parser
			= session.cli()
			// Bind the variable to a new option, with a hint string
			| Opt(debug_level, "level")
					// the option names it will respond to
					["--debug"]
			// description string for the help output
			("Custom option for a debug level.");
		// Now pass the new composite back to Catch, so it uses that
		session.cli(cli);
		// Let Catch (using Clara) parse the command line
		int exit_code = session.applyCommandLine(argc, argv);
		if (exit_code == 0)
			exit_code = session.run();
		//
		std::clog << "Exitcode: " << exit_code << std::endl;
		return exit_code;
	};
	// Delay to observe test order.
#if WIN32
	::Sleep(1000);
#else
	::sleep(1);
#endif
	return func();
}
