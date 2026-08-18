# Required first entry checking the cmake version.
cmake_minimum_required(VERSION 3.29)

# Set the project name which is also used as the target name.
project("hello-lib"
	DESCRIPTION "Hello shared library"
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
endif ()


# //! [switch]
# Switch between static and dynamic library build.
if (TRUE)
	# Add shared library target and also sets the dynamic library version.
	Sf_AddTarget("${PROJECT_NAME}" SHARED FLAGS pack VERSION EXIF SUFFIX COVERAGE)
	# Add target compile definitions.
	target_compile_definitions(${PROJECT_NAME} PRIVATE
		# Tell the code the 'hello-lib' library is used as dynamic library. (So imports needed)
		_HWL_PKG
		## The 'DEBUG_LEVEL' controls the debug output macro's.
		_DEBUG_LEVEL=1
		# When enabled the 'target.h' file enables reporting of the current target being build using 'pragma message'.
		#REPORT_TARGET
	)
else ()
	Sf_AddTarget("${PROJECT_NAME}" STATIC COVERAGE)
	# Add target compile definitions.
	target_compile_definitions(${PROJECT_NAME} PRIVATE
		## The 'DEBUG_LEVEL' controls the debug output macro's.
		_DEBUG_LEVEL=1
		# When enabled the 'target.h' file enables reporting of the current target being build using 'pragma message'.
		#REPORT_TARGET
		PUBLIC
		# Tell the code the 'hello-lib' library is used as an archive. (So no imports or exports)
		_HWL_ARC
	)
endif ()
# //! [switch]

# Add the library alias.
add_library(Sf::Hello ALIAS "${PROJECT_NAME}")

# Add the source files to the target.
target_sources(${PROJECT_NAME} PRIVATE
	inc/hwl/target.h
	inc/hwl/global.h
	inc/hwl/hello.h
	src/hello.cpp
)

# Set the include directories for this target.
target_include_directories(${PROJECT_NAME}
	# Make users use a directory prefix to prevent collisions in file-naming.
	INTERFACE "inc"
	# Privately no need for a prefix.
	PRIVATE "inc/hwl"
)



