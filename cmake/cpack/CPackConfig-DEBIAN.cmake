# See: https://cmake.org/cmake/help/latest/cpack_gen/deb.html
set(CPACK_DEBIAN_PACKAGE_DEBUG OFF)
set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
set(CPACK_DEBIAN_PACKAGE_NAME "${SF_PACKAGE_NAME}")
# Variable CPACK_DEBIAN_PACKAGE_VERSION defaults to the CPACK_PACKAGE_VERSION so no need to set it.
#set(CPACK_DEBIAN_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}")
# Variable CPACK_DEBIAN_PACKAGE_RELEASE is not used and resolved using CPACK_PACKAGE_VERSION.
#set(CPACK_DEBIAN_PACKAGE_RELEASE "")

# Set the architecture conform the compiler.
# To check the resulting package architecture use:
#    dpkg-deb -f <deb-file> architecture
if (SF_ARCHITECTURE STREQUAL "x86_64")
	# Set the architecture name used by debian.
	set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
	set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
# Check for the aarch64.
elseif (SF_ARCHITECTURE STREQUAL "x86")
	set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "i386")
	set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
elseif (SF_ARCHITECTURE STREQUAL "aarch64")
	set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "arm64")
	set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
elseif (SF_ARCHITECTURE STREQUAL "arm")
	set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "armhf")
	set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
else ()
	message(SEND_ERROR "Architecture '${CMAKE_SYSTEM_PROCESSOR}' not supported!")
endif ()

set(CPACK_DEBIAN_PACKAGE_GENERATE_SHLIBS ON)
#set(CPACK_DEBIAN_PACKAGE_MAINTAINER "${CPACK_PACKAGE_CONTACT}")
set(CPACK_DEBIAN_PACKAGE_HOMEPAGE "${CMAKE_PROJECT_HOMEPAGE_URL}")
# Prevent error in 'CPackDeb.cmake' reporting "dpkg-shlibdeps: 'dpkg-shlibdeps: error: cannot find library".
list(APPEND CPACK_DEBIAN_PACKAGE_SHLIBDEPS_PRIVATE_DIRS "${CMAKE_INSTALL_PREFIX}/lib")
#set(CPACK_DEBIAN_PACKAGE_DEPENDS "libc6 (>= 2.3.1-6), libc6 (< 2.4)")


