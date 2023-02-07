#!/bin/bash
#set -x

# Define and use some foreground colors values when not running CI-jobs.
if [[ ${CI} ]] ; then
	fg_black=""
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
	local LAST_CH="${LAST_ARG:0-1}"
	local FIRST_CH="${LAST_ARG:0:1}"
	# Set color based on first character of the string.
	case "${FIRST_CH}" in
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
	case "${LAST_CH}" in
		"!")
			local COLOR="${fg_red}"
			;;
		".")
			local COLOR="${fg_cyan}"
			;;
	esac
	echo -n "${COLOR}" 1>&2
	# shellcheck disable=SC2068
	echo ${@} 1>&2
	echo -n "${fg_reset}" 1>&2
}

# When the script directory is not set then
if [[ -z "${SCRIPT_DIR}" ]] ; then
	WriteLog "Environment variable 'SCRIPT_DIR' not set!"
	exit 1
fi

# Change to the scripts directory to operated from when script is called from a different location.
if ! cd "${SCRIPT_DIR}" ; then
	WriteLog "Change to operation directory '${SCRIPT_DIR}' failed!"
	exit 1
fi

# Prints the help to stderr.
#
function ShowHelp()
{
	echo "Usage: ${0} [<options>] <sub-dir> [<target>]
  -d, --debug      : Debug: Show executed commands rather then executing them.
  -r, --required   : Install required Linux packages using debian package manager.
  -c, --clean      : Cleans build targets first (adds build option '--clean-first')
  -C, --wipe       : Wipe clean the targeted cmake-build-<build-type>-<compiler-type>
  -x, --extra      : Add extra apps for exploration during development by setting the custom SF_BUILD_TESTING to 'ON'.
  -t, --test       : Runs the ctest application in the cmake-build-* directory.
  -w, --windows    : Cross compile Windows on Linux using MinGW.
  -m, --make       : Create build directory and makefiles only.
  -b, --build      : Build target only.
  -v, --verbose    : CMake verbose enabled during CMake make (level VERBOSE).
  --toolset <name> : Preferred toolset in Windows (clion,qt,studio) where:
                     qt = QT Group Framework, studio = Microsoft Visual Studio, clion = JetBrains CLion.
  --gitlab-ci      : Simulate CI server by setting CI_SERVER environment variable (disables colors i.e.).
  Where <sub-dir> is the directory used as build root for the CMakeLists.txt in it.
  This is usually the current directory '.'.
  When the <target> argument is omitted it defaults to 'all'.
  The <sub-dir> is also the directory where cmake will create its 'cmake-build-???' directory.

  Examples:
    Make/Build all projects: ${0} -mb .
    Same as above: ${0} -mb . all
    Clean all projects: ${0} . clean
    Install all projects: ${0} . install
    Show all projects to be build in the current directory: ${0} . help
    Build 'com' sub-project in the current directory: ${0} -b . com
    Build all projects in the 'com' directory: ${0} -b com
	"
}

# Amount of CPU cores to use for compiling.
CPU_CORES_TO_USE="$(($(nproc --all) -1))"
# Get the target OS.
SF_TARGET_OS="$(uname -o)"

# Install needed packages depending in the Windows(cygwin) or Linux environment it is called from.
#
function InstallPackages()
{
	WriteLog "About to install required packages for ($1)..."
	if [[ "$1" == "GNU/Linux/x86_64" || "$1" == "GNU/Linux/arm64" || "$1" == "GNU/Linux/aarch64" ]] ; then
		if ! sudo apt install --install-recommends cmake gcc g++ doxygen graphviz libopengl0 libgl1-mesa-dev libxkbcommon-dev \
			libxkbfile-dev libvulkan-dev libssl-dev exiftool ; then
			WriteLog "Failed to install 1 or more packages!"
			exit 1
		fi
	elif [[ "$1" == "GNU/Linux/x86_64/Cross" ]] ; then
		if ! sudo apt install --install-recommends mingw-w64 cmake doxygen graphviz wine exiftool ; then
			WriteLog "Failed to install 1 or more packages!"
			exit 1
		fi
	elif [[ "$1" == "Cygwin/x86_64" ]] ; then
		if ! apt-cyg install doxygen graphviz perl-Image-ExifTool ; then
			WriteLog "Failed to install 1 or more Cygwin packages (Try the Cygwin setup tool when elevation is needed) !"
			exit 1
		fi
	else
		# shellcheck disable=SC2128
		WriteLog "Unknown '$1' environment selection passed to function '${FUNCNAME}' !"
	fi
}

