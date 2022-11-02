#!/bin/bash
#set -x

# When the script directory is not set then
if [[ -z "${SCRIPT_DIR}" ]] ; then
	# Get the bash script directory.
	SCRIPT_DIR="$(realpath "$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)/../..")"
fi

# Define and use some foreground colors values when not running CI-jobs.
if [[ ${CI} ]] ; then
	fg_black="";
	fg_red=""
	fg_green=""
	fg_yellow=""
	fg_blue=""
	fg_magenta=""
	fg_cyan=""
	fg_white=""
	fg_reset=""
else
	# shellcheck disable=SC2034
	fg_black="$(tput setaf 0)"
	fg_red="$(tput setaf 1)"
	# shellcheck disable=SC2034
	fg_green="$(tput setaf 2)"
	fg_yellow="$(tput setaf 3)"
	# shellcheck disable=SC2034
	fg_blue="$(tput setaf 4)"
	fg_magenta="$(tput setaf 5)"
	fg_cyan="$(tput setaf 6)"
	# shellcheck disable=SC2034
	fg_white="$(tput setaf 7)"
	fg_reset="$(tput sgr0)"
fi

# Writes to stderr.
#
function WriteLog()
{
	# shellcheck disable=SC2034
	# shellcheck disable=SC2124
	local LAST_ARG="${@: -1}"
	local LAST_CH="${LAST_ARG: 0-1}"
	case "${LAST_CH}" in
		"!")
			local COLOR="${fg_red}"
			;;
		".")
			local COLOR="${fg_cyan}"
			;;
		"-")
			local COLOR="${fg_magenta}"
			;;
		"=")
			local COLOR="${fg_yellow}"
			;;
		*)
			local COLOR=""
			;;
	esac
	echo -n "${COLOR}" 1>&2;
	# shellcheck disable=SC2068
	echo ${@} 1>&2;
	echo -n "${fg_reset}" 1>&2;
}

# Amount of CPU cores to use for compiling.
CPU_CORES_TO_USE="$(($(nproc --all) -1))"

# Change to the scripts directory to operated from.
if ! cd "${SCRIPT_DIR}" ; then
	WriteLog "Change to operation directory '${SCRIPT_DIR}' failed!"
	exit 1;
fi

# Prints the help to stderr.
#
function ShowHelp()
{
	echo "Usage: ${0} [<options>] <sub-dir> [<target>]
  -d : Debug: Show executed commands rather then executing them.
  -p : Install prerequisite Linux packages using 'apt' for now.
  -c : Cleans build targets first (adds build option '--clean-first')
  -C : Wipe clean the targeted cmake-build-<build-type>-<compiler-type>
  -t : Add tests to the build configuration.
  -w : Cross compile Windows on Linux using MinGW.
  -s : Build using Visual Studio
  -m : Create build directory and makefiles only.
  -b : Build target only.
  Where <sub-dir> is:
    '.', 'com', 'rt-shared-lib/app', 'rt-shared-lib/iface',
    'rt-shared-lib/impl-a', 'rt-shared-lib', 'custom-ui-plugin'
  When the <target> argument is omitted it defaults to 'all'.
  The <sub-dir> is also the directory where cmake will create its 'cmake-build-???' directory.

  Examples:
    Make/Build all projects: ${0} -mb .
    Same as above: ${0} -mb . all
    Clean all projects: ${0} . clean
    Install all projects: ${0} . install
    Show all projects to be build: ${0} . help
    Build 'sf-misc' project in 'com' sub-dir only: ${0} -b . sf-misc
    Build 'com' project and all sub-projects: ${0} -b com
    Build 'rt-shared-lib' project and all sub-projects: ${0} -b rt-shared-lib
	"
}

# Install needed packages depending in the Windows(cygwin) or Linux environment it is called from.
#
function InstallPackages()
{
	if [[ "${1}" == "Linux" ]] ; then
		WriteLog "About to install required packages..."
		if ! sudo apt install cmake doxygen graphviz libopengl0 libgl1-mesa-dev libxkbcommon-dev \
			libxkbfile-dev libvulkan-dev libssl-dev gcc-12 g++-12; then
			WriteLog "Failed to install 1 or more packages!"
			exit 1
		fi
	elif [[ "${1}" == "Linux/Cross" ]] ; then
		if ! sudo apt install mingw-w64 cmake doxygen graphviz ; then
			WriteLog "Failed to install 1 or more packages!"
			exit 1
		fi
	elif [[ "${1}" == "Windows" ]] ; then
		if ! cyg-apt install doxygen graphviz ; then
			WriteLog "Failed to install 1 or more Cygwin packages!"
			exit 1
		fi
	else
		# shellcheck disable=SC2128
		WriteLog "Unknown '$1' environment selection passed to function '${FUNCNAME}'."
	fi
}

