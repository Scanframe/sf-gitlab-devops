#!/bin/bash

# Add win64 subdirectory so the WineExec.sh knows where to look for the executables.
EXECUTABLE_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)/lnx64"
LD_LIBRARY_PATH="${EXECUTABLE_DIR}/lib"
# Import the script to prepare environment variables for executing the Windows executable.
source "${EXECUTABLE_DIR}/../../cmake/lib/bin/LinuxExec.sh"


