if ("${CMAKE_PROJECT_NAME}" STREQUAL "${PROJECT_NAME}")
	set(CMAKE_CXX_STANDARD 20)
	set(CMAKE_CXX_STANDARD_REQUIRED ON)
	# Do not export all by default in Linux.
	if (NOT WIN32)
		# Catch2 cannot handle compiler switch below.
		#add_definitions("-fvisibility=hidden")
	endif ()
	if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
		# Generate an error on undefined (imported) symbols on dynamic libraries
		# because the error appears only at load-time otherwise.
		add_link_options(-Wl,--no-undefined -Wl,--no-allow-shlib-undefined)
		if (WIN32)
			# When building for Windows using GNU report warnings on MSVC incompatibilities.
			#add_definitions(-D__MINGW_MSVC_COMPAT_WARNINGS)
			# Suppressing the warning that out-of-line inline functions are redeclared.
			#add_link_options(-Wno-inconsistent-dllimport)
		endif ()
	endif ()
	# When MSVC compiler is used set some options.
	if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
		add_compile_options("-Zc:__cplusplus")
	endif()
	#set_property(TARGET "${PROJECT_NAME}" PROPERTY CXX_STANDARD 20)
	# When GNU compiler is used set some options.
	if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
		message(STATUS "C++ Compiler: ${CMAKE_CXX_COMPILER_ID} ${CMAKE_CXX_COMPILER_VERSION}")
		if (WIN32)
			# Needed for Windows since Catch2 is creating a huge obj file.
			add_compile_options(-m64 -Wa,-mbig-obj)
		else ()
			# For detecting memory errors.
			add_compile_options(--pedantic-errors #[[-fsanitize=address]])
		endif ()
	endif ()
	# Workaround for using a network drive on Windows.
	_WorkAroundSmbShare()
	#
	message(STATUS "CMake Version: ${CMAKE_VERSION}")
	message(STATUS "CMake System : ${CMAKE_SYSTEM}")
	message(STATUS "CMake System Name: ${CMAKE_SYSTEM_NAME}")
	message(STATUS "CMake System Info File: ${CMAKE_SYSTEM_INFO_FILE}")
	message(STATUS "CMake System Processor: ${CMAKE_SYSTEM_PROCESSOR}")
endif ()

#TODO: This QT stuff should probably be in its own cmake package file so it can be omitted in non Qt builds.
# Set the Qt Library location variable.
if (NOT DEFINED QT_DIRECTORY)
	_GetQtVersionDirectory(QT_DIRECTORY)
	message(STATUS "Qt Version Directory: ${QT_DIRECTORY}")
	# When changing this CMAKE_PREFIX_PATH remove the 'cmake-build-xxxx' directory
	# since it weirdly keeps the previous selected CMAKE_PREFIX_PATH
	if (WIN32)
		if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
			set(QT_LIBS_SUBDIRECTORY "msvc2019_64")
		else()
			set(QT_LIBS_SUBDIRECTORY "mingw_64")
		endif()
		message(STATUS "Qt Libraries: ${QT_LIBS_SUBDIRECTORY}")
		list(PREPEND CMAKE_PREFIX_PATH "${QT_DIRECTORY}/${QT_LIBS_SUBDIRECTORY}")
		set(QT_INCLUDE_DIRECTORY "${QT_DIRECTORY}/${QT_LIBS_SUBDIRECTORY}/include")
	else ()
		list(PREPEND CMAKE_PREFIX_PATH "${QT_DIRECTORY}/gcc_64")
		set(QT_INCLUDE_DIRECTORY "${QT_DIRECTORY}/gcc_64/include")
	endif ()
endif ()

# Set the Qt directory variable.
if (NOT DEFINED QT_PLUGINS_DIR)
	#message(FATAL_ERROR "######## Fix this depending on the compiler type. ############")
	if (NOT QT_DIRECTORY STREQUAL "")
		if (WIN32)
			set(QT_PLUGINS_DIR "${QT_DIRECTORY}/mingw_64/plugins")
		else ()
			set(QT_PLUGINS_DIR "${QT_DIRECTORY}/gcc_64/plugins")
		endif ()
	endif ()
	message(STATUS "Designer Plugins Dir: ${QT_PLUGINS_DIR}")
endif ()
