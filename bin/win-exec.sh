#!/bin/bash

# Get the current script directory.
dir="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)"
# Set the env variables for the script to act on.
EXECUTABLE_DIR="${dir}/win64" "${dir}/../cmake/lib/bin/WineExec.sh" "${@}"
