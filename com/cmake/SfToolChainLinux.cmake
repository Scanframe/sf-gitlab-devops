# Notify that this file was loaded.
message(STATUS "Configuring Linux for latest compiler version")

# Dirty way of getting the newest installed C compiler on the system.
foreach(_Version RANGE 14 8 -1)
	find_program(_Compiler "/usr/bin/gcc-${_Version}")
	if (NOT _Compiler STREQUAL "_Compiler-NOTFOUND")
		message(STATUS "Found compiler: ${_Compiler}")
		set(CMAKE_C_COMPILER "${_Compiler}")
		break()
	endif()
endforeach()

# Dirty way of getting the newest installed C++ compiler on the system.
foreach(_Version RANGE 14 8 -1)
	find_program(_Compiler "/usr/bin/g++-${_Version}")
	if (NOT _Compiler STREQUAL "_Compiler-NOTFOUND")
		message(STATUS "Found compiler: ${_Compiler}")
		set(CMAKE_CXX_COMPILER "${_Compiler}")
		break()
	endif()
endforeach()


