# Required first entry checking the cmake version.
cmake_minimum_required(VERSION 3.29)

# Set the global project name.
project("document")

# Add doxygen project when SfDoxygen was found.
find_package(SfDoxygen QUIET)
if (SfDoxygen_FOUND)
	set(_SourceList)
	# Get the markdown files in this directory and the cmake library.
	file(GLOB _Sources RELATIVE "${CMAKE_CURRENT_BINARY_DIR}" "*.md" "${CMAKE_SOURCE_DIR}/cmake/lib/doc/*.md")
	list(APPEND _SourceList ${_Sources})
	# Get all 'doc' named subdirectories in the source tree relative to the binary directory
	# where Doxygen is running from where images are possibly accessed.
	Sf_GetNamedSubdirectories("${CMAKE_SOURCE_DIR}/src" "${CMAKE_CURRENT_BINARY_DIR}" "doc" _ImageDirs)
	foreach (_ImageDir ${_ImageDirs})
		file(GLOB _Sources RELATIVE "${CMAKE_CURRENT_BINARY_DIR}" "${CMAKE_CURRENT_BINARY_DIR}/${_ImageDir}/*.md")
		list(APPEND _SourceList ${_Sources})
	endforeach ()
	# Retrieve all non-test targets from the global project.
	Sf_GetAllTargets(_Targets "${CMAKE_SOURCE_DIR}" "TRUE")
	# Remove all the test targets using its prefix.
	list(FILTER _Targets EXCLUDE REGEX "^${SF_TEST_NAME_PREFIX}.*$")
	# Iterate through all targets to remove.
	foreach (_Target ${_Targets})
		get_target_property(_Type "${_Target}" TYPE)
		# Only use executables and shared libraries.
		if (_Type STREQUAL "EXECUTABLE" OR _Type STREQUAL "SHARED_LIBRARY")
			message(VERBOSE "Document Target (${_Type}): ${_Target}")
		else ()
			list(REMOVE_ITEM APPEND _Targets "${_Target}")
		endif ()
	endforeach ()
	# Get the source files from the the passed document targets.
	Sf_GetSourceFiles(_Sources "${_Targets}" "${CMAKE_CURRENT_BINARY_DIR}")
	# Only add files with the '.h' extension.
	list(FILTER _Sources INCLUDE REGEX ".*\\.h$")
	# Remove unwanted header file(s) ending on 'Private.h'.
	list(FILTER _Sources EXCLUDE REGEX ".*Private\\.h$")
	# Remove unwanted header file(s) ending on '_p.h'.
	list(FILTER _Sources EXCLUDE REGEX ".*_p\\.h$")
	# Add the target found sources to the list.
	list(APPEND _SourceList ${_Sources})
#[[
	# Output a list of sources.
	list(JOIN _SourceList "\n\t" _Files)
	message(NOTICE "Target Files:\n\t${_Files}")
]]
	# Adds the actual manual target and the last 2 optional arguments are awesome theming flag and plantuml version.
	Sf_AddDoxygenDocumentation("${PROJECT_NAME}" "${PROJECT_SOURCE_DIR}" "${_ImageDirs}" "${PROJECT_SOURCE_DIR}/../bin/man" "${_SourceList}" TRUE)
endif ()
