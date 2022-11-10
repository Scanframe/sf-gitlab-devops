# FetchContent_MakeAvailable was not added until CMake 3.14; use our shim
#
if (${CMAKE_VERSION} VERSION_LESS 3.14)
	macro(FetchContent_MakeAvailable NAME)
		FetchContent_GetProperties(${NAME})
		if (NOT ${NAME}_POPULATED)
			FetchContent_Populate(${NAME})
			add_subdirectory(${${NAME}_SOURCE_DIR} ${${NAME}_BINARY_DIR})
		endif ()
	endmacro()
endif ()

# Checks if the required passed file exists.
# When not a useful fatal message is produced.
#
macro(Sf_CheckFileExists _File)
	if (NOT EXISTS "${_File}")
		message(FATAL_ERROR "The file \"${_File}\" does not exist. Check order of dependent add_subdirectory(...).")
	endif ()
endmacro()

# Works around for Catch2 which does not allow us to set the compiler switch (-fvisibility=hidden)
#
function(Sf_SetTargetDefaultCompileOptions _Target)
	#message(STATUS "Setting target '${_Target}' compiler option -fvisibility=hidden")
	target_compile_options("${_Target}" PRIVATE "-fvisibility=hidden")
endfunction()

# Gets the version from the Git repository using 'PROJECT_SOURCE_DIR' variable.
# When not found it returns "${_VarOut}-NOTFOUND"
#
function(Sf_GetGitTagVersion _VarOut _SrcDir)
	# Initialize return value.
	set(${_VarOut} "${_VarOut}-NOTFOUND" PARENT_SCOPE)
	# Get git binary location for execution.
	find_program(_GitExe "git")
	if (_Compiler STREQUAL "_GitExe-NOTFOUND")
		message(FATAL_ERROR "Git program not found!")
	endif ()
	if ("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Windows")
		execute_process(COMMAND bash -c "\"${_GitExe}\" describe --tags --dirty --match \"v*\""
			# Use the current project directory to find.
			WORKING_DIRECTORY "${_SrcDir}"
			OUTPUT_VARIABLE _Version
			RESULT_VARIABLE _ExitCode
			ERROR_VARIABLE _ErrorText
			OUTPUT_STRIP_TRAILING_WHITESPACE)
	else ()
		execute_process(COMMAND "${_GitExe}" describe --tags --dirty --match "v*"
			# Use the current project directory to find.
			WORKING_DIRECTORY "${_SrcDir}"
			OUTPUT_VARIABLE _Version
			RESULT_VARIABLE _ExitCode
			ERROR_VARIABLE _ErrorText
			OUTPUT_STRIP_TRAILING_WHITESPACE)
	endif ()
	# Check the exist code for an error.
	if (_ExitCode GREATER 0)
		message(STATUS "Repository '${_SrcDir}' not having a version tag like 'v0.0.0' ?!")
		message(VERBOSE "${_GitExe} describe --tags --dirty --match v* ... Exited with (${_ExitCode}).")
		message(VERBOSE "${_ErrorText}")
		# Set an initial version to allow continuing.
		set(_Version "v0.0.0")
	endif ()
	set(_RegEx "^v([0-9]+\\.[0-9]+\\.[0-9]+)")
	string(REGEX MATCH "${_RegEx}" _Dummy_ "${_Version}")
	if ("${CMAKE_MATCH_1}" STREQUAL "")
		message(FATAL_ERROR "Git returned tag '${_Version}' does not match regex '${_RegEx}' !")
	else ()
		set(${_VarOut} "${CMAKE_MATCH_1}" PARENT_SCOPE)
	endif ()
endfunction()

