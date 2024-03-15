# Required first entry checking the cmake version.
cmake_minimum_required(VERSION 3.18)

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
	# Set the 3 CMAKE_xxxxx_OUTPUT_DIRECTORY variables.
	Sf_SetOutputDirs("bin")
endif ()

# Add shared library target and also sets the dynamic library version.
Sf_AddSharedLibrary("${PROJECT_NAME}")

# Adds the compiler and linker options for coverage.
Sf_AddTargetForCoverage("${PROJECT_NAME}")

# Add the library alias.
add_library(Sf::Hello ALIAS "${PROJECT_NAME}")

# Add the source files to the target.
target_sources(${PROJECT_NAME} PRIVATE
	inc/hwl/target.h
	inc/hwl/global.h
	inc/hwl/hello.h
	src/hello.cpp
)

# Add target compile definitions.
target_compile_definitions(${PROJECT_NAME} PRIVATE
	# Tell the compiled code a dynamic library (DL) is being build.
	TARGET_DYNAMIC_LIB
	# Tell the compiled code a dynamic library (DL) is being build.
	QDESIGNER_EXPORT_WIDGETS
	# Tell the code the 'sf-misc' library is used as an archive. (So no imports or exports)
	#_HWL_ARC
	# Tell the code the 'misc' library is used as dynamic library. (So imports needed)
	_HWL_PKG
	# The 'DEBUG_LEVEL' controls the debug output macro's.
	_DEBUG_LEVEL=1
	# When enabled the 'target.h' file enables reporting of the current target being build using 'pragma message'.
	#REPORT_TARGET
)

#set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 23)

# When enabled the 'target.h' file enables reporting of the current target being build using 'pragma message'.
#target_compile_definitions(${PROJECT_NAME} PRIVATE REPORT_TARGET)

# Set the include directories for this target.
target_include_directories(${PROJECT_NAME}
	# Make users use a directory prefix to prevent collisions in file-naming.
	INTERFACE "inc"
	# Privately no need for a prefix.
	PRIVATE "inc/hwl"
)
