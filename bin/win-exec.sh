#!/bin/bash

# Get the current script directory.
DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)"
# Set the env variables for the script to act on.
EXECUTABLE_DIR="${DIR}/win64" "${DIR}/../cmake/lib/bin/WineExec.sh" "${@}"
