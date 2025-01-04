# Required first entry checking the cmake version.
cmake_minimum_required(VERSION 3.25)

# Make it so our own packages are found and also the ones in the sub-module library.
list(APPEND CMAKE_PREFIX_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake" "${CMAKE_CURRENT_LIST_DIR}/cmake/lib")

# Package needed for Sf_GetGitTagVersion().
find_package(SfBase CONFIG REQUIRED)
# Package setting the correct tool chain according the host and SF_COMPILER.
find_package(SfToolChain CONFIG REQUIRED)

# Get the Git versions from the repository of this files directory.
Sf_GetGitTagVersion(_Versions "${CMAKE_CURRENT_LIST_DIR}")
# Report the found Git tag found version.
Sf_ReportGitTagVersion("${_Versions}")
# Split the list into separate values.
list(GET _Versions 0 SF_GIT_TAG_VERSION)
list(GET _Versions 1 SF_GIT_TAG_RC)
list(GET _Versions 2 SF_GIT_TAG_COMMITS)

# Set the global project name.
project("devops-shared"
	VERSION "${SF_GIT_TAG_VERSION}"
	DESCRIPTION "Scanframe DevOps Trial App"
	HOMEPAGE_URL "https://git.scanframe.com/shared/devops.git"
	LANGUAGES C CXX
)

# Check if the cmake is available and include it to maybe overrule CMakePresets.json cache variables.
if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/user.cmake")
	include("${CMAKE_CURRENT_LIST_DIR}/user.cmake")
endif ()

# Add top target for displaying info on the compiled target where Sf_AddExifTarget() is called on.
add_custom_target("exif" ALL)

# Use faster linker for Windows maybe?
if (WIN32)
	# Adding option '-mwindows' as a linker flag will remove the console.
	set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fuse-ld=bfd")
	# Prevent error when configuring for cross compile for Windows in Linux.
	if (CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
		# Make some cmake files happy so they do report "Not found".
		set(Vulkan_INCLUDE_DIR "/tmp")
	endif ()
	# Needed to be able to set debug breaks using MSVC
	set(CMAKE_C_FLAGS_DEBUG "-D_DEBUG")
endif ()

# Make sure builds do not wind up in the source directory.
find_package(SfMacros CONFIG REQUIRED)
find_package(SfBuildCheck CONFIG REQUIRED)
if (SF_BUILD_QT)
	# Install/fetch the Qt Libraries when ENV{QT_VER_DIR} is not set.
	find_package(SfQtLibrary 6.7.2 CONFIG REQUIRED)
endif ()

# Set the C++ standard to 20 for all projects which is required for the SfCompiler package.
set(CMAKE_CXX_STANDARD 20)
find_package(SfCompiler CONFIG REQUIRED)

# Set the 3 CMAKE_?????_OUTPUT_DIRECTORY variables.
Sf_SetOutputDirs("bin")

if (SF_BUILD_TESTING)
	# Prevents Catch2 from adding targets.
	set_property(GLOBAL PROPERTY CTEST_TARGETS_ADDED 1)
	# Enable the tests added with add_test.
	enable_testing()
	# Include CDash dashboard testing module and it sets the BUILD_TESTING to 'ON'.
	include(CTest)
endif ()

# Configure the rpath to make the Linux compiled instances find
# libraries without using the LD_LIBRARY_PATH.
if (SF_BUILD_QT)
	# Need to have the Qt directory in the RPATH.
	Sf_GetQtVersionDirectory(_QtVerDir)
	if (_QtVerDir STREQUAL "")
		message(SEND_ERROR "Qt version directory not found or set!")
	else ()
		Sf_SetRPath("\${ORIGIN}:\${ORIGIN}/lib:${_QtVerDir}/gcc_64/lib")
	endif ()
else ()
	Sf_SetRPath("\${ORIGIN}:\${ORIGIN}/lib")
endif ()

# Satisfy cmake to prevent warning.
if (CMAKE_VERBOSE_MAKEFILE)
	message(STATUS "Verbosity enabled.")
endif ()

# Clear the tests from previous by passing an empty string.
Sf_AddAsCoverageTest("")

# Add Sub Projects in the right order of dependencies.
add_subdirectory(src)
# Add Doxygen document project.
if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/doc")
	add_subdirectory(doc)
endif ()

# Coverage report generator in the form af a test is added.
# Only when testing is enabled and the build type is 'Coverage'.
# This must be the last test added since it relies on previous the calls
# to 'Sf_AddAsCoverageTest()'.
Sf_AddTestCoverageReport("coverage-report" "${CMAKE_CURRENT_LIST_DIR}/bin/gcov" "--html flat --json --cleanup --verbose" "src")

# Add package build config when not building coverage.
if (NOT CMAKE_BUILD_TYPE STREQUAL "Coverage")
	if (EXISTS "${CMAKE_CURRENT_LIST_DIR}/cmake/cpack/CPackConfig.cmake")
		include(cmake/cpack/CPackConfig.cmake)
	endif ()
endif ()
