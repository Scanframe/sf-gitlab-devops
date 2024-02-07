add_subdirectory("gen")

# When Qt libraries are linked.
if (SF_BUILD_QT)
	add_subdirectory("qt")
endif ()

if (SF_BUILD_TESTING)
	add_subdirectory(tests)
endif ()
