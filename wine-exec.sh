#!/usr/bin/env bash
#set -x

# Writes to stderr.
#
function WriteLog()
{
	echo "$@" 1>&2;
}

# Get this script's directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
DIR_ROOT="${DIR}"
# Only when it could find the script.
if [[ -f "${DIR_ROOT}/com/cmake/QtLibDir.sh" ]] ; then
	# Get the Qt installed directory.
	QT_VER_DIR="$(bash "${DIR_ROOT}/com/cmake/QtLibDir.sh" "$(realpath "${HOME}/lib/QtWin")")"
	# Qt version on Linux.
	QT_VER="$(basename "${QT_VER_DIR}")"
	# Qt lib sub directory build by certain compiler version.
	QT_LIB_SUB="mingw_64"
	# Location of Qt DLLs.
	DIR_QT_DLL="$(realpath "${HOME}/lib/QtWin/${QT_VER}/${QT_LIB_SUB}/bin")"
else
	DIR_QT_DLL=""
fi
# Form the binary target directory for cross Windows builds.
DIR_BIN_WIN="$(realpath "${DIR_ROOT}/binwin")"
# Location of MinGW DLLs.
DIR_MINGW_DLL="/usr/x86_64-w64-mingw32/lib"
# Location of MinGW posix DLLs 2.
DIR_MINGW_DLL2="$(ls -d /usr/lib/gcc/x86_64-w64-mingw32/*-posix | sort -V | tail -n 1)"
# Wine command.
WINE_BIN="wine64"

# When nothing is passed show help and wine version.
if [[ -z "$1" ]]; then
	WriteLog \
	"Executes a cross-compiled Windows binary from the target directory.
Usage: $0 <win-exe-in-binwin-dir> [[<options>]...]
Wine Version: $("${WINE_BIN}" --version)

Available exe-files:
$(cd "${DIR_BIN_WIN}" && ls *.exe)
	"
	exit 1
fi

# Check if the command is available/installed.
if ! command -v "${WINE_BIN}" > /dev/null ; then
	WriteLog "Missing '${WINE_BIN}', probably not installed."
	exit 1
fi

# Check if all directories exist.
for DIR_NAME in  "${DIR_BIN_WIN}" "${DIR_MINGW_DLL}" "${DIR_MINGW_DLL2}" "${DIR_QT_DLL}" ; do
	if [[ ! -z "${DIR_NAME}" && ! -d "${DIR_NAME}" ]]; then
		WriteLog "Missing directory '${DIR_NAME}', probably something is not installed."
		exit 1
	fi
done

# Path to executable and its DLL's.
WDIR_EXE_DLL="$(winepath -w "${DIR_BIN_WIN}")"
# Path to mingw runtime DLL's
WDIR_MINGW_DLL="$(winepath -w "${DIR_MINGW_DLL}")"
# Path to mingw runtime DLL's second path.
WDIR_MINGW_DLL2="$(winepath -w "${DIR_MINGW_DLL2}")"
# Path to QT runtime DLL's
WDIR_QT_DLL="$(winepath -w "${DIR_QT_DLL}")"
# Export the path to find the needed DLLs in.
export WINEPATH="${WDIR_EXE_DLL};${WDIR_QT_DLL};${WDIR_MINGW_DLL};${WDIR_MINGW_DLL2}"

# Execute it in its own shell to contain the temp dir change.
# Redirect wine stderr to be ignored.
(cd "${DIR_BIN_WIN}" && wine "$@" 2> /dev/null)
