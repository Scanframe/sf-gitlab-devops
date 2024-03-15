#!/bin/bash

DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="${DIR}" "${DIR}/cmake/lib/bin/Build.sh" "${@}"
