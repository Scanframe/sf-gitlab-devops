#!/usr/bin/env bash

# Exit at first error.
set -e

# Check if the needed cmds are installed.
cmds=("git" "sed" "wget")
for cmd in "${cmds[@]}"; do
	if ! command -v "${cmd}" >/dev/null; then
		WriteLog "Missing command '${cmd}' for this script!"
		exit 1
	fi
done

# Directory to clone into.
clone_dir="gitlab-devops"

# Check if the directory exists and bailout when it does.
if [[ -d "${clone_dir}" ]]; then
	echo "Directory '${clone_dir}' already exists!"
	exit 1
fi

# Do not use option '--recurse-submodules' since the default is not using github.
git clone "https://github.com/Scanframe/sf-gitlab-devops.git" "${clone_dir}"

# Move into the cloned directory.
cd "${clone_dir}"

# Check if the backup file exists.
if [[ -f .gitmodules.bak ]]; then
	echo "File '.gitmodules.bak' already exists!"
	exit 1
fi

# Replace the default URL using.
sed --in-place=".bak" 's|https://git\.scanframe\.com/library/cmake-lib\.git|https://github\.com/Scanframe/sf-cmake\.git|' .gitmodules

# Recursively update or initialize submodules.
git submodule update --init --recursive
