#!/bin/bash
#set -x

# Get the bash script directory.
#SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"

# Set the directory the local QT root expected.
if [[ -z "$1" ]] ; then
	LOCAL_QT_ROOT="${HOME}/lib/Qt"
else
	LOCAL_QT_ROOT="$1"
fi

# Writes to stderr.
#
function WriteLog()
{
	echo "$@" 1>&2;
}

# Find newest local Qt version directory.
#
function GetLocalQtDir()
{
	local LocalQtDir=""
	# Check is the Qt install can be found.
	if [[ ! -d "${LOCAL_QT_ROOT}" ]] ; then
		WriteLog "Qt install directory or symbolic link '${LOCAL_QT_ROOT}' was not found!"
		exit 1
	fi
	# Find the newest Qt library installed.
	LocalQtDir="$(find "${LOCAL_QT_ROOT}/" -maxdepth 1 -type d -regex ".*\/Qt\/[0-9]\\.[0-9]+\\.[0-9]+$" | sort --reverse --version-sort | head -n 1)"
	if [[ -z "${LocalQtDir}" ]] ; then
		WriteLog "Could not find local installed Qt directory."
		exit 1
	fi
	if [[ "$(uname -s)" == "CYGWIN_NT"* ]]; then
		LocalQtDir="$(cygpath --mixed "${LocalQtDir}")"
	fi
	echo -n "${LocalQtDir}"
}



if ! GetLocalQtDir ; then
	exit 1
fi 
