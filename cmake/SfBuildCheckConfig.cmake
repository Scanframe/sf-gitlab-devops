macro(Sf_EnsureOutOfSourceBuild MSG)
	string(COMPARE EQUAL "${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}" InSource)
	get_filename_component(ParentDir ${CMAKE_SOURCE_DIR} PATH)
	string(COMPARE EQUAL "${CMAKE_SOURCE_DIR}" "${ParentDir}" InSourceSubdir)
	if(InSource OR InSourceSubdir)
		message(FATAL_ERROR "${MSG}") 
	endif()
endmacro()

# Ensures that we do an out of source build
Sf_EnsureOutOfSourceBuild("${PROJECT_NAME} requires an out of source build.")