# Returns the version number of the git version tag.
#
function GetGitTagVersion()
{
	local tag;
	tag="$(git describe --tags --dirty --match "v*")"
	if [[ $? && ! "${tag}" =~ ^v([0-9]+\.[0-9]+\.[0-9]).* ]] ; then
		echo "0.0.0"
	else
		echo "${BASH_REMATCH[1]}"
	fi
}

# Detect windows using the cygwin 'uname' command.
if [[ "${SF_TARGET_OS}" == "Cygwin" ]] ; then
	WriteLog "- Windows OS detected through Cygwin shell"
	export SF_TARGET_OS="Cygwin"
	FLAG_WINDOWS=true
	# Set the directory the local QT root.
	# shellcheck disable=SC2012
	LOCAL_QT_ROOT="$( (ls -d /cygdrive/?/Qt | tail -n 1) 2> /dev/null )"
	if [[ -d "$LOCAL_QT_ROOT" ]] ; then
		WriteLog "- Found QT in '${LOCAL_QT_ROOT}'"
	fi
	# Create temporary file for executing cmake.
	EXEC_SCRIPT="$(mktemp --suffix .bat)"
elif [[ "${SF_TARGET_OS}" == "Msys" ]] ; then
	WriteLog "- Windows OS detected through Msys shell"
	export SF_TARGET_OS="Msys"
	FLAG_WINDOWS=true
	# Set the directory the local QT root.
	# shellcheck disable=SC2012
	LOCAL_QT_ROOT="$( (ls -d /?/Qt | tail -n 1) 2> /dev/null )"
	if [[ -d "$LOCAL_QT_ROOT" ]] ; then
		WriteLog "- Found QT in '${LOCAL_QT_ROOT}'"
	fi
	# Create temporary file for executing cmake.
	EXEC_SCRIPT="$(mktemp --suffix .bat)"
elif [[ "${SF_TARGET_OS}" == "GNU/Linux" ]] ; then
	WriteLog "- Linux detected"
	export SF_TARGET_OS="GNU/Linux"
	FLAG_WINDOWS=false
	# Set the directory the local QT root.
	LOCAL_QT_ROOT="${HOME}/lib/Qt"
	# Check if it exists.
	if [[ -d "${LOCAL_QT_ROOT}" ]] ; then
		WriteLog "- QT found in '${LOCAL_QT_ROOT}'"
	else
		LOCAL_QT_ROOT=""
	fi
	# Create temporary file for executing cmake.
	EXEC_SCRIPT="$(mktemp --suffix .sh)"
	chmod +x "${EXEC_SCRIPT}"
else
	WriteLog "Targeted OS '${SF_TARGET_OS}' not supported!"
fi

