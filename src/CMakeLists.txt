add_subdirectory("gen")
add_subdirectory("hwl")

# Configure the rpath.
if (SF_BUILD_QT STREQUAL "ON")
	# When the Qt directory is available append it.
	Sf_GetQtVersionDirectory(_QtVer)
	if (NOT _QtVer STREQUAL "")
		Sf_SetRPath("\${ORIGIN}:\${ORIGIN}/lib:${_QtVer}/gcc_64/lib")
	endif ()
else ()
	Sf_SetRPath("\${ORIGIN}:\${ORIGIN}/lib")
endif ()

# When Qt libraries are linked.
if (SF_BUILD_QT)
	add_subdirectory("qt")
endif ()

if (SF_BUILD_TESTING)
	add_subdirectory(tests)
endif ()


