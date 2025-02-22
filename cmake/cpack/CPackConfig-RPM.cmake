# See: https://cmake.org/cmake/help/latest/cpack_gen/rpm.html
set(CPACK_RPM_PACKAGE_DEBUG OFF)
set(CPACK_RPM_PACKAGE_RELOCATABLE ON)
set(CPACK_RPM_FILE_NAME RPM-DEFAULT)
set(CPACK_RPM_PACKAGE_NAME "${SF_PACKAGE_NAME}")
# Variable CPACK_RPM_PACKAGE_VERSION defaults to the CPACK_PACKAGE_VERSION so no need to set it.
#set(CPACK_RPM_PACKAGE_VERSION "${CMAKE_PROJECT_VERSION}")
# Variable CPACK_RPM_PACKAGE_RELEASE is not used and resolved using CPACK_PACKAGE_VERSION but even when empty '-1' is added.
set(CPACK_RPM_PACKAGE_RELEASE "")
set(CPACK_RPM_PACKAGE_SUMMARY "${CPACK_PACKAGE_DESCRIPTION_SUMMARY}")
set(CPACK_RPM_PACKAGE_DESCRIPTION "${CPACK_PACKAGE_DESCRIPTION}")
set(CPACK_RPM_PACKAGE_LICENSE "None")
set(CPACK_RPM_PACKAGE_URL "${CMAKE_PROJECT_HOMEPAGE_URL}")
set(CPACK_RPM_PACKAGE_GROUP "Scanframe")
set(CPACK_RPM_PACKAGE_AUTOREQ 1)
set(CPACK_RPM_PACKAGE_AUTOPROV 1)
#set(CPACK_RPM_PACKAGE_REQUIRES "python >= 2.5.0, cmake >= 3.27")
set(CPACK_RPM_PACKAGE_ARCHITECTURE "${SF_ARCHITECTURE}")
# Set the correct stripping application from the toolchain.
set(CPACK_RPM_SPEC_MORE_DEFINE "%define __strip ${CMAKE_STRIP}")
# Prevent stripping since it calls the default /usr/bin/strip on the aarch64 when on x86_64 system.
#set(CPACK_RPM_SPEC_MORE_DEFINE "%define __spec_install_post /bin/true")
