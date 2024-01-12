# Root of all poky installs.
set(_POKY_INSTALL_ROOT "/opt/poky")
# Full provided version string
set(PACKAGE_VERSION False)
# True if version is exact match
set(PACKAGE_VERSION_EXACT False)
# True if version is compatible
set(PACKAGE_VERSION_COMPATIBLE False)
# True if unsuitable as any version
set(PACKAGE_VERSION_UNSUITABLE False)
# Check if the version directory exists.
if (NOT EXISTS "${_POKY_INSTALL_ROOT}/${PACKAGE_FIND_VERSION}")
	# Get the all the version directories having the format 'x.x.x' .
	file(GLOB _versions RELATIVE ${_POKY_INSTALL_ROOT} "${_POKY_INSTALL_ROOT}/*.*.*")
	list(JOIN _versions ", " _versions)
	# Notice which Poky compilers are available.
	message(NOTICE "Poky toolchain available versions: ${_versions}")
else ()
	# Set the package name.
	set(PACKAGE_NAME PokyToolChain)
	# SEt the version which will result in the 'PokyToolChain_VERSION' being set as well.
	set(PACKAGE_VERSION ${PACKAGE_FIND_VERSION})
	# Log the version selected.
	message(STATUS "Poky toolchain v${PACKAGE_FIND_VERSION} found (${PACKAGE_NAME}).")
	# Signal the exact version was found to the running cmake.
	set(PACKAGE_VERSION_EXACT True)
	# Set the version for the package and the function installing the chain.
	#set(PokyToolChain_VERSION ${PACKAGE_FIND_VERSION})
endif ()

