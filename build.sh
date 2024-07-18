#!/bin/bash

script_dir="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="${script_dir}" "${script_dir}/cmake/lib/bin/Build.sh" "${@}"
