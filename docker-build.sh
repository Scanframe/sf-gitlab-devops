#!/bin/bash

# Bail out on first error.
set -e

# Get the script directory.
script_dir="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)"
# Build directory used for Docker to prevent mixing.
build_dir="${script_dir}/cmake-build/docker"
# Set the image name to be used.
img_name="nexus.scanframe.com/gnu-cpp:dev"
# Create the docker binary build directory.
mkdir -p "${script_dir}/cmake-build/docker"

# Function which runs the docker build.sh script in the container.
function docker_run {
	docker run \
		--rm \
		--interactive \
		--tty \
		--privileged \
		--net=host \
		--env LOCAL_USER="$(id -u):$(id -g)" \
		--env DISPLAY \
		--volume "${HOME}/.Xauthority:/home/user/.Xauthority:ro" \
		--volume "${script_dir}:/mnt/project:rw" \
		--volume "${build_dir}:/mnt/project/cmake-build:rw" \
		--workdir "/mnt/project/" \
		"${img_name}" "${@}"
}

# When no arguments are given run bash from within the container.
if [[ $# -eq 0 ]]; then
	echo "Same as 'build.sh' script but running from Docker image '${img_name}'.

To pull the latest image for use the 'pull' command explicitly for this script.
Now entering container using bash to allow inspection.
"
	# Execute the build script from the Docker image.
	docker_run bash
else
	# When only pull has been passed pull the latest image.
	if [[ $# -eq 1  && "${1}" == "pull" ]]; then
		docker pull "${img_name}"
	else
		# Execute the build script from the Docker image.
		docker_run /mnt/project/build.sh "${@}"
	fi
fi
