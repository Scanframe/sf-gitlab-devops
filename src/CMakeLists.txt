add_subdirectory("cli")
add_subdirectory("hwl")

# When Qt libraries are linked.
if (SF_BUILD_QT)
	add_subdirectory(qt)
endif ()

# Function enable_testing() set the 'BUILD_TESTING' flag.
if (SF_BUILD_TESTING)
	add_subdirectory(tests/catch)
	# Somehow Windows MinGW compiler causes errors: undefined reference to '__imp__Exit' and to '__imp_quick_exit'.
	if (NOT SF_COMPILER STREQUAL "mingw")
		add_subdirectory(tests/google)
	endif ()
endif ()

# Add a files as examples.
Sf_AddExamples("hwl/CMakeLists.txt" "hwl")
Sf_AddExamples("cli/CMakeLists.txt" "hwl/gen")
Sf_AddExamples("qt/CMakeLists.txt" "hwl/qt")
