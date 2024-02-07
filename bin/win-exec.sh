#!/bin/bash

# Add win64 subdirectory so the WineExec.sh knows where to look for the executables.
EXECUTABLE_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)/win64"
# Import the script to prepare environment variables for executing the Windows executable.
source "${EXECUTABLE_DIR}/../../cmake/lib/bin/WineExec.sh"
