macro(_check_file_exists file)
	if (NOT EXISTS "${file}")
		message(FATAL_ERROR "The file \"${file}\" does not exist. Check order of dependent add_subdirectory(...).")
		#message(WARNING "The file \"${file}\" does not exist.")
	endif ()
endmacro()

macro(_populate_target_props TargetName Configuration LIB_LOCATION IMPLIB_LOCATION)
	# Seems a relative directory is not working using REALPATH.
	get_filename_component(imported_location "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${LIB_LOCATION}" REALPATH)
	# When this fails on a library which is part of the project the order of add_subdirectory(...) is incorrect.
	_check_file_exists(${imported_location})
	set_target_properties(${TargetName} PROPERTIES "IMPORTED_LOCATION_${Configuration}" ${imported_location})
	if (NOT IMPLIB_LOCATION STREQUAL "")
		set(imported_implib "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${IMPLIB_LOCATION}")
		_check_file_exists(${imported_implib})
		set_target_properties(${TargetName} PROPERTIES "IMPORTED_IMPLIB_${Configuration}" ${imported_implib})
	endif ()
endmacro()

macro(_add_shared_library TargetName)
	# When the target exists ignore it.
	if (TARGET ${TargetName})
		#message(STATUS "Not adding (${PROJECT_NAME}) library ${TargetName} already part of build and ignored.")
	else ()
		message(STATUS "Adding (${PROJECT_NAME}) library: ${TargetName}")
		add_library(${TargetName} SHARED IMPORTED)
		if (WIN32)
			_populate_target_props(${TargetName} DEBUG "lib${TargetName}.dll" "lib${TargetName}.dll.a")
		else ()
			_populate_target_props(${TargetName} DEBUG "lib${TargetName}.so" "")
		endif ()
	endif ()
endmacro()

# FetchContent_MakeAvailable was not added until CMake 3.14; use our shim
if (${CMAKE_VERSION} VERSION_LESS 3.14)
	macro(FetchContent_MakeAvailable NAME)
		FetchContent_GetProperties(${NAME})
		if (NOT ${NAME}_POPULATED)
			FetchContent_Populate(${NAME})
			add_subdirectory(${${NAME}_SOURCE_DIR} ${${NAME}_BINARY_DIR})
		endif ()
	endmacro()
endif ()

##
## Locates a top 'bin' directory containing the file named '__output__'.
## Sets the '_OutputDir' variable when found.
##
function(_LocateOutputDir)
	# InitializeBase return value variable.
	set(_OutputDir "" PARENT_SCOPE)
	if (WIN32)
		set(_BinDir "binwin")
	else ()
		set(_BinDir "bin")
	endif ()
	# Loop from 9 to 4 with step 1.
	foreach (_Counter RANGE 0 4 1)
		# Form the string to the parent directory.
		string(REPEAT "/.." ${_Counter} _Sub)
		# Get the real filepath which is looked for.
		get_filename_component(_Dir "${CMAKE_CURRENT_LIST_DIR}${_Sub}/${_BinDir}" REALPATH)
		# When the file inside is found Set the output directories and break the loop.
		if (EXISTS "${_Dir}/__output__")
			set(_OutputDir "${_Dir}" PARENT_SCOPE)
			# Stop here the directory has been found.
			break()
		endif ()
	endforeach ()
endfunction()

##
## Sets the 3 CMAKE_??????_OUTPUT_DIRECTORY variables when an output directory has been found.
## Only when the top project is the current project.
## Fatal error when not able to do so.
##
function(_SetOutputDirs)
	if (CMAKE_PROJECT_NAME STREQUAL "${PROJECT_NAME}")
		_LocateOutputDir()
		# Check if the directory was found.
		if (_OutputDir STREQUAL "")
			message(FATAL_ERROR "_SetOutputDirs() (${PROJECT_NAME}): Output directory could not be located")
		else ()
			message(STATUS "Output Directory (${PROJECT_NAME}): ${_OutputDir}")
			# Set the directories accordingly in the parents scope.
			set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${_OutputDir}" PARENT_SCOPE)
			set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${_OutputDir}" PARENT_SCOPE)
			set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${_OutputDir}" PARENT_SCOPE)
		endif ()
	endif ()
