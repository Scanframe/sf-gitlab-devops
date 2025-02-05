#!/bin/bash

# Get the current script directory.
dir="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)"

# When running from Cygwin Windows is the host so Wine is not there.
if [[ "$(uname -o)" != "Cygwin" ]]; then
	# Set the env variables for the script to act on.
	EXECUTABLE_DIR="${dir}/win64${SF_OUTPUT_DIR_SUFFIX}" "${dir}/../cmake/lib/bin/WineExec.sh" "${@}"
else
	# Set the env variables for the script to act on.
	EXECUTABLE_DIR="${dir}/win64${SF_OUTPUT_DIR_SUFFIX}" "${dir}/../cmake/lib/bin/WindowsExec.sh" "${@}"
fi