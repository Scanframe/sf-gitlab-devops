#!/bin/bash

# Get the current script directory.
DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)"
# Set the env variables for the script to act on.
EXECUTABLE_DIR="${DIR}/lnx64" LD_LIBRARY_PATH="${DIR}/lnx64/lib" "${DIR}/../cmake/lib/bin/LinuxExec.sh" "${@}"
