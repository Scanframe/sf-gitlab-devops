# GitLab DevOps Trial Project/Repository

## Content

<!-- TOC -->
* [GitLab DevOps Trial Project/Repository](#gitlab-devops-trial-projectrepository)
  * [Content](#content)
  * [Introduction](#introduction)
    * [Intended Learning Points](#intended-learning-points)
    * [CMake Steps](#cmake-steps)
  * [C++ Source](#c-source)
    * [Main Application](#main-application)
    * [Unittest](#unittest)
    * [Doxygen Code Manual](#doxygen-code-manual)
<!-- TOC -->

## Introduction

This repository is to test GitLab's pipeline for CI (Continuous Integration) and CD (Continuous Delivery).
This using **GitLab-Runner** on several virtual machines and a Raspberry Pi.
Only compiling to 64-bit code for all platforms.

Runners Tested on and links for downloading:

* [Linux Ubuntu Server](https://ubuntu.com/download/server)
* [Windows](https://developer.microsoft.com/en-us/windows/downloads/virtual-machines/)
* [Armbian](https://www.armbian.com/uefi-arm64/)

The Linux server platform is also capable able to cross compile Windows applications using the `gw` compiler.

### Intended Learning Points

1. [CMake](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html "Link to website.") building Linux GNU and Windows GW projects
   using [CMakePresets.json](CMakePresets.json "Link to file.") file.
2. Auto compile GitLab CI-pipeline using Docker or Shell executor.
3. Build a Debian package after a push on the 'release' branch. (maybe Windows too)

### CMake Steps

CMake uses 2 steps:

1) Configure: Create cmake configuration directory contain make files.
2) Build: Use configuration directory to build the targets.

Additional steps:

3) Test: Use configuration directory to execute the defined unit-tests.
4) Pack: t.b.d.

## C++ Source

### Main Application

The build is a simple `hello-world` application locate in [`./src/gen`](./src/gen).

```c++
#include <iostream>

int main(int argc, char** argv)
{
  std::cout << "Hello, World!" << std::endl;
  return 0;
}
```

### Unittest

To make it more challenging the **Catch2** unit-test library is imported.
The test application sources are located in [`./src/tests`](./src/tests).

```cmake
# FetchContent added in CMake 3.11, downloads during the configure step.
include(FetchContent)
# Import Catch2 library for testing.
FetchContent_Declare(
	Catch2
	GIT_REPOSITORY https://github.com/catchorg/Catch2.git
	GIT_TAG v3.1.1
)
# Adds Catch2::Catch2
FetchContent_MakeAvailable(Catch2)
```

A simple unit test and application is created in [`./src/tests`](./src/tests) directory.
The compile-target is `devops-trial-test`.

```c++
#include <catch2/catch_all.hpp>

TEST_CASE("sf::StringSplit", "[generic][strings]")
{
	using Catch::Matchers::Equals;

	SECTION("Strings")
	{
		std::vector<std::string> sl;
		sl.insert(sl.end(), "Hello");
		sl.insert(sl.end(), "World");
		sl.insert(sl.end(), "3");
		sl.insert(sl.end(), "4.0");
		CHECK(sl == std::vector<std::string>{"Hello", "World", "3", "4.0"});
	}
}
```

### Doxygen Code Manual

The `cmake/SfDoxyGenConfig.cmake` package adds a funtion `Sf_AddManual()` which in its turn adds a manual target.

Look at [Doxygen](https://www.doxygen.nl/) website for the syntax in C++ header comment blocks or Markdown files.

```cmake
# Required first entry checking the cmake version.
cmake_minimum_required(VERSION 3.18)
# Set the global project name.
project("doc")
# Add doxygen project when SfDoxyGen was found.
# On Windows this is only possible when doxygen is installed in Cygwin.
find_package(SfDoxyGen QUIET)
if (SfDoxyGen_FOUND)
	# Get the markdown files in this project directory including the README.md.
	file(GLOB _SourceList RELATIVE "${CMAKE_CURRENT_BINARY_DIR}" "*.md" "../*.md")
	message("${_SourceList}")
	# Get all the header files from the application.
	file(GLOB_RECURSE _SourceListTmp RELATIVE "${CMAKE_CURRENT_BINARY_DIR}" "../app/*.h" "../app/*.md")
	# Remove unwanted header file(s) ending on 'Private.h'.
	list(FILTER _SourcesListTmp EXCLUDE REGEX ".*Private\\.h$")
	# Append the list with headers.
	list(APPEND _SourceList ${_SourceListTmp})
	# Adds the actual manual target.
	Sf_AddManual("${PROJECT_NAME}" "${PROJECT_SOURCE_DIR}" "${PROJECT_SOURCE_DIR}/../bin/man" "${_SourceList}")
endif ()
```