# Detect windows using the cygwin 'uname' command.
if [[ "$(uname -s)" == "CYGWIN_NT"* ]] ; then
	WriteLog "Windows detected."
	export SF_TARGET_SYSTEM="Windows"
	FLAG_WINDOWS=true
	# Set the directory the local QT root.
	LOCAL_QT_ROOT="P:\\Qt"
	EXEC_SCRIPT="$(mktemp --suffix .bat)"
else
	WriteLog "Linux detected."
	export SF_TARGET_SYSTEM="Linux"
	FLAG_WINDOWS=false
	# Set the directory the local QT root.
	LOCAL_QT_ROOT="${HOME}/lib/Qt"
	EXEC_SCRIPT="$(mktemp --suffix .sh)"
	chmod +x "${EXEC_SCRIPT}"
fi

# Report the working directory
WriteLog "Working from directory '${SCRIPT_DIR}'."

# Initialize arguments and switches.
FLAG_DEBUG=false
FLAG_CONFIG=false
FLAG_BUILD=false
FLAG_WIPE_DIR=false
# Flag for cross compiling for Windows from Linux.
FLAG_CROSS_WINDOWS=false
# Flag for when using Visual Studio
FLAG_VISUAL_STUDIO=false
# Initialize the config options.
CONFIG_OPTIONS="-L"
CONFIG_OPTIONS=""
# Initialize the build options.
BUIlD_OPTIONS=
# Initialize the target.
TARGET="all"
# Additional Cmake make command line options.
declare -A CMAKE_DEFS
# Default profile is debug.
CMAKE_DEFS['CMAKE_BUILD_TYPE']='Debug'
# Default build dynamic libraries.
CMAKE_DEFS['BUILD_SHARED_LIBS']='ON'

# Parse all options and arguments.
# ---------------------------------