# No arguments at show help and bailout.
if [[ $# == 0 ]]; then
	ShowHelp
	exit 1
fi

# Initialize arguments and switches.
FLAG_DEBUG=false
FLAG_CONFIG=false
FLAG_BUILD=false
FLAG_TEST=false
FLAG_WIPE_DIR=false
FLAG_PACKAGE=false
# Flag for cross compiling for Windows from Linux.
FLAG_CROSS_WINDOWS=false

# Selected toolset where empty is to auto select.
TOOLSET=""
# Toolset cmake binary and directory.
declare -A TOOLSET_NAME
declare -A TOOLSET_CMAKE
declare -A TOOLSET_CTEST
# Directory location of the toolsets.
declare -A TOOLSET_DIR
# Shell command to call before make or build.
declare -A TOOLSET_PRE

# Initialize the config options.
CONFIG_OPTIONS=""
# Initialize the build options.
BUIlD_OPTIONS=
# Initialize the target.
TARGET="all"
# Additional Cmake make command line options.
declare -A CMAKE_DEFS
# Default profile is debug.
CMAKE_DEFS['CMAKE_BUILD_TYPE']='Debug'
# Default build dynamic libraries (in Windows the qt toolset causes a runtime error with the Catch2 DLL).
CMAKE_DEFS['__disabled__BUILD_SHARED_LIBS']='ON'
# Color buildsystem messages by default.
CMAKE_DEFS['CMAKE_COLOR_DIAGNOSTICS']='ON'
# Parse options.
TEMP=$(getopt -o 'dhcCbtmwrvx' --long \
	'toolset:,help,debug,verbose,extra,required,wipe,clean,make,build,test,windows,studio,gitlab-ci' \
	-n "$(basename "${0}")" -- "$@")
# shellcheck disable=SC2181
if [[ $? -ne 0 ]] ; then
	ShowHelp
	exit 1
fi
eval set -- "$TEMP"
unset TEMP
while true; do
	case $1 in

		--toolset)
			TOOLSET="$2"
			if [[ "${TOOLSET}" =~ [^(clion|qt|studio)$] ]] ; then
				WriteLog "Toolset selection '${TOOLSET}' invalid!"
				ShowHelp
				exit 1
			fi
			shift 2
			continue
			;;

		--gitlab-ci)
			export CI_SERVER="yes"
			shift 1
			continue
			;;

		-h|--help)
			ShowHelp
			exit 0
			;;

		-d|--debug)
			WriteLog "- Script debugging is enabled"
			FLAG_DEBUG=true
			shift 1
			continue
			;;

		-v|--verbose)
			WriteLog "- CMake verbose level set"
			CMAKE_DEFS['CMAKE_MESSAGE_LOG_LEVEL']='VERBOSE'
			# Makes add_custom command show its command output.
			CMAKE_DEFS['VERBOSE']='1'
			shift 1
			continue
			;;

		-r|--required)
			if [[ ${FLAG_CROSS_WINDOWS} == true ]] ; then
				InstallPackages "${SF_TARGET_OS}/$(uname -m)/Cross"
			else
				InstallPackages "${SF_TARGET_OS}/$(uname -m)"
			fi
			exit 0
			;;

		-C|--wipe)
			WriteLog "- Wipe clean targeted build directory commenced"
			# Set the flag to wipe the build directory first.
			FLAG_WIPE_DIR=true
			shift 1
			continue
			;;

		-c|--clean)
			WriteLog "- Clean first enabled"
			BUIlD_OPTIONS="${BUIlD_OPTIONS} --clean-first"
			shift 1
			continue
			;;

		-m|--make)
			WriteLog "- Create build directory and makefiles"
			FLAG_CONFIG=true
			shift 1
			continue
			;;

		-b|--build)
			WriteLog "- Build the given target"
			FLAG_BUILD=true
			shift 1
			continue
			;;

		-x|--extra)
			WriteLog "- Including test/extra builds using custom 'SF_BUILD_TESTING' flag"
			CMAKE_DEFS['SF_BUILD_TESTING']='ON'
			shift 1
			continue
			;;

		-t|--test)
			WriteLog "- Running tests enabled"
			FLAG_TEST=true
			shift 1
			continue
			;;

		-w|--windows)
			if ! ${FLAG_WINDOWS} ; then
				WriteLog "- Cross compile for Windows"
				FLAG_CROSS_WINDOWS=true
			else
				WriteLog "Ignoring Cross compile when in Windows"
			fi
			shift 1
			continue
			;;

		'--')
			shift
			break
		;;

		*)
			echo "Internal error on argument (${1}) !" >&2
			exit 1
		;;
	esac
done