endfunction()

##
## Sets the extension of the created executable binary.
##
function(_SetBinarySuffix)
	foreach (_var IN LISTS ARGN)
		if (WIN32)
			set_target_properties(${_var} PROPERTIES OUTPUT_NAME "${_var}" SUFFIX ".exe")
		else ()
			set_target_properties(${_var} PROPERTIES OUTPUT_NAME "${_var}" SUFFIX ".bin")
		endif ()
	endforeach ()
endfunction()

##
## Sets the extension of the created dynamic library.
##
function(_SetDynamicLibrarySuffix)
	foreach (_var IN LISTS ARGN)
		if (WIN32)
			set_target_properties(${_var} PROPERTIES OUTPUT_NAME "${_var}" SUFFIX ".dll")
		else ()
			set_target_properties(${_var} PROPERTIES OUTPUT_NAME "${_var}" SUFFIX ".so")
		endif ()
	endforeach ()
endfunction()

##
## Gets all sub directories which match the passed regex.
##
function(_GetSubDirs VarOut Directory MatchStr)
	file(GLOB _Children RELATIVE "${Directory}" "${Directory}/*")
	set(_List "")
	foreach (_Child ${_Children})
		if (IS_DIRECTORY "${Directory}/${_Child}")
			if ("${_Child}" MATCHES "${MatchStr}")
				list(APPEND _List "${_Child}")
			endif ()
		endif ()
	endforeach ()
	set(${VarOut} ${_List} PARENT_SCOPE)
endfunction()

# Gets the Qt directory located a defined position for Linux and Windows.
#
function(_GetQtVersionDirectory VarOut)
	set(_QtDir "")
	if (DEFINED SF_CROSS_WINDOWS)
		get_filename_component(_QtDir "$ENV{HOME}/lib/QtWin" REALPATH)
	elseif ("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
		set(_QtDir "$ENV{HOME}/lib/Qt")
	elseif ("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
		set(_QtDir "P:/Qt")
	endif ()
	_GetSubDirs(_SubDirs "${_QtDir}" "^[0-9]+.[0-9]+.[0-9]+$")
	list(LENGTH _SubDirs _Len)
	if (NOT ${_Len})
		message(FATAL_ERROR "Failed to get Qt library directory in '${_QtDir}'!")
	endif ()
	list(SORT _SubDirs COMPARE NATURAL ORDER DESCENDING)
	list(GET _SubDirs 0 _QtVerDir)
	set(${VarOut} "${_QtDir}/${_QtVerDir}" PARENT_SCOPE)
endfunction()

# Works around the cmake bug with sources and binary directory on a shared drive.
#
function(_WorkAroundSmbShare)
	# Check if the environment var exists telling us that cmake is running on Windows.
	if (EXISTS "$ENV{ComSpec}")
		set(_Command "PowerShell.exe")
		string(REPLACE "/" "\\" _Script "${SfMacros_DIR}/SmbShareWorkAround.ps1")
		execute_process(COMMAND "${_Command}" "${_Script}" "${CMAKE_BINARY_DIR}" OUTPUT_VARIABLE _Result RESULT_VARIABLE _ExitCode)
	endif ()
	#message(STATUS ${_Result})
	# Validate the exit code.
	if (_ExitCode GREATER "0")
		message(FATAL_ERROR "Failed execution of script: ${_Script}")
	endif ()
	set(${VarOut} "${_Result}" PARENT_SCOPE)
endfunction()

# Works around for Catch2 which does not allow us to set the compiler switch (-fvisibility=hidden)
#
function(_SetTargetDefaultCompileOptions)
	#message(STATUS "Setting target '${PROJECT_NAME}' compiler option -fvisibility=hidden")
	target_compile_options("${PROJECT_NAME}" PRIVATE "-fvisibility=hidden")
endfunction()
