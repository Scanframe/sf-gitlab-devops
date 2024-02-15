#!/bin/bash

SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)"

# Build directory used for Docker to prevent mixing.
BUILD_DIR="${SCRIPT_DIR}/cmake-build/docker"
# Create the docker binary build directory.
mkdir -p "${SCRIPT_DIR}/cmake-build/docker"
# Function which runs the docker build.sh script.
function docker_run {
	local IMG_NAME HOSTNAME
	# Set the image name to be used.
	IMG_NAME="nexus.scanframe.com:8090/gnu-cpp:dev"
	# Hostname for the docker container.
	HOSTNAME="cpp-builder"
	docker run \
		--rm \
		--interactive \
		--tty \
		--privileged \
		--net=host \
		--env LOCAL_USER="$(id -u):$(id -g)" \
		--env DISPLAY \
		--volume "${HOME}/.Xauthority:/home/user/.Xauthority:ro" \
		--volume "${SCRIPT_DIR}:/mnt/project:rw" \
		--volume "${BUILD_DIR}:/mnt/project/cmake-build:rw" \
		--workdir "/mnt/project/" \
		"${IMG_NAME}" "${@}"
}

if [[ $# -eq 0 ]]; then
	# Execute the build script from the Docker image.
	docker_run bash
else
	# Execute the build script from the Docker image.
	docker_run /mnt/project/build.sh "${@}"
fi
