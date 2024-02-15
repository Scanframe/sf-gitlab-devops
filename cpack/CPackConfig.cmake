# Required first entry checking the cmake version.
cmake_minimum_required(VERSION 3.25)

set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${CMAKE_PROJECT_DESCRIPTION}")
set(CPACK_PACKAGE_DESCRIPTION
	"The long description of this DevOps trial application
having more then one line.")

# Seems to have no effect at the moment...
#if (NOT WIN32)
#	set(CPACK_SET_DESTDIR "$ENV{HOME}/tmp")
#endif ()

set(CPACK_PACKAGING_INSTALL_PREFIX "/opt/Scanframe/devops")
# Set the temporary directory to install which is actually copy the binaries to.
# So in this case the as subdirectory in the CMake binary directory is used.
set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/__install__")

# Release number set only once.
# Uncomment this lines to use timestamp for the release number.
#string(TIMESTAMP NOW "%s")
#set(SF_PACKAGE_RELEASE "${NOW}")
set(SF_PACKAGE_RELEASE 1)

include("${CMAKE_CURRENT_LIST_DIR}/CPackDebian.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/CPackRpm.cmake")

Sf_GetAllTargets(_AllTargets "${PROJECT_SOURCE_DIR}" "TRUE")
foreach (_Target ${_AllTargets})
	get_target_property(_Type "${_Target}" TYPE)
	# MODULE_LIBRARY, SHARED_LIBRARY, OBJECT_LIBRARY, INTERFACE_LIBRARY, EXECUTABLE
	if (_Type STREQUAL "EXECUTABLE" OR _Type MATCHES "_LIBRARY$")
	#if (_Type STREQUAL "EXECUTABLE" OR _Type STREQUAL "SHARED_LIBRARY")
		#message(NOTICE "_Target=${_Target}, Type=${_Type}")
		list(APPEND _Targets  "${_Target}")
	endif ()
endforeach ()

install(TARGETS ${_Targets}
	RUNTIME DESTINATION bin
	LIBRARY DESTINATION lib
	ARCHIVE DESTINATION arc
	#CONFIGURATIONS Debug
)

#install(DIRECTORY "bin/man/html/" DESTINATION doc FILES_MATCHING PATTERN "*.*")
#install(DIRECTORIES "lnx64" DESTINATION "." FILES_MATCHING PATTERN "*.bin")

include(CPack)
