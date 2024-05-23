#!/bin/bash 

# Bail out on first error.
set -e
# Get the script directory.
SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}")" && pwd)"
# Build directory used for Docker to prevent mixing.
BUILD_DIR="${SCRIPT_DIR}/cmake-build/docker"
# Set the image name to be used.
IMG_NAME="nexus.scanframe.com:8090/gnu-cpp:dev"
# Hostname for the docker container.
HOSTNAME="cpp-builder"
# Create the docker binary build directory.
mkdir -p "${SCRIPT_DIR}/cmake-build/docker"

if [[ "$(uname -s)" != "CYGWIN_NT"* ]]; then
	# Function which runs the docker build.sh script.
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
			--volume "${SCRIPT_DIR}:/mnt/project:rw" \
			--volume "${BUILD_DIR}:/mnt/project/cmake-build:rw" \
			--workdir "/mnt/project/" \
			"${IMG_NAME}" "${@}"
	}
else
	# Function which runs the docker build.sh script.
	function docker_run {
		docker run \
			--rm \
			--interactive \
			--privileged \
			--net=host \
			--env LOCAL_USER="$(id -u):$(id -g)" \
			--env DISPLAY \
			--volume "${HOME}/.Xauthority:/home/user/.Xauthority:ro" \
			--volume "$(cygpath -w "${SCRIPT_DIR}"):/mnt/project:rw" \
			--volume "$(cygpath -w "${BUILD_DIR}"):/mnt/project/cmake-build:rw" \
			--workdir "/mnt/project/" \
			"${IMG_NAME}" "${@}"
	}
fi


if [[ $# -eq 0 ]]; then
	echo "Same as 'build.sh' script but running from Docker image '${IMG_NAME}'.

To pull the latest image for use the 'pull' command explicitly for this script.
Now entering container using bash to allow inspection.
"
	# Execute the build script from the Docker image.
	docker_run bash
else
	# When only pull has been passed pull the latest image.
	if [[ $# -eq 1  && "${1}" == "pull" ]]; then
		docker pull "${IMG_NAME}"
	fi
	# Execute the build script from the Docker image.
	docker_run /mnt/project/build.sh "${@}"
fi
