# Required first entry checking the cmake version.
cmake_minimum_required(VERSION 3.18)
# Set the project name.
project("hello-world"
	DESCRIPTION "Hello world application"
	LANGUAGES CXX
)

# Only when this is the main project.
if (PROJECT_NAME STREQUAL CMAKE_PROJECT_NAME)
	# Make it so our own packages are found
	list(APPEND CMAKE_PREFIX_PATH "../cmake")
	# Make sure builds do not wind up in the source directory.
	find_package(SfBuildCheck CONFIG REQUIRED)
	find_package(SfMacros CONFIG REQUIRED)
	find_package(SfCompiler CONFIG REQUIRED)
	# Set the 3 CMAKE_xxxxx_OUTPUT_DIRECTORY variables.
	Sf_SetOutputDirs("bin")
endif ()

# Set the actual executable target.
Sf_AddExecutable("${PROJECT_NAME}")

#if (NOT WIN32)
#	# Set compiler to use compile for coverage.
#	target_compile_options("${PROJECT_NAME}" PRIVATE -fprofile-arcs -ftest-coverage)
#	# For coverage testing
#	target_link_options("${PROJECT_NAME}" PRIVATE -lgcov --coverage -rdynamic)
#endif ()

# Import the library.
target_link_libraries(${PROJECT_NAME} PRIVATE Sf::Hello)

# Add version resource to the target.
Sf_AddVersionResource("${PROJECT_NAME}")

# Add custom target to report resource stored versions.
Sf_AddExifTarget("${PROJECT_NAME}")

# RC-files only seem to be compiled when building using MingW.
target_sources(${PROJECT_NAME} PRIVATE main.cpp template.h)

# Sets the extension of the generated binary.
Sf_SetTargetSuffix("${PROJECT_NAME}")
