
function(Sf_SetToolChain)
	# Assemble path to tool chain file.
	set(_CmakeFile "${CMAKE_CURRENT_BINARY_DIR}/.sf/SfToolChain.cmake")
	file(WRITE "${_CmakeFile}" "#### Created by function '${CMAKE_CURRENT_FUNCTION}'\n")
	# Check if this is a cross compile for windows.
	if (NOT DEFINED SF_CROSS_WINDOWS OR "${SF_CROSS_WINDOWS}" STREQUAL "OFF")
		foreach (_Version RANGE 14 8 -1)
			find_program(_Compiler "/usr/bin/gcc-${_Version}")
			if (NOT _Compiler STREQUAL "_Compiler-NOTFOUND")
				message(STATUS "Found C compiler: ${_Compiler}")
				file(APPEND "${_CmakeFile}" "set(CMAKE_C_COMPILER \"${_Compiler}\")\n")
				break()
			endif ()
		endforeach ()
		foreach (_Version RANGE 14 8 -1)
			find_program(_CppCompiler "/usr/bin/g++-${_Version}")
			if (NOT _CppCompiler STREQUAL "_CppCompiler-NOTFOUND")
				message(STATUS "Found C++ compiler: ${_CppCompiler}")
				file(APPEND "${_CmakeFile}" "set(CMAKE_CXX_COMPILER \"${_CppCompiler}\")\n")
				break()
			endif ()
		endforeach ()
	else ()
		# Find the Windows cross compiler
		find_program(SF_CROSS_COMPILER "x86_64-w64-mingw32-c++-posix")
		if (NOT EXISTS ${SF_CROSS_COMPILER})
			message(FATAL_ERROR "Windows cross compiler not found. Missing package 'mingw-w64' ?")
			return()
		endif ()
		file(APPEND "${_CmakeFile}"
"set(CMAKE_SYSTEM_NAME Windows)
# Use mingw 64-bit compilers.
set(CMAKE_C_COMPILER \"x86_64-w64-mingw32-gcc-posix\")
set(CMAKE_CXX_COMPILER \"x86_64-w64-mingw32-c++-posix\")
set(CMAKE_RC_COMPILER \"x86_64-w64-mingw32-windres\")
set(CMAKE_RANLIB \"x86_64-w64-mingw32-ranlib\")
set(CMAKE_FIND_ROOT_PATH \"/usr/x86_64-w64-mingw32\")
# Adjust the default behavior of the find commands:
# search headers and libraries in the target environment
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
# Search programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
")
	endif ()

		set(CMAKE_TOOLCHAIN_FILE "${_CmakeFile}" PARENT_SCOPE)
endfunction()



