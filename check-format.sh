#!/usr/bin/env bash

# Bailout on first error.
set -e

# Get the scripts directory.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
arguments=()
# Add quiet option when call from the Git pre-commit hook.
if [[ "$(ps -o comm= $PPID)" == "pre-commit" ]]; then
	# Makes the WriteLog function not use colors.
	export TERM="dumb"
	# Report only problems and totals.
	arguments+=('--quiet')
	# Add git-diff noticed files only for checking.
	arguments+=('--git-hook')
# Check if called from a GitLab pipeline for a merge request.
elif [[ -n "${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}" ]]; then
	arguments+=('--quiet')
	arguments+=('--branch' "${CI_MERGE_REQUEST_TARGET_BRANCH_NAME}")
# When this script is called manually.
else
	echo "Redirection to script 'cmake/lib/bin/clang-format.sh'.

This script is to be called from a git 'pre-commit' hook or
when an Gitlab merge-request is pipeline is running.
"
	# Add the directories to check for this repository.
	arguments+=("${@}")
fi
# Make this script directory the current one.
pushd "${script_dir}" >/dev/null
# Execute the script for checking.
cmake/lib/bin/clang-format.sh "${arguments[@]}"
# Return to the initial directory.
popd >/dev/null
