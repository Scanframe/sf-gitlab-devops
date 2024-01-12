function(V_SetPokyToolChain)
	## TODO: Selecting which architecture is build for should be taken into account aswell.
	# Get the Major version number.
	string(REPLACE "." ";" VERSION_LIST ${PokyToolChain_VERSION})
	list(GET VERSION_LIST 0 _VERSION_MAJOR)
	# Location where the Poky version is installed. Included files depend on it.
	set(_InstallDir "/opt/poky/${PokyToolChain_VERSION}")
	# Check the major version to install the version type 2 (ARMv7 32-bit compiler)
	if (_VERSION_MAJOR STREQUAL "2")
		include("${PokyToolChain_DIR}/PokyToolChainV2.cmake")
		# Check the major version to install the version type 3 (i686 32-bit compiler)
	elseif (_VERSION_MAJOR STREQUAL "3")
		include("${PokyToolChain_DIR}/PokyToolChainV3.cmake")
	else ()
		message(FATAL_ERROR "Poky toolchain configuration for version '${PokyToolChain_VERSION}' not available!")
	endif ()
endfunction()

