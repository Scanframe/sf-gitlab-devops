#!/bin/bash

# Get the current script directory.
dir="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)"
# Set the env variables for the script to act on.
EXECUTABLE_DIR="${dir}/win64${SF_OUTPUT_DIR_SUFFIX}" "${dir}/../cmake/lib/bin/WineExec.sh" "${@}"
