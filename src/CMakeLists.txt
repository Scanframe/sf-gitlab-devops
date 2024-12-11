add_subdirectory("gen")
add_subdirectory("hwl")

# When Qt libraries are linked.
if (SF_BUILD_QT)
	add_subdirectory(qt)
endif ()

# Function enable_testing() set the 'BUILD_TESTING' flag.
if (BUILD_TESTING)
	add_subdirectory(tests/google)
	add_subdirectory(tests/catch)
endif ()
