# Notify that this file was loaded.
message(STATUS "Configuring Linux for latest compiler version")

# Need a sentry other wise weird linker errors occur for unknown reason.
if (CMAKE_C_COMPILER STREQUAL "")
	foreach (_Version RANGE 14 8 -1)
		find_program(_Compiler "/usr/bin/gcc-${_Version}")
		if (NOT _Compiler STREQUAL "_Compiler-NOTFOUND")
			message(STATUS "Found compiler: ${_Compiler}")
			set(CMAKE_C_COMPILER "${_Compiler}")
			break()
		endif ()
	endforeach ()
endif ()

# Need a sentry other wise weird linker errors occur for unknown reason.
if (CMAKE_C_COMPILER STREQUAL "")
	foreach (_Version RANGE 14 8 -1)
		find_program(_Compiler "/usr/bin/g++-${_Version}")
		if (NOT _Compiler STREQUAL "_Compiler-NOTFOUND")
			message(STATUS "Found compiler: ${_Compiler}")
			set(CMAKE_CXX_COMPILER "${_Compiler}")
			break()
		endif ()
	endforeach ()
endif ()
