# set minimum cmake versionbold
cmake_minimum_required(VERSION 3.14 FATAL_ERROR)
# Make it so our own packages are found.
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_LIST_DIR}/com/cmake")
# Check if this is a cross compile for windows.
if(NOT DEFINED SF_CROSS_WINDOWS)
	# Seems the variable 'CMAKE_SYSTEM_NAME' is no set yet at this time.
	#if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
	set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/com/cmake/SfToolChainLinux.cmake" #[[CACHE PATH "" FORCE]])
	#endif()
else () #if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
	# Find the Windows cross compiler
	find_program(SF_CROSS_COMPILER "x86_64-w64-mingw32-c++-posix")
	if (NOT EXISTS ${SF_CROSS_COMPILER})
		message("Windows cross compiler not found.")
		return()
	endif ()
	# Set the toolchain for the cross compiler for Windows.
	set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/com/cmake/SfToolChainCrossWindows.cmake")
endif ()

# Set the global project name.
project("DevOps"
	VERSION 0.1.0
	DESCRIPTION "Scanframe DevOps Trial Application"
	HOMEPAGE_URL "https://git.scanframe.com/trial/devops"
	)

# Make sure builds do not wind up in the source directory.
find_package(SfMacros CONFIG REQUIRED)
find_package(SfBuildCheck CONFIG REQUIRED)
find_package(SfCompiler CONFIG REQUIRED)

include(GNUInstallDirs)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})

# Set the 3 CMAKE_xxxxx_OUTPUT_DIRECTORY variables.
_SetOutputDirs()

add_subdirectory(app)
