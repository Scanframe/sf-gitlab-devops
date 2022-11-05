# Required first entry checking the cmake version.
cmake_minimum_required(VERSION 3.18)

# Make it so our own packages are found.
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_LIST_DIR}/com/cmake")

# Package needed for adding function Sf_SetToolChain().
find_package(SfToolChain CONFIG REQUIRED)
# Install tool chain for Linux or Windows.
Sf_SetToolChain()

# Set the global project name.
project("qt-concepts"
	VERSION 0.1.0
	DESCRIPTION "Scanframe DevOps Trial App"
	HOMEPAGE_URL "https://git.scanframe.com/trial/devops.git"
	)

# Sentry for builds not working anyway.
if (NOT CMAKE_SYSTEM_NAME STREQUAL "$ENV{SF_TARGET_SYSTEM}" AND NOT DEFINED SF_CROSS_WINDOWS)
	message(NOTICE "-- Target system is '$ENV{SF_TARGET_SYSTEM}' when on '${CMAKE_SYSTEM_NAME}' so bailing out here.")
	return()
endif ()

# Use faster linker for Windows maybe?
if (WIN32)
	# Adding option '-mwindows' as a linker flag will remove the console.
	set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fuse-ld=bfd")
endif (WIN32)

# Make sure builds do not wind up in the source directory.
find_package(SfMacros CONFIG REQUIRED)
find_package(SfBuildCheck CONFIG REQUIRED)
find_package(SfCompiler CONFIG REQUIRED)

# Set the 3 CMAKE_xxxxx_OUTPUT_DIRECTORY variables.
_SetOutputDirs()

# Add Sub Projects in the right order of dependency.
add_subdirectory(app)
