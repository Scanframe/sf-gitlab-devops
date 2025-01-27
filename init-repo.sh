#!/bin/bash

set -e

# Get the scripts run directory weather it is a symlink or not.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Move to the script directory which is the root of repository.
cd "${script_dir}"

# Check if the needed cmds are installed.
cmds=("git")
# For Cygwin an additional command are needed.
[[ "$(uname -o)" == "Cygwin " ]] && cmds+=("symlink2native.sh")

for cmd in "${cmds[@]}"; do
	if ! command -v "${cmd}" >/dev/null; then
		WriteLog "Missing command '${cmd}' for this script!"
		exit 1
	fi
done

# Fix the submodule URL for GitHub cloned repo.
if [[ "$(dirname "$(git config remote.origin.url)")" == 'https://github.com/Scanframe' ]]; then
	echo "Fixing cmake library submodule URL."
	git config --file .gitmodules submodule.cmake/lib.url 'https://github.com/Scanframe/sf-cmake.git'
fi

echo "Git: Updating submodules recursively."
# Retrieve the related repository submodules.
git submodule update --init --recursive
# When running from Windows convert symlinks in the root of the repository.
if [[ "$(uname -o)" == "Cygwin " ]]; then
	echo "Windows needed junction to symlink conversion."
	# Convert all symlinks into Windows native symlinks as a workaround for having Git not producing
	# native symlinks correctly with 'CYGWIN=winsymlinks:nativestrict' having set but only junctions.
	symlink2native.sh .
fi
