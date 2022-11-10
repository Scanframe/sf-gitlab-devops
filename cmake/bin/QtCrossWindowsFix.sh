#!/usr/bin/env bash
##
## This script is Qt version and directory locations specific.
## Add links to applications and replaces cmake files referencing exe-files.
## Replacing the cmake files using the Linux QT library.
##

#set -x

# Writes to stderr.
#
function WriteLog()
{
	echo "$@" 1>&2;
}

##
## Install only 64bit compilers.
##

#sudo apt install gcc-mingw-w64-x86-64 g++-mingw-w64-x86-64 gdb-mingw-w64

# Directory of this script.
SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
# Root for the Windows Qt installed MinGW files.
QT_WIN_DIR="${HOME}/lib/QtWin"
# Get the Qt installed directory.
QT_VER_DIR="$(bash "${SCRIPT_DIR}/QtLibDir.sh")"
# Qt version on Linux.
QT_VER="$(basename "${QT_VER_DIR}")"
# Qt lib sub directory build by certain compiler version.
QT_LIB_SUB="mingw_64"
# Directory where the Linux Qt library cmake files are located.
DIR_FROM="${QT_VER_DIR}/gcc_64/lib/cmake"
# Directory where the Windows Qt library cmake files are located.
DIR_TO="${QT_WIN_DIR}/${QT_VER}/${QT_LIB_SUB}/lib/cmake"
# To allow dry run.
#CMD_PF="echo"

if [[ ! -d "${DIR_FROM}" ]]; then
	WriteLog "Directory '${DIR_FROM}' does not exist!"
	exit 1
fi

if [[ ! -d "${DIR_TO}" ]]; then
	WriteLog "Directory '${DIR_TO}' does not exist!"
	exit 1
fi

# Ask for permission
read -rp "Continue [y/N]?" && if [[ $REPLY = [yY] ]]
then
	WriteLog "Starting..."
else
	exit 0
fi

##
## Create symlink in from ~/lib/Qt/6.2.0/gcc_64/libexec to ${QT_WIN_DIR}
##
WriteLog "Create symlink to required '${QT_WIN_DIR}/${QT_VER}/${QT_LIB_SUB}/libexec'"
${CMD_PF} ln -sf "${QT_VER_DIR}/gcc_64/libexec" "${QT_WIN_DIR}/${QT_VER}/${QT_LIB_SUB}/libexec"

##
## Create symlinks or dummies for applications needed in the make files.
##
for fn in "qtpaths" "qmake" \
	"qmldom" "qmllint" "qmlformat" "qmlprofiler" "qmlprofiler" "qmltime" "qmlplugindump" "qmltc" \
	"qmltestrunner"	"androiddeployqt" "androidtestrunner" "windeployqt" "qmlls" ; do
	if [[ ! -f "${QT_VER_DIR}/gcc_64/bin/${fn}" ]] ; then
		WriteLog "Creating dummy to missing binary file to symlink: ${QT_VER_DIR}/gcc_64/bin/${fn}"
		cat <<EOD > "${QT_WIN_DIR}/${QT_VER}/${QT_LIB_SUB}/bin/${fn}"
#!/bin/bash
###
### Dummy executable to fool Windows cmake files.
###
EOD
	else
		WriteLog "Creating symlink to: ${QT_VER_DIR}/gcc_64/bin/${fn}"
		${CMD_PF} ln -sf "${QT_VER_DIR}/gcc_64/bin/${fn}" "${QT_WIN_DIR}/${QT_VER}/${QT_LIB_SUB}/bin"
	fi
done

#
# Replace all cmake files referencing windows EXE-tools.
#
pushd "${DIR_TO}" > /dev/null || exit
declare -a files
while IFS=  read -r -d $'\n'; do
	# Only file with a reverence to a '.exe' in it.
	if grep -qli "\.exe\"" "${REPLY}" ; then
		files+=("${REPLY}")
	fi
done < <(find "${DIR_TO}" -type f -name "*-relwithdebinfo.cmake" -printf "%P\n")
popd > /dev/null || exit

# Iterate through the files.
for fn in "${files[@]}" ; do
	WriteLog "Overwriting CMake files using Linux version: $fn"
	${CMD_PF} cp "${DIR_FROM}/${fn}" "${DIR_TO}/${fn}"
	if [[ $fn == "Qt6CoreTools/Qt6CoreToolsTargets-relwithdebinfo.cmake" ]] ; then
		cat <<EOF >> "${DIR_TO}/${fn}"

# ===================================================================================================
# == Appended from Windows version because it is missed when cross compiling on Linux for Windows. ==
# ===================================================================================================

# Import target "Qt6::windeployqt" for configuration "RelWithDebInfo"
set_property(TARGET Qt6::windeployqt APPEND PROPERTY IMPORTED_CONFIGURATIONS RELWITHDEBINFO)
set_target_properties(Qt6::windeployqt PROPERTIES
  IMPORTED_LOCATION_RELWITHDEBINFO "\${_IMPORT_PREFIX}/bin/windeployqt"
  )

list(APPEND _IMPORT_CHECK_TARGETS Qt6::windeployqt )
list(APPEND _IMPORT_CHECK_FILES_FOR_Qt6::windeployqt "\${_IMPORT_PREFIX}/bin/windeployqt" )

EOF

	fi
done
