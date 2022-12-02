
function(Sf_SetToolChain)
	# Assemble path to tool chain file.
	set(_CmakeFile "${CMAKE_CURRENT_BINARY_DIR}/.sf/SfToolChain.cmake")
	file(WRITE "${_CmakeFile}" "#### Created by function '${CMAKE_CURRENT_FUNCTION}'\n")
	# Check if this is a cross compile for windows.
	if (NOT DEFINED SF_CROSS_WINDOWS OR "${SF_CROSS_WINDOWS}" STREQUAL "OFF")
		# By default the toolset for Linux is GNU
		if (NOT DEFINED SF_COMPILER OR "${SF_COMPILER}" STREQUAL "gnu")
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
		# When set to clang try to find the latest clang compiler.
		elseif ("${SF_COMPILER}" STREQUAL "clang")
			foreach (_Version RANGE 19 9 -1)
				find_program(_Compiler "/usr/bin/clang-${_Version}")
				if (NOT _Compiler STREQUAL "_Compiler-NOTFOUND")
					message(STATUS "Found C compiler: ${_Compiler}")
					file(APPEND "${_CmakeFile}" "set(CMAKE_C_COMPILER \"${_Compiler}\")\n")
					break()
				endif ()
			endforeach ()
			foreach (_Version RANGE 19 9 -1)
				find_program(_CppCompiler "/usr/bin/clang++-${_Version}")
				if (NOT _CppCompiler STREQUAL "_CppCompiler-NOTFOUND")
					message(STATUS "Found C++ compiler: ${_CppCompiler}")
					file(APPEND "${_CmakeFile}" "set(CMAKE_CXX_COMPILER \"${_CppCompiler}\")\n")
					break()
				endif ()
			endforeach ()
		# Report that a toolset was given but not
		else ()
			message(FATAL_ERROR "Toolset '${SF_COMPILER}' is unknown!")
		endif ()
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

		# Cygwin compilers.
		if (False)
			file(APPEND "${_CmakeFile}"
"set(CMAKE_SYSTEM_NAME Windows)
# Use mingw 64-bit compilers on Cygwin.
set(CMAKE_C_COMPILER \"i686-w64-mingw32-gcc\")
set(CMAKE_CXX_COMPILER \"i686-w64-mingw32-c++\")
set(CMAKE_RC_COMPILER \"i686-w64-mingw32-windres\")
set(CMAKE_RANLIB \"i686-w64-mingw32-ranlib\")
set(CMAKE_FIND_ROOT_PATH \"/usr/bin\")
# Adjust the default behavior of the find commands:
# search headers and libraries in the target environment
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
# Search programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
")
		endif ()


	endif ()

		set(CMAKE_TOOLCHAIN_FILE "${_CmakeFile}" PARENT_SCOPE)
endfunction()