# Sets the passed target version properties according the version of the sub project
# or by default use the tag in vN.N.N format
#
function(Sf_SetTargetVersion _Target)
	# Get the type of the target.
	get_target_property(_Type ${_Target} TYPE)
	# Get version. from Git when possible.
	Sf_GetGitTagVersion(_Version "${CMAKE_CURRENT_SOURCE_DIR}")
	# Check if the git version was found.
	if (NOT "${_Version}" STREQUAL "_Version-NOTFOUND")
		message(VERBOSE "${CMAKE_CURRENT_FUNCTION}(${_Target}) using Git version (${_Version})")
		# Check the target version is set.
	elseif (NOT "${CMAKE_PROJECT_VERSION}" STREQUAL "")
		set(_Version "${${_Target}_VERSION}")
		message(VERBOSE "${CMAKE_CURRENT_FUNCTION}(${_Target}) using Sub-Project(${_Target}) version (${_Version})")
		# Check the project version is set.
	elseif (NOT "${CMAKE_PROJECT_VERSION}" STREQUAL "")
		# Try using the main project version
		set(_Version "${CMAKE_PROJECT_VERSION}")
		message(VERBOSE "${CMAKE_CURRENT_FUNCTION}(${_Target}) using Main-Project version (${_Version})")
	else ()
		# Clear the version variable.
		set(_Version "")
	endif ()
	# When the version string was resolved apply the properties.
	if (NOT "${_Version}" STREQUAL "")
		# Only in Linux SOVERSION makes sense.
		if ("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
			# Do not want symlink like SO-file.
			if (_Type STREQUAL "EXECUTABLE")
				set_target_properties("${_Target}" PROPERTIES SOVERSION "${_Version}")
			else ()
				# Set the target version properties for Linux.
				set_target_properties("${_Target}" PROPERTIES VERSION "${_Version}" SOVERSION "${_Version}")
			endif ()
		else ()
			# Set the target version properties for Windows.
			set_target_properties("${_Target}" PROPERTIES SOVERSION "${_Version}")
		endif ()
	endif ()
endfunction()

# Adds an executable application target and also sets the default compile options.
#
macro(Sf_AddExecutable _Target)
	# Add the executable.
	add_executable("${_Target}")
	# Set the default compiler options for our own code only.
	Sf_SetTargetDefaultCompileOptions("${_Target}")
	# Set the version of this target.
	Sf_SetTargetVersion("${_Target}")
endmacro()

# Adds a dynamic library target and sets the version number on it as well.
macro(Sf_AddSharedLibrary _Target)
	# Add the library to create.
	add_library("${_Target}" SHARED)
	# Set the default compiler options for our own code only.
	Sf_SetTargetDefaultCompileOptions("${_Target}")
	# Set the version of this target.
	Sf_SetTargetVersion("${_Target}")
endmacro()

# Adds an exif custom target for reporting the resource stored versions.
#
macro(Sf_AddExifTarget _Target)
	# Only possible when compiling in Linux.
	#if ("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Linux")
	# Add "exif-<target>" custom target when main 'exif' target exist.
	if (TARGET "exif")
		if ("${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Windows")
			add_custom_target("exif-${_Target}" ALL
				COMMAND bash -c "exiftool '$<TARGET_FILE:${_Target}>' | egrep -i '(File Name|Product Version|File Version|File Type|CPU Type)\\s*:' | sed 's/\\s*:/:/g'"
				WORKING_DIRECTORY "$<TARGET_FILE_DIR:${_Target}>"
				DEPENDS "$<TARGET_FILE:${_Target}>"
				COMMENT "Reading resource information from '$<TARGET_DIR:${_Target}>'."
				VERBATIM
				)
		else ()
			add_custom_target("exif-${_Target}" ALL
				COMMAND exiftool "$<TARGET_FILE:${_Target}>" | egrep -i "^(File Name|Product Version|File Version|File Type|CPU Type)\\s*:" | sed "s/\\s*:/:/g"
				WORKING_DIRECTORY "$<TARGET_FILE_DIR:${_Target}>"
				DEPENDS "$<TARGET_FILE:${_Target}>"
				COMMENT "Reading resource information from '$<TARGET_DIR:${_Target}>'."
				VERBATIM
				)
		endif ()
		add_dependencies("exif" "exif-${_Target}")
	endif ()
	#endif ()
endmacro()

# Add version resource 'resource.rc' to be compiled by passed target.
#
function(Sf_AddVersionResource _Target)
	get_target_property(_Version "${_Target}" SOVERSION)
	get_target_property(_OutputName "${_Target}" OUTPUT_NAME)
	get_target_property(_OutputSuffix "${_Target}" SUFFIX)
	string(REPLACE "." "," RC_WindowsFileVersion "${_Version},0")
	set(RC_WindowsProductVersion "${RC_WindowsFileVersion}")
	set(RC_FileVersion "${_Version}")
	set(RC_ProductVersion "${RC_FileVersion}")
	set(RC_FileDescription "${CMAKE_PROJECT_DESCRIPTION}")
	set(RC_ProductName "${CMAKE_PROJECT_DESCRIPTION}")
	set(RC_OriginalFilename "${_OutputName}${_OutputSuffix}")
	set(RC_InternalName "${_OutputName}${_OutputSuffix}")
	string(TIMESTAMP RC_BuildDateTime "%Y-%m-%dT%H:%M:%SZ" UTC)
	if (NOT DEFINED SF_COMPANY_NAME)
		set(RC_CompanyName "Unknown")
	else ()
		set(RC_CompanyName "${SF_COMPANY_NAME}")
	endif ()
	set(_HomepageUrl "${HOMEPAGE_URL}")
	set(RC_Comments "Build on '${CMAKE_HOST_SYSTEM_NAME} ${CMAKE_HOST_SYSTEM_PROCESSOR} ${CMAKE_HOST_SYSTEM_VERSION}' (${CMAKE_PROJECT_HOMEPAGE_URL})")
	# Set input and output files for the generation of the actual config file.
	set(_FileIn "${SfBase_DIR}/tpl/res/version.rc")
	# MAke sure the file exists.
	Sf_CheckFileExists("${_FileIn}")
	# Assemble the file out.
	set(_FileOut "${CMAKE_CURRENT_BINARY_DIR}/version.rc")
	# Generate the configure the file for doxygen.
	configure_file("${_FileIn}" "${_FileOut}" @ONLY NEWLINE_STYLE LF)
	#
	target_sources("${_Target}" PRIVATE "${_FileOut}")
endfunction()
