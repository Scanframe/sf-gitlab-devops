#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dbg_msgs="${DIR}/.$(basename "${0}" ".sh")"

if [[ $# -eq 0 || ! -f "${dbg_msgs}" ]];then
	SCRIPT_DIR="${DIR}" "${DIR}/cmake/lib/bin/version-bump.sh" "${@}"
else
	SCRIPT_DIR="${DIR}" "${DIR}/cmake/lib/bin/version-bump.sh" --dbg-msgs "${dbg_msgs}" "${@}"
fi
