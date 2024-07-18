#!/bin/bash

# Get the current script directory.
dir="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)"
# Set the env variables for the script to act on.
EXECUTABLE_DIR="${dir}/lnx64" LD_LIBRARY_PATH="${dir}/lnx64/lib" "${dir}/../cmake/lib/bin/LinuxExec.sh" "${@}"
