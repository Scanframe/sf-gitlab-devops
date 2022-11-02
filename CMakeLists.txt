# Required first entry checking the cmake version.
cmake_minimum_required(VERSION 3.18)

# Make it so our own packages are found.
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_LIST_DIR}/com/cmake")

# Check if this is a cross compile for windows.
if(NOT DEFINED SF_CROSS_WINDOWS)
	# Seems the variable 'CMAKE_SYSTEM_NAME' is no set yet at this time.
	#if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
	set(CMAKE_TOOLCHAIN_FILE "com/cmake/SfToolChainLinux.cmake" #[[CACHE PATH "" FORCE]])
	#endif()
else () #if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
	# Suppressing a lot of Vulkan directory warnings.
	#set(Vulkan_INCLUDE_DIR "/usr/include")
	# Find the Windows cross compiler
	find_program(SF_CROSS_COMPILER "x86_64-w64-mingw32-c++-posix")
	if (NOT EXISTS ${SF_CROSS_COMPILER})
		message(FATAL_ERROR "Windows cross compiler not found. Missing package 'mingw-w64' ?")
		return()
	endif ()
	# Set an environment variable to pass the location of the QT cmake directory to use for the cross-compile.
	set(ENV{SF_QT_VERSION_CMAKE_DIR} "$ENV{HOME}/lib/QtWin/6.4.0/mingw_64/lib/cmake")
	# Set the toolchain for the cross compiler for Windows.
	set(CMAKE_TOOLCHAIN_FILE "com/cmake/SfToolChainCrossWindows.cmake")
endif ()

# Set the global project name.
project("qt-concepts"
	VERSION 0.1.0
	DESCRIPTION "Scanframe Modular Application"
	HOMEPAGE_URL "https://git.scanframe.com/shared/qt-concepts"
	)

# Sentry for builds not working anyway.
if (NOT CMAKE_SYSTEM_NAME STREQUAL "$ENV{SF_TARGET_SYSTEM}" AND NOT DEFINED SF_CROSS_WINDOWS)
	message(NOTICE "-- Target system is '$ENV{SF_TARGET_SYSTEM}' when on '${CMAKE_SYSTEM_NAME}' so bailing out here.")
	return()
endif ()

# Enable test builds from the root file by default for now.
# So the test targets are listed and can be executed.
if (WIN32)
	# Disabled for Windows for now since MingW linker takes minutes to link Catch2 archive.
	#set(SF_BUILD_TESTING OFF)
	set(SF_BUILD_TESTING ON)
else ()
	set(SF_BUILD_TESTING ON)
endif ()

# Enables including Qt libraries when building (libraries).
set(SF_BUILD_QT ON)
#set(SF_BUILD_QT OFF)

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
