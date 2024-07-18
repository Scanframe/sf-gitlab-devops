# Required first entry checking the cmake version.
cmake_minimum_required(VERSION 3.27)

# This the also the default for variale CPACK_DEBIAN_PACKAGE_MAINTAINER.
set(CPACK_PACKAGE_CONTACT "Arjan van Olphen <a.v.olphen@scanframe.nl>")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${CMAKE_PROJECT_DESCRIPTION}")
set(CPACK_PACKAGE_DESCRIPTION
	"The long description of this DevOps template application
having more then one line.")

# Variable for all types of packages to set the individual package name.
# This name could get a suffix like '-staging' when it is not a release.
set(SF_PACKAGE_NAME "${CMAKE_PROJECT_NAME}")

# Seems to have no effect at the moment...
#if (NOT WIN32)
#	set(CPACK_SET_DESTDIR "$ENV{HOME}/tmp")
#endif ()
#set(CPACK_PACKAGE_DIRECTORY "/tmp/cpack")

# Do not include the directory named the same as the ZIP file. (ZIP generator only)
set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF)

# Disables the component-based installation mechanism.
set(CPACK_MONOLITHIC_INSTALL ON)

# Set the temporary directory to install which is actually copy the binaries to.
# So in this case the as subdirectory in the CMake binary directory is used.
set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/__install__")

if (WIN32)
	# Somehow the'\\\\' to prevent an error.
	set(CPACK_PACKAGE_INSTALL_DIRECTORY "Scanframe\\\\${PROJECT_NAME}")
	# Only for ZIP, RPM and Debian packages.
	set(CPACK_PACKAGING_INSTALL_PREFIX "/Scanframe/${PROJECT_NAME}")
else ()
	set(CPACK_PACKAGE_INSTALL_DIRECTORY "Scanframe/${PROJECT_NAME}")
	# Only for ZIP, RPM and Debian packages.
	set(CPACK_PACKAGING_INSTALL_PREFIX "/opt/Scanframe/${PROJECT_NAME}")
endif ()

# Initialize the package release variable for Debian it is limited to regex "^[A-Za-z0-9.+~]+$"
set(SF_PACKAGE_RELEASE "")
# Check for a release candidate of the Git tag and if so append the RC reference.
if (NOT SF_GIT_TAG_RC STREQUAL "")
	set(SF_PACKAGE_RELEASE "rc.${SF_GIT_TAG_RC}")
endif ()
# Check for an offset in commits from the tag then append the number the release name.
if (NOT SF_GIT_TAG_COMMITS STREQUAL "")
	set(SF_PACKAGE_RELEASE "${SF_PACKAGE_RELEASE}~${SF_GIT_TAG_COMMITS}")
endif ()

#[[
# When called from a CI-pipeline append its IID and when not the timestamp.
if (DEFINED ENV{CI_PIPELINE_IID})
	set(SF_PACKAGE_RELEASE "${SF_PACKAGE_RELEASE}~$ENV{CI_PIPELINE_IID}")
else ()
	string(TIMESTAMP NOW "%Y%m%d%H%M%S")
	set(SF_PACKAGE_RELEASE "${SF_PACKAGE_RELEASE}~${NOW}")
endif ()
]]

# Default is the main project version which is already set to SF_GIT_TAG_VERSION
# which it is overridden when release part is to be added.
if (NOT SF_PACKAGE_RELEASE STREQUAL "")
	set(CPACK_PACKAGE_VERSION "${SF_GIT_TAG_VERSION}-${SF_PACKAGE_RELEASE}")
endif ()

# Notify the package release produced.
message(STATUS "Package version: ${CPACK_PACKAGE_VERSION}")

# Don't make the 'install' target depend on the 'all' target.
set(CMAKE_SKIP_INSTALL_ALL_DEPENDENCY TRUE)
# Number of threads to use when performing parallelized operations, such as compressing the installer package.
set(CPACK_THREADS 4)

# Specific packager settings are in put in include separate files.
include("${CMAKE_CURRENT_LIST_DIR}/CPackConfig-DEBIAN.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/CPackConfig-RPM.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/CPackConfig-NSIS.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/CPackConfig-ARCHIVE.cmake")

# Retrieve all targets from this project.
Sf_GetAllTargets(_AllTargets "${PROJECT_SOURCE_DIR}" "TRUE")
# Iterate through all targets
foreach (_Target ${_AllTargets})
	get_target_property(_Type "${_Target}" TYPE)
	# Only install executables and shared libraries.
	if (_Type STREQUAL "EXECUTABLE" OR _Type STREQUAL "SHARED_LIBRARY")
		# Skip all test targets for packaging.
		if ("${_Target}" MATCHES "^${SF_TEST_NAME_PREFIX}.*$")
			message(VERBOSE "Skipping ${_Type} '${_Target}'")
		else ()
			message(VERBOSE "Installing ${_Type} '${_Target}'")
			list(APPEND _Targets "${_Target}")
		endif ()
	endif ()
endforeach ()

# Install all the targets in (sub-)directories.
if (WIN32)
	# Do not include the import libraries.
	install(TARGETS ${_Targets}
		RUNTIME DESTINATION ./
		LIBRARY DESTINATION ./
		#CONFIGURATIONS Debug
	)
else ()
	install(TARGETS ${_Targets}
		RUNTIME DESTINATION ./
		LIBRARY DESTINATION lib
		ARCHIVE DESTINATION arc
		#CONFIGURATIONS Debug
	)
endif ()

#install(DIRECTORY "bin/man/html/" DESTINATION doc FILES_MATCHING PATTERN "*.*")
#install(DIRECTORIES "lnx64" DESTINATION "." FILES_MATCHING PATTERN "*.bin")

# The include here creates the all variable which have not been set yet to the defaults.
# So CPACK_PACKAGE_FILE_NAME is set "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-${CPACK_SYSTEM_NAME}"
# The variable CPACK_ARCHIVE_FILE_NAME is bugged in 3.27.8 and not set or used by 'CPack' include file here.
include(CPack)