# Get the arguments in an array.
argument=()
while [ $# -gt 0 ] && ! [[ "$1" =~ ^- ]]; do
	argument=("${argument[@]}" "$1")
	shift
done

# First argument is mandatory.
if [[ -z "${argument[0]}" ]]; then
	WriteLog "Mandatory target (sub-)directory not passed!"
	ShowHelp
	exit 1
fi

# Initialize variable for the source sub directory.
SOURCE_DIR="${argument[0]}"
# Initialize the first part of the build directory depending on the build type (Debug, Release etc.).
BUILD_SUBDIR="cmake-build-${CMAKE_DEFS['CMAKE_BUILD_TYPE'],,}"

#
# Assemble CMake build directory depending on OS and passed options.
#
# When Windows is the OS running Cygwin.
if ${FLAG_WINDOWS} ; then
	# Set the build-dir for the compiler based on toolset in Windows.
	if [[ "${TOOLSET}" == "studio" ]] ; then
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
if [[ "${TARGET}" == @(help|install) && ${FLAG_WIPE_DIR} == true ]] ;  then
	FLAG_WIPE_DIR=false
	WriteLog "Wiping clean with target '${TARGET}' not possible!"
fi

# When the Wipe flag is set.
if ${FLAG_WIPE_DIR} ; then
	WriteLog "- Wiping clean build-dir '${RM_SUBDIR}/${BUILD_SUBDIR}'"
	RM_CMD="rm --verbose --recursive --one-file-system --interactive=never"
	RM_SUBDIR="${SCRIPT_DIR}"
	if [[ -n "${SOURCE_DIR}" && "${SOURCE_DIR}" && "${SOURCE_DIR}" != "." ]] ; then
		RM_SUBDIR="${RM_SUBDIR}/${SOURCE_DIR}"
	fi
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
			${RM_CMD} "${RM_SUBDIR}/${BUILD_SUBDIR}/"..?* "${RM_SUBDIR}/${BUILD_SUBDIR}/".[!.]* "${RM_SUBDIR}/${BUILD_SUBDIR}/"* > /dev/null 2>&1
		fi
	fi
fi

# Configure cmake location.
if ${FLAG_WINDOWS} ; then
	# Order of preference
	TOOLSET_ORDER="qt clion studio native"
	# Actual order of preference is reversed due the bash array.
	TOOLSET_NAME['native']="Native Cygwin compiler"
	TOOLSET_NAME['clion']="JetBrains CLion accompanied MinGW"
	TOOLSET_NAME['qt']="QT Platform accompanied MinGW"
	TOOLSET_NAME['studio']="Microsoft Visual Studio accompanied MSVC"
	# Try adding CLion cmake.
	TOOLSET_CMAKE['native']="$(which cmake)"
	TOOLSET_CTEST['native']="$(which ctest)"
	# shellcheck disable=SC2154
	TOOLSET_DIR['native']="/usr/bin"
	TOOLSET_PRE['native']=""
	# shellcheck disable=SC2154
	# shellcheck disable=SC2012
	TOOLSET_CMAKE['clion']="$(ls -d "$(cygpath -u "${ProgramW6432}")/JetBrains/CLion"*/bin/cmake/win/bin/cmake.exe 2> /dev/null | tail -n 1)"
	# shellcheck disable=SC2012
	TOOLSET_CTEST['clion']="$(ls -d "$(cygpath -u "${ProgramW6432}")/JetBrains/CLion"*/bin/cmake/win/bin/ctest.exe 2> /dev/null | tail -n 1)"
	# shellcheck disable=SC2012
	TOOLSET_DIR['clion']="$(ls -d "$(cygpath -u "${ProgramW6432}")/JetBrains/CLion"*/bin/mingw/bin | tail -n 1)"
	TOOLSET_PRE['clion']=""
	# Try adding QT cmake.
	TOOLSET_CMAKE["qt"]="$(ls -d "${LOCAL_QT_ROOT}/Tools/CMake_64/bin/cmake.exe" 2> /dev/null)"
	TOOLSET_CTEST["qt"]="$(ls -d "${LOCAL_QT_ROOT}/Tools/CMake_64/bin/ctest.exe" 2> /dev/null)"
	# shellcheck disable=SC2012
	TOOLSET_DIR['qt']="$(ls -d "${LOCAL_QT_ROOT}/Tools/mingw"*"/bin" | sort --version-sort | tail -n 1)"
	TOOLSET_PRE['qt']=""
	# Try adding Visual Studio cmake.
	TOOLSET_CMAKE['studio']="$(ls -d "$(cygpath -u "${ProgramW6432}")/Microsoft Visual Studio/"*/*"/Common7/IDE/CommonExtensions/Microsoft/CMake/CMake/bin/cmake.exe" 2> /dev/null )"
	TOOLSET_CTEST['studio']="$(ls -d "$(cygpath -u "${ProgramW6432}")/Microsoft Visual Studio/"*/*"/Common7/IDE/CommonExtensions/Microsoft/CMake/CMake/bin/ctest.exe" 2> /dev/null )"
	# Toolset directory for Visual studio is set using a batch file provided by visual studio.
	# shellcheck disable=SC2012
	TOOLSET_DIR['studio']="/usr/bin"
	TOOLSET_PRE['studio']="if not defined VisualStudioVersion ( call \"$(cygpath -w "$(ls -d "$(cygpath -u "${ProgramW6432}")/Microsoft Visual Studio/"*/*"/VC/Auxiliary/Build/vcvarsall.bat")")\" x64 -vcvars_ver=14 )"
	# Show debug info on found toolsets.
	if ${FLAG_DEBUG} ; then
		for key in "${!TOOLSET_NAME[@]}" ; do
			WriteLog "= TOOLSET_CMAKE[${key}]=${TOOLSET_CMAKE[${key}]}"
			WriteLog "= TOOLSET_CTEST[${key}]=${TOOLSET_CTEST[${key}]}"
			WriteLog "= TOOLSET_DIR[${key}]=${TOOLSET_DIR[${key}]}"
			WriteLog "= TOOLSET_PRE[${key}]=${TOOLSET_PRE[${key}]}"
		done
	fi
	# When not set select the toolset select the first that is set according the preferred toolset order.
	if [[ -z "${TOOLSET}" ]] ; then
		for key in ${TOOLSET_ORDER} ; do
			# Check if this entry was found.
			if [[ -n "${TOOLSET_CMAKE[${key}]}" ]] ; then
				WriteLog "- Selecting toolset: ${TOOLSET_NAME[${key}]}"
				TOOLSET="${key}"
				break
			fi
		done
	else
		# Check if the obligatory toolset is present.
		if [[ -z "${TOOLSET_CMAKE[${TOOLSET}]}" ]] ; then
			# shellcheck disable=SC2154
			WriteLog "Requested toolset '${TOOLSET}' is not available!"
			exit 1
		fi
	fi
	# Convert to windows path format.
	CMAKE_BIN="$(cygpath -w "${TOOLSET_CMAKE[${TOOLSET}]}")"
	# Convert to windows path format.
	CTEST_BIN="$(cygpath -w "${TOOLSET_CTEST[${TOOLSET}]}")"
	# Convert the prefix path to Windows format.
	PATH_PREFIX="$(cygpath -w "${TOOLSET_DIR[${TOOLSET}]}")"
	# Assemble the Windows build directory.
	BUILD_DIR="$(cygpath -aw "${SCRIPT_DIR}/${BUILD_SUBDIR}")"
	# Convert the source path to Windows format.
	SOURCE_DIR="$(cygpath -aw "${SOURCE_DIR}")"
	# Visual Studio wants of course wants something else again.
	if [[ "${TOOLSET}" == "studio" ]] ; then
		BUILD_GENERATOR="CodeBlocks - NMake Makefiles"
		#BUILD_GENERATOR="CodeBlocks - Ninja"
	else
		BUILD_GENERATOR="CodeBlocks - MinGW Makefiles"
	fi
	# Report used cmake and its version.
	WriteLog "- CMake '${CMAKE_BIN}' $("$(cygpath -u "${CMAKE_BIN}")" --version | head -n 1)"
	WriteLog "- CTest '${CTEST_BIN}' $("$(cygpath -u "${CTEST_BIN}")" --version | head -n 1)"
else
	# Try to use the CLion installed version of the cmake command.
	CMAKE_BIN="${HOME}/lib/clion/bin/cmake/linux/bin/cmake"
	CTEST_BIN="${HOME}/lib/clion/bin/cmake/linux/bin/ctest"
	if ! command -v "${CMAKE_BIN}" &> /dev/null ; then
		# Try to use the Qt installed version of the cmake command.
		CMAKE_BIN="${LOCAL_QT_ROOT}/Tools/CMake/bin/cmake"
		CTEST_BIN="${LOCAL_QT_ROOT}/Tools/CMake/bin/ctest"
		if ! command -v "${CMAKE_BIN}" &> /dev/null ; then
			CMAKE_BIN="$(which cmake)"
			CTEST_BIN="$(which ctest)"
		fi
	fi
	BUILD_DIR="${SCRIPT_DIR}/${BUILD_SUBDIR}"
	BUILD_GENERATOR="CodeBlocks - Unix Makefiles"
	WriteLog "- CMake '$(realpath "${CMAKE_BIN}")' $(${CMAKE_BIN} --version | head -n 1)"
	WriteLog "- CTest '$(realpath "${CTEST_BIN}")' $(${CTEST_BIN} --version | head -n 1)"
fi

# Build execution script depending on the OS.
if ${FLAG_WINDOWS} ; then
	# Start of echo capturing.
	{
		echo '@echo off'
		# Set time stamp at beginning of file.
		echo ":: Timestamp: $(date '+%Y-%m-%dT%T.%N')"
		if [[ "${TOOLSET}" == "studio"  && ($FLAG_CONFIG == true || $FLAG_BUILD == true) ]] ; then
			echo "${TOOLSET_PRE[${TOOLSET}]}"
		fi
		echo -e "\n:: === General Section ==="
		# Add the prefix to the path when non empty.
		if [[ -n "${PATH_PREFIX}" && "${TOOLSET}" != "studio" ]] ; then
			echo ":: Set path prefix for tools to be found."
			echo "PATH=${PATH_PREFIX};%PATH%"
		fi
		# Configure
		if ${FLAG_CONFIG} ; then
			echo -e "\n:: === CMake Configure Section ==="
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
			echo -e "\n:: === CMake Build Section ==="
			echo "\"${CMAKE_BIN}\" ^"
			echo "--build \"${BUILD_DIR}\" ^"
			echo "--target \"${TARGET}\" ${BUIlD_OPTIONS} ^"
			echo "--parallel ${CPU_CORES_TO_USE}"
		fi
		# Run all declared Tests with ctest
		if ${FLAG_TEST} ; then
			echo -e "\n:: === CTest Section ==="
			echo "\"${CTEST_BIN}\" ^"
			echo "--test-dir \"${BUILD_DIR}\""
		fi
	} >> "${EXEC_SCRIPT}"
else
	# Start of echo capturing.
	{
		# Set time stamp at beginning of file.
		echo "# Timestamp: $(date '+%Y-%m-%dT%T.%N')"
		echo -e "\n# === General Section ==="
		# Add the prefix to the path when non empty.
		if [[ -n "${PATH_PREFIX}" ]] ; then
			echo "# Set path prefix for tools to be found."
			# shellcheck disable=SC2154
			echo "path=${PATH_PREFIX};${path}"
		fi
		# Configure
		if ${FLAG_CONFIG} ; then
			echo -e "\n# === CMake Configure Section ==="
			echo "'${CMAKE_BIN}' \\"
			echo "-B '${BUILD_DIR}' \\"
			echo "-G '${BUILD_GENERATOR}' ${CONFIG_OPTIONS} \\"
			for key in "${!CMAKE_DEFS[@]}" ; do
				echo "-D ${key}='${CMAKE_DEFS[${key}]}' \\"
			done
			echo "	\"${SOURCE_DIR}\""
		fi
		# Build/Compile
		if ${FLAG_BUILD} ; then
			echo -e "\n# === CMake Build Section ==="
			echo "\"${CMAKE_BIN}\" \\" ;
			echo "--build \"${BUILD_DIR}\" \\"
			echo "--target \"${TARGET}\" ${BUIlD_OPTIONS} \\"
			echo "--parallel ${CPU_CORES_TO_USE}"
		fi
		# Run all declared Tests with ctest
		if ${FLAG_TEST} ; then
			echo -e "\n# === CTest Section ==="
			echo "\"${CTEST_BIN}\" \\"
			echo "--test-dir \"${BUILD_DIR}\""
		fi
	} >> "${EXEC_SCRIPT}"
fi

# Execute the script or write it to the log out when debugging.
if ${FLAG_DEBUG} ; then
	WriteLog "=== Script content ${EXEC_SCRIPT} ==="
	# shellcheck disable=SC2028
	echo "$(cat "${EXEC_SCRIPT}")\n\n"
	WriteLog "$(printf '=%.0s' {1..45})"
else
	WriteLog "- Executing generated script: '${EXEC_SCRIPT}'"
	if ${FLAG_WINDOWS} ; then
		CMD "/C $(cygpath -w "${EXEC_SCRIPT}")"
	else
		exec "${EXEC_SCRIPT}"
	fi
fi

# Cleanup generate script afterwards.
if [[ -f "${EXEC_SCRIPT}" ]] ; then
	rm "${EXEC_SCRIPT}"
fi
