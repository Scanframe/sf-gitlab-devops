#include <catch2/catch_all.hpp>

namespace
{
// Some user variable you want to be able to set from the command line.
int debug_level = 0;
}

int main(int argc, char* argv[])
{
	// Function calling catch command line processor.
	auto func = [&]() -> int
	{
		// There must be exactly one instance
		Catch::Session session;
		// Build a new parser on top of Catch's
		using namespace Catch::Clara;
		auto cli
			// Get Catch's composite command line parser
			= session.cli()
				// bind variable to a new option, with a hint string
				| Opt(debug_level, "level")
				// the option names it will respond to
			["--debug"]
				// description string for the help output
				("Custom option for a debug level.");
		// Now pass the new composite back to Catch, so it uses that
		session.cli(cli);
		// Let Catch (using Clara) parse the command line
		int returnCode = session.applyCommandLine(argc, argv);
		if (returnCode != 0)
		{
			return returnCode;
		}
		else
		{
			auto rv = session.run();
			return rv;
		}
	};
	return func();
}

