include(FetchContent)

# Adds doxygen manual target to the project.
#
# _Sources info is obtained using a GLOB function like:
#     file(GLOB_RECURSE _SourceListTmp RELATIVE "${CMAKE_CURRENT_BINARY_DIR}" "../*.h" "../*.md")
#
function(Sf_AddManual _Target _BaseDir _OutDir _SourceList)
	# Initialize plantuml version with empty string.
	set(_PlantUmlVer "")
	# Check if argument 4 which is the plantuml version is passed
	if (DEFINED ARGV4)
		if ("${ARGV4}" STREQUAL "")
			# Set default plantuml version.
			set(_PlantUmlVer "v1.2023.1")
		else()
			set(_PlantUmlVer "${ARGV4}")
		endif ()
		message(STATUS "DoxyGen > PlantUML version to download: '${_PlantUmlVer}'")
		# Check GitHub for latest releases at 'https://github.com/plantuml/plantuml/releases'.
		FetchContent_Declare(PlantUmlJar
			URL "https://github.com/plantuml/plantuml/releases/download/${_PlantUmlVer}/plantuml.jar"
			DOWNLOAD_NO_EXTRACT true
			TLS_VERIFY true
			)
		# Download it.
		FetchContent_MakeAvailable(PlantUmlJar)
		# Set the variable used in the configuration template.
		set(DG_PlantUmlJar "${plantumljar_SOURCE_DIR}")
	else ()
		message(STATUS "PlantUML version not set and is not downloaded.")
	endif ()
	# Add doxygen project when doxygen was found
	find_package(Doxygen QUIET)
	if (NOT Doxygen_FOUND)
		message(NOTICE "${CMAKE_CURRENT_FUNCTION}(): Cannot Doxygen package is missing!")
		return()
	endif ()
	# For cygwin only relative path are working.
	file(RELATIVE_PATH DG_LogoFile "${CMAKE_CURRENT_BINARY_DIR}" "${_BaseDir}/logo.png")
	# Path to images adding the passed base directory. ()
	file(RELATIVE_PATH _Temp "${CMAKE_CURRENT_BINARY_DIR}" "${_BaseDir}")
	set(DG_ImagePath "${_Temp}")
#[[
	# Add the top project source dir.
	file(RELATIVE_PATH _Temp "${CMAKE_CURRENT_BINARY_DIR}" "${CMAKE_SOURCE_DIR}")
	set(DG_ImagePath "${DG_ImagePath} ${_Temp}")
]]
	# Enable when to change the output directory.
	file(RELATIVE_PATH DG_OutputDir "${CMAKE_CURRENT_BINARY_DIR}" "${_OutDir}")
	# Set the MarkDown main page for the manual.
	file(RELATIVE_PATH DG_MainPage "${CMAKE_CURRENT_BINARY_DIR}" "${_BaseDir}/mainpage.md")
	# Replace the list separator ';' with space in the list.
	list(JOIN _SourceList " " DG_Source)
	# Enable when generating Zen styling output.
	if (FALSE)
		set(DG_HtmlHeader "${SfDoxyGen_DIR}/theme/zen/header.html")
		set(DG_HtmlFooter "${SfDoxyGen_DIR}/theme/zen/footer.html")
		set(DG_HtmlExtra "${SfDoxyGen_DIR}/theme/zen/stylesheet.css")
		set(DG_HtmlExtraStyleSheet "")
	else ()
		# Fixes source file viewing.
		file(RELATIVE_PATH DG_HtmlExtraStyleSheet "${CMAKE_CURRENT_BINARY_DIR}" "${SfDoxyGen_DIR}/tpl/doxygen/custom.css")
	endif ()
	# Set the example path to this parent directory.
	file(RELATIVE_PATH DG_ExamplePath "${CMAKE_CURRENT_BINARY_DIR}" "${PROJECT_SOURCE_DIR}")
	# Set PlantUML the include path.
	set(DG_PlantUmlIncPath "${_BaseDir}")
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
	# Only applicable when plantuml is available.
	if (NOT "${DG_PlantUmlJar}" STREQUAL "")
		# Remove plantuml cache file which prevent changes in the include file to propagate.
		add_custom_command(
			TARGET ${_Target}
			PRE_BUILD
			COMMAND ${CMAKE_COMMAND} -E rm "${_OutDir}/inline_*.pu"
		)
	endif ()
endfunction()
