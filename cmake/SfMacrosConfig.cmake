##
## This package cannot be used with find_package() before the first  project is set.
##

find_package(SfBase CONFIG REQUIRED)

macro(Sf_PopulateTargetProperties TargetName _Configuration _LibLocation _ImplibLocation)
	# Seems a relative directory is not working using REALPATH.
	get_filename_component(_imported_location "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${_LibLocation}" REALPATH)
	# When this fails on a library which is part of the project the order of add_subdirectory(...) is incorrect.
	Sf_CheckFileExists(${_imported_location})
	set_target_properties(${TargetName} PROPERTIES "IMPORTED_LOCATION_${_Configuration}" ${_imported_location})
	if (NOT _ImplibLocation STREQUAL "")
		set(_imported_implib "${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${_ImplibLocation}")
		Sf_CheckFileExists(${_imported_implib})
		set_target_properties(${TargetName} PROPERTIES "IMPORTED_IMPLIB_${_Configuration}" ${_imported_implib})
	endif ()
endmacro()

macro(Sf_AddImportLibrary TargetName)
	# When the target exists ignore it.
	if (TARGET ${TargetName})
		#message(STATUS "Not adding (${PROJECT_NAME}) library ${TargetName} already part of build and ignored.")
	else ()
		message(STATUS "Adding (${PROJECT_NAME}) library: ${TargetName}")
		add_library(${TargetName} SHARED IMPORTED)
		if (WIN32)
			Sf_PopulateTargetProperties(${TargetName} DEBUG "lib${TargetName}.dll" "lib${TargetName}.dll.a")
		else ()
			Sf_PopulateTargetProperties(${TargetName} DEBUG "lib${TargetName}.so" "")
		endif ()
	endif ()
endmacro()

##
## Locates a top 'bin' directory containing the file named '__output__'.
## Sets the '_OutputDir' variable when found.
##
function(Sf_LocateOutputDir)
	# InitializeBase return value variable.
	set(_OutputDir "" PARENT_SCOPE)
	# Look into this sub directory.
	set(_BinDir "bin")
	# Loop from 9 to 4 with step 1.
	foreach (_Counter RANGE 0 4 1)
		# Form the string to the parent directory.
		string(REPEAT "/.." ${_Counter} _Sub)
		# Get the real filepath which is looked for.
		get_filename_component(_Dir "${CMAKE_CURRENT_LIST_DIR}${_Sub}/${_BinDir}" REALPATH)
		# When the file inside is found Set the output directories and break the loop.
		if (EXISTS "${_Dir}/__output__")
			set(_Sep "/")
			#[[
						if ("$ENV{CI_SERVER}" STREQUAL "yes")
							set(_Sep "-")
						endif()
			]]
			# Make a distinction based on targeted system.
			if (WIN32)
				set(_OutputDir "${_Dir}${_Sep}win64" PARENT_SCOPE)
			else ()
				set(_OutputDir "${_Dir}${_Sep}lnx64" PARENT_SCOPE)
			endif ()
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
function(Sf_SetOutputDirs)
	if (CMAKE_PROJECT_NAME STREQUAL "${PROJECT_NAME}")
		Sf_LocateOutputDir()
		# Check if the directory was found.
		if (_OutputDir STREQUAL "")
			message(FATAL_ERROR "Sf_SetOutputDirs() (${PROJECT_NAME}): Output directory could not be located")
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
function(Sf_SetBinarySuffix)
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
function(Sf_SetDynamicLibrarySuffix)
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
function(Sf_GetSubDirectories VarOut Directory MatchStr)
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
function(Sf_GetQtVersionDirectory _VarOut)
	set(_QtDir "")
	if (NOT "${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "${CMAKE_SYSTEM_NAME}" AND "${CMAKE_HOST_SYSTEM_NAME}" STREQUAL "Linux")
		get_filename_component(_QtDir "$ENV{HOME}/lib/QtWin" REALPATH)
	elseif ("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
		set(_QtDir "$ENV{HOME}/lib/Qt")
	elseif ("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
		set(_QtDir "")
		# Iterate through all the most logical drives. (Drive P is preferred so put in front.)
		set(_Drives P C D E F G H I J K L M N O P Q R S T U V W X Y Z)
		foreach (_Drive ${_Drives})
			if (EXISTS "${_Drive}:/Qt/")
				set(_QtDir "${_Drive}:/Qt")
				message(STATUS "Qt root library found in '${_QtDir}'!")
				break()
			endif ()
		endforeach ()
	endif ()
	Sf_GetSubDirectories(_SubDirs "${_QtDir}" "^[0-9]+\\.[0-9]+\\.[0-9]+$")
	list(LENGTH _SubDirs _Len)
	if (NOT ${_Len})
		message(STATUS "Qt versioned library not found in '${_QtDir}'!")
		set(${_VarOut} "" PARENT_SCOPE)
		return()
	endif ()
	list(SORT _SubDirs COMPARE NATURAL ORDER DESCENDING)
	list(GET _SubDirs 0 _QtVerDir)
	set(${_VarOut} "${_QtDir}/${_QtVerDir}" PARENT_SCOPE)
endfunction()

# Works around the cmake bug with sources and binary directory on a shared drive.
#
function(Sf_WorkAroundSmbShare)
	#[[
		# Check if the environment var exists telling us that cmake is running on Windows.
		if (EXISTS "$ENV{ComSpec}")
			set(_Command "PowerShell.exe")
			string(REPLACE "/" "\\" _Script "${SfMacros_DIR}/bin/SmbShareWorkAround.ps1")
			execute_process(COMMAND "${_Command}" "${_Script}" "${CMAKE_BINARY_DIR}" OUTPUT_VARIABLE _Result RESULT_VARIABLE _ExitCode)
		endif ()
		#message(STATUS ${_Result})
		# Validate the exit code.
		if (_ExitCode GREATER "0")
			message(FATAL_ERROR "Failed execution of script: ${_Script}")
		endif ()
	]]
endfunction()
