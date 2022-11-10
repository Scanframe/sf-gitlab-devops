# Adds doxygen manual target to the project.
#
function(Sf_AddManual _Target _BaseDir _OutDir)
	# Add doxygen project when doxygen was found
	find_package(Doxygen QUIET)
	if (NOT Doxygen_FOUND)
		message(NOTICE "${CMAKE_CURRENT_FUNCTION}(): Cannot Doxygen package is missing!")
		return()
	endif()
	# For cygwin only relative path are working.
	file(RELATIVE_PATH DG_LogoFile "${CMAKE_CURRENT_BINARY_DIR}" "${_BaseDir}/logo.png")
	# Path to images adding the passed base directory. ()
	file(RELATIVE_PATH _Temp "${CMAKE_CURRENT_BINARY_DIR}" "${_BaseDir}")
	set(DG_ImagePath "${_Temp}")
	# Add the top project source dir.
	file(RELATIVE_PATH _Temp "${CMAKE_CURRENT_BINARY_DIR}" "${CMAKE_SOURCE_DIR}")
	set(DG_ImagePath "${DG_ImagePath} ${_Temp}")
	# Enable when to change the output directory.
	file(RELATIVE_PATH DG_OutputDir "${CMAKE_CURRENT_BINARY_DIR}" "${_OutDir}")
	# Get the markdown files in this project directory.
	file(GLOB _SourceList RELATIVE "${CMAKE_CURRENT_BINARY_DIR}" "*.md")
	# Get all the header files in the ../com module.
	file(GLOB_RECURSE _SourceListTmp RELATIVE "${CMAKE_CURRENT_BINARY_DIR}" "../com/*.h" "../com/*.md")
	# Remove unwanted header file(s) ending on 'Private.h'.
	list(FILTER _SourcesListTmp EXCLUDE REGEX ".*Private\\.h$")
	list(APPEND _SourceList ${_SourceListTmp})
	# Replace the list separator ';' with space in the list.
	list(JOIN _SourceList " " DG_Source)
	# Enable when generating Zen styling output.
	if (FALSE)
		set(DG_HtmlHeader "${SfDoxyGen_DIR}/theme/zen/header.html")
		set(DG_HtmlFooter "${SfDoxyGen_DIR}/theme/zen/footer.html")
		set(DG_HtmlExtra "${SfDoxyGen_DIR}/theme/zen/stylesheet.css")
		set(DG_HtmlExtraStyleSheet "")
	else()
		# Fixes source file viewing.
		file(RELATIVE_PATH DG_HtmlExtraStyleSheet "${CMAKE_CURRENT_BINARY_DIR}" "${SfDoxyGen_DIR}/tpl/doxygen/custom.css")
	endif ()
	# Set the example path to this parent directory.
	file(RELATIVE_PATH DG_ExamplePath "${CMAKE_CURRENT_BINARY_DIR}" "${PROJECT_SOURCE_DIR}")
	# Set input and output files for the generation of the actual config file.
	set(_FileIn "${SfDoxyGen_DIR}/tpl/doxygen/doxyfile.conf")
	set(_FileOut "${CMAKE_CURRENT_BINARY_DIR}/doxyfile.conf")
	# Generate the configure the file for doxygen.
	configure_file("${_FileIn}" "${_FileOut}" @ONLY)
	# Note the option ALL which allows to build the docs together with the application.
	add_custom_target("${_Target}" ALL
		COMMAND ${DOXYGEN_EXECUTABLE} ${_FileOut}
		WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
		COMMENT "Generating documentation with Doxygen"
		VERBATIM)
	#message(FATAL_ERROR "DG_Source: ${DG_Source}")
endfunction()
