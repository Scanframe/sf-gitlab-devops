# Required first entry checking the cmake version.
cmake_minimum_required(VERSION 3.18)

# Adds Writes a Debian control file using a passed template.
#
function(Sf_DebianControlFile _TplFile)
	set(DC_Package "${CMAKE_PROJECT_NAME}")
	set(DC_HomeUrl "${CMAKE_PROJECT_HOMEPAGE_URL}")
	# Only project description is used as a short description in the template.
	set(DC_Description "${CMAKE_PROJECT_DESCRIPTION}")
	#	Get the project version number.
	set(DC_Version "${CMAKE_PROJECT_VERSION}")
	# Set input and output files for the generation of the actual config file.
	#set(CMAKE_LIBRARY_OUTPUT_DIRECTORY)
	set(_FileOut "${CMAKE_CURRENT_BINARY_DIR}/pkg/DEBIAN/control")
	# Generate the configure the file for doxygen.
	configure_file("${_TplFile}" "${_FileOut}" @ONLY)
endfunction()

# Create a package control file using own template.
Sf_DebianControlFile("${CMAKE_CURRENT_LIST_DIR}/debian-control.tpl")

# Source directory for creating the debian package in.
set(SF_PKG_SRC_DIR "${CMAKE_CURRENT_BINARY_DIR}/pkg")
# Target directory to put all compiled binaries in.
get_filename_component(SF_PKG_TRG_DIR "${CMAKE_CURRENT_BINARY_DIR}/../../bin" REALPATH)
# Full path to target package fle.
set(SF_PKG_TRG "${SF_PKG_TRG_DIR}/${CMAKE_PROJECT_NAME}_${CMAKE_PROJECT_VERSION}.deb")
# Custom command to create a package having an application in '/usr/local/lib' and a symlink in '/usr/local/bin'.
add_custom_command(
	OUTPUT "${SF_PKG_TRG}"
	# Create the Linux directory for installing the
	COMMAND mkdir -p "${SF_PKG_SRC_DIR}/usr/local/lib" && cp "$<TARGET_FILE:hello-world>" "${SF_PKG_SRC_DIR}/usr/local/lib"
	# Create relative symbolic link to executable.
	COMMAND mkdir -p "${SF_PKG_SRC_DIR}/usr/local/bin" && ln -rfs "${SF_PKG_SRC_DIR}/usr/local/lib/$<TARGET_FILE_NAME:hello-world>" "${SF_PKG_SRC_DIR}/usr/local/bin/hello-world"
	COMMAND dpkg-deb --build --root-owner-group "${SF_PKG_SRC_DIR}" "${SF_PKG_TRG}"
	WORKING_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}"
	DEPENDS "hello-world"
	)

	add_custom_target ("package"
	DEPENDS "${SF_PKG_TRG}"
	)

# Run script when calling install target.
#install(CODE "execute_process(COMMAND my_script.sh)")