argument=()
while [ $# -gt 0 ] && [ "$1" != "--" ]; do
	while getopts "dhcCbtmwsp" opt; do
		case $opt in
			h)
				ShowHelp
				exit 0
				;;
			d)
				FLAG_DEBUG=true
				;;
			p)
				if [[ ${FLAG_CROSS_WINDOWS} ]] ; then
					InstallPackages "${SF_TARGET_SYSTEM}/Cross"
				else
					InstallPackages "${SF_TARGET_SYSTEM}"
				fi
					exit 0
				;;
			C)
				WriteLog "Wipe clean targeted build directory commenced."
				# Set the flag to wipe the build directory first.
				FLAG_WIPE_DIR=true
				;;
			c)
				WriteLog "Clean first enabled"
				BUIlD_OPTIONS="${BUIlD_OPTIONS} --clean-first"
				;;
			m)
				WriteLog "Create build directory and makefiles."
				FLAG_CONFIG=true
				;;
			b)
				WriteLog "Build the given target."
				FLAG_BUILD=true
				;;
			t)
				WriteLog "Include test builds."
				CMAKE_DEFS['SF_BUILD_TESTING']='ON'
				;;
			w)
				if ! ${FLAG_WINDOWS} ; then
					WriteLog "Cross compile for Windows"
					if [[ ! ${FLAG_WINDOWS} = true ]] ; then
						FLAG_CROSS_WINDOWS=true
					fi
				else
					WriteLog "Ignoring Cross compile when in Windows."
				fi
				;;
			s)
				if ${FLAG_WINDOWS} ; then
					WriteLog "Using Visual Studio Compiler"
					FLAG_VISUAL_STUDIO=true
				else
					WriteLog "Ignoring Visual Studio switch when in Linux."
				fi
				;;
			\?)
				ShowHelp
			 	exit 1
				;;
	esac
	done
	shift $((OPTIND-1))
	while [ $# -gt 0 ] && ! [[ "$1" =~ ^- ]]; do
		argument=("${argument[@]}" "$1")
		shift
	done
done
if [ "$1" == "--" ]; then
	shift
	argument=("${argument[@]}" "$@")
fi

# First argument is mandatory.
if [[ -z "${argument[0]}" ]]; then
	WriteLog "Mandatory target (sub-)directory not passed!"
	ShowHelp
	exit 1
fi

# Initialize variables.
SOURCE_DIR="${argument[0]}"
# Initialize the first part of the build directory depending on the build type (Debug, Release etc.).
BUILD_SUBDIR="cmake-build-${CMAKE_DEFS['CMAKE_BUILD_TYPE'],,}"
#
# Assemble CMake build directory depending on OS and passed options.
#
# When Windows is the OS running Cygwin.
if ${FLAG_WINDOWS} = true ; then
	# Set the build-dir for the cross compile.
	if ${FLAG_VISUAL_STUDIO} = true ; then
		BUILD_SUBDIR="${BUILD_SUBDIR}-msvc"
	else
		BUILD_SUBDIR="${BUILD_SUBDIR}-mingw"
	fi
# When a Linux is the OS.
else
	# Set the build-dir for the cross compile.
	if ${FLAG_CROSS_WINDOWS} ; then
		# Set the CMake define.
		CMAKE_DEFS['SF_CROSS_WINDOWS']='ON'
		BUILD_SUBDIR="${BUILD_SUBDIR}-gw"
	else
		BUILD_SUBDIR="${BUILD_SUBDIR}-gnu"
	fi
fi

# When second argument is not given all targets are build as the default.
if [[ -n "${argument[1]}" ]]; then
	TARGET="${argument[1]}"
fi

# Check if wiping can be performed.
if [[ "${TARGET}" == @(help|install) && ${FLAG_WIPE_DIR} ]] ;  then
	FLAG_WIPE_DIR=false
	WriteLog "Wiping clean with target '${TARGET}' not possible!"
fi

# When the Wipe flag is set.
if ${FLAG_WIPE_DIR} ; then
	RM_CMD="rm --verbose --recursive --one-file-system --interactive=never"
	RM_SUBDIR="${SCRIPT_DIR}"
	if [[ -n "${TARGET}" && "${TARGET}" && "${TARGET}" != "all" ]] ; then
		RM_SUBDIR="${RM_SUBDIR}/${TARGET}"
	fi
	WriteLog "Wiping clean build-dir '${RM_SUBDIR}/${BUILD_SUBDIR}'."
	# Check if only build flag is specified.
	if ! ${FLAG_CONFIG} && ${FLAG_BUILD} ; then
		WriteLog "Only building is impossible after wipe!"
		FLAG_BUILD=false
	fi
	if ${FLAG_DEBUG} ; then
		WriteLog "@${RM_CMD} ${RM_SUBDIR}/${BUILD_SUBDIR}/*"
	else
		# Check if the build directory really exists checking an expected subdir.
		if [[ -d "${RM_SUBDIR}/${BUILD_SUBDIR}" ]] ; then
			# Remove all content from the build directory also the hidden ones skipping '.' and '..'
			${RM_CMD} "${RM_SUBDIR}/${BUILD_SUBDIR}/"..?* "${RM_SUBDIR}/${BUILD_SUBDIR}/".[!.]* "${RM_SUBDIR}/${BUILD_SUBDIR}/"* > /dev/null
		fi
	fi
fi

# Configure Build generator depending .
if ${FLAG_WINDOWS} ; then
	CMAKE_BIN="${LOCAL_QT_ROOT}\Tools\CMake_64\bin\cmake.exe"
	BUILD_DIR="$(cygpath -aw "${SCRIPT_DIR}/${BUILD_SUBDIR}")"
	if ${FLAG_VISUAL_STUDIO} ; then
		BUILD_GENERATOR="CodeBlocks - NMake Makefiles"
		# CMake binary bundled with MSVC but the default QT version is also ok.
		CMAKE_BIN="%VSINSTALLDIR%\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe"
	else
		BUILD_GENERATOR="MinGW Makefiles"
	fi
	SOURCE_DIR="$(cygpath -aw "${SOURCE_DIR}")"
else
	# Try to use the CLion installed version of the cmake command.
	CMAKE_BIN="${HOME}/lib/clion/bin/cmake/linux/bin/cmake"
	if ! command -v "${CMAKE_BIN}" &> /dev/null ; then
		# Try to use the Qt installed version of the cmake command.
		CMAKE_BIN="${LOCAL_QT_ROOT}/Tools/CMake/bin/cmake"
		if ! command -v "${CMAKE_BIN}" &> /dev/null ; then
			CMAKE_BIN="cmake"
		fi
	fi
	BUILD_DIR="${SCRIPT_DIR}/${BUILD_SUBDIR}"
	BUILD_GENERATOR="CodeBlocks - Unix Makefiles"
	WriteLog "CMake '$(realpath ${CMAKE_BIN})' $(${CMAKE_BIN} --version | head -n 1)."
fi


# Build execution script depending on the OS.
if ${FLAG_WINDOWS} ; then
	# Start of echo capturing.
	{
		echo '@echo off'
		# Set time stamp at beginning of file.
		echo ":: Timestamp: $(date '+%Y-%m-%dT%T.%N')"
		if ${FLAG_VISUAL_STUDIO} ; then	cat <<EOF
if not defined VisualStudioVersion (
	call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x86_amd64 -vcvars_ver=14.29
	echo :: MSVC v%VisualStudioVersion% vars have been set now.
) else (
	echo :: MSVC v%VisualStudioVersion% vars have been set before.
)
EOF
		fi
		# Configure
		if ${FLAG_CONFIG} ; then
			echo ":: CMake Configure"
			echo "\"${CMAKE_BIN}\" ^"
			echo "-B \"${BUILD_DIR}\" ^"
			echo "-G \"${BUILD_GENERATOR}\" ${CONFIG_OPTIONS} ^"
			for key in "${!CMAKE_DEFS[@]}" ; do
				echo "-D ${key}=\"${CMAKE_DEFS[${key}]}\" ^"
			done
			echo "\"${SOURCE_DIR}\""
		fi
		# Build/Compile
		if ${FLAG_BUILD} ; then
			echo ":: CMake Build Target"
			echo "\"${CMAKE_BIN}\" ^"
			echo "--build \"${BUILD_DIR}\" ^"
			echo "--target \"${TARGET}\" ${BUIlD_OPTIONS} ^"
			if ! ${FLAG_VISUAL_STUDIO} ; then
				echo "-- -j ${CPU_CORES_TO_USE}"
			else
				echo "-- "
			fi
		fi
	} >> "${EXEC_SCRIPT}"
else
	# Start of echo capturing.
	{
		# Set time stamp at beginning of file.
		echo "# Timestamp: $(date '+%Y-%m-%dT%T.%N')"
		# Configure
		if ${FLAG_CONFIG} ; then
			echo "# CMake Configure"
			echo "\"${CMAKE_BIN}\" \\"
			echo "	-B \"${BUILD_DIR}\" \\"
			echo "	-G \"${BUILD_GENERATOR}\" ${CONFIG_OPTIONS} \\"
			for key in "${!CMAKE_DEFS[@]}" ; do
				echo "	-D ${key}=\"${CMAKE_DEFS[${key}]}\" \\"
			done
			echo "	\"${SOURCE_DIR}\""
		fi
		# Build/Compile
		if ${FLAG_BUILD} ; then
			echo "# CMake Build Target"
			echo "\"${CMAKE_BIN}\" \\" ;
			echo "	--build \"${BUILD_DIR}\" \\"
			echo "	--target \"${TARGET}\" ${BUIlD_OPTIONS} \\"
			echo "	-- -j ${CPU_CORES_TO_USE}"
		fi
	} >> "${EXEC_SCRIPT}"
fi

# Execute the script or write it to the log out when debugging.
if ${FLAG_DEBUG} ; then
	WriteLog "=== Script content ${EXEC_SCRIPT} ==="
	WriteLog "$(cat "${EXEC_SCRIPT}")"
	WriteLog "$(printf '=%.0s' {1..45})"
else
	WriteLog "Executing generated script: '${EXEC_SCRIPT}'."
	if ${FLAG_WINDOWS} ; then
		CMD /C "$(cygpath -w "${EXEC_SCRIPT}")"
	else
		exec "${EXEC_SCRIPT}"
	fi
fi
