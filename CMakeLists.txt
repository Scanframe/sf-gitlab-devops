# set minimum cmake version
cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

# Check if this is a cross compile for windows.
if(NOT DEFINED SF_CROSS_WINDOWS)
	# Seems the variable 'CMAKE_SYSTEM_NAME' is no set yet at this time.
	#if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
	set(CMAKE_TOOLCHAIN_FILE "cmake/SfToolChainLinux.cmake" #[[CACHE PATH "" FORCE]])
	#endif()
else () #if (CMAKE_SYSTEM_NAME STREQUAL "Linux")
	# Suppressing a lot of Vulkan directory warnings.
	#set(Vulkan_INCLUDE_DIR "/usr/include")
	# Find the Windows cross compiler
	find_program(SF_CROSS_COMPILER "x86_64-w64-mingw32-c++-posix")
	if (NOT EXISTS ${SF_CROSS_COMPILER})
		message("Windows cross compiler not found.")
		return()
	endif ()
	# Set an environment variable to pass the location of the QT cmake directory to use for the cross-compile.
	set(ENV{SF_QT_VERSION_CMAKE_DIR} "$ENV{HOME}/lib/QtWin/6.4.0/mingw_64/lib/cmake")
	# Set the toolchain for the cross compiler for Windows.
	set(CMAKE_TOOLCHAIN_FILE "cmake/SfToolChainCrossWindows.cmake")
endif ()

# project name and language
project(HelloWorld LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_EXTENSIONS ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(GNUInstallDirs)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})

#add_compile_definitions(_GLIBCXX_HAS_GTHREADS)
#add_compile_options(-pthread -lpthread -std=c++0x)

# define executable and its source file
add_executable(HelloWorld main.cpp)

target_link_libraries(${PROJECT_NAME} PRIVATE pthread)

