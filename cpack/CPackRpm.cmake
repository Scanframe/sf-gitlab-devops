set(CPACK_RPM_PACKAGE_DEBUG ON)

set(CPACK_RPM_FILE_NAME RPM-DEFAULT)
set(CPACK_RPM_PACKAGE_NAME "${CMAKE_PROJECT_NAME}")
set(CPACK_RPM_PACKAGE_VERSION "${CMAKE_PROJECT_VERSION}")
set(CPACK_RPM_PACKAGE_RELEASE "${SF_PACKAGE_RELEASE}")
set(CPACK_RPM_PACKAGE_SUMMARY "${CPACK_PACKAGE_DESCRIPTION_SUMMARY}")
set(CPACK_RPM_PACKAGE_DESCRIPTION "${CPACK_PACKAGE_DESCRIPTION}")
set(CPACK_RPM_PACKAGE_LICENSE "None")
set(CPACK_RPM_PACKAGE_URL "${CMAKE_PROJECT_HOMEPAGE_URL}")
set(CPACK_RPM_PACKAGE_GROUP "Scanframe")
set(CPACK_RPM_PACKAGE_AUTOREQ 1)
set(CPACK_RPM_PACKAGE_AUTOPROV 1)

#set(CPACK_RPM_PACKAGE_REQUIRES "python >= 2.5.0, cmake >= 3.27")