#!/bin/bash

# Get the current script directory.
dir="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)"
# Set the env variables for the script to act on.
EXECUTABLE_DIR="${dir}/lnx64${SF_OUTPUT_DIR_SUFFIX}" LD_LIBRARY_PATH="${EXECUTABLE_DIR}/lib" "${dir}/../cmake/lib/bin/LinuxExec.sh" "${@}"
