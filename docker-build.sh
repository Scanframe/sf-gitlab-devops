#!/bin/bash

# Bail out on first error.
set -e

# Get the script directory.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get the project root and subdirectory.
project_subdir="$(basename "${script_dir}")"
# Set the image name to be used.
img_name="nexus.scanframe.com/gnu-cpp:dev"
# Set container name to be used.
container_name="cpp_builder"
# Hostname for the docker container.
hostname="$(hostname)"

# Assemble the Docker default options to run.
options=()
# Remove container and associated anonymous volumes.
options+=(--rm)
# Not needed when detached (daemon) running.
options+=(--tty)
options+=(--interactive)
# Options to allow mounting fuse-zip from entry point.
options+=(--device /dev/fuse)
options+=(--cap-add SYS_ADMIN)
options+=(--security-opt apparmor:unconfined)
# Option 'privileged' when the 3 above are not working as it should.
#options+=(--privileged)
# Not really needed.
options+=(--hostname "${hostname}")
# The Entrypoint script requires to be executed as root although not actual
# needed is prevents nesting sudo commands.
options+=(--user 0:0)
# The Entrypoint uses LOCAL_USER variable to set the 'uid' and 'gid' of the user 'user' and its home directory.
options+=(--env LOCAL_USER="$(id -u):$(id -g)")
# Options needed to forward X11 server from the host.
options+=(--network host)
options+=(--env DISPLAY="${DISPLAY}")
options+=(--volume "${HOME}/.Xauthority:/home/user/.Xauthority:ro")
# Mount the project sub directory into the project directory like
# CLion does using a Docker toolchain.
options+=(--volume "${script_dir}:/mnt/project/${project_subdir}:rw")
# Check if the build directory offset has been set for separate build dir offset.
if [[ -n "${DOCKER_BUILD}" ]]; then
	# Build directory used for Docker builds.
	build_dir="${script_dir}/cmake-build/docker"
	# Create the special docker binary build directory.
	mkdir --parents "${build_dir}"
	options+=(--volume "${build_dir}:/mnt/project/${project_subdir}/cmake-build:rw")
fi
options+=(--workdir "/mnt/project/${project_subdir}/")

# Function which runs the docker build.sh script in the container.
function docker_run {
	docker run "${options[@]}" "${img_name}" "${@}"
}

# Check if running detached.
function is_detached {
	cntr_id="$(docker ps --filter name="${container_name}" --quiet)"
	[[ -n "${cntr_id}" ]] || return 1 && return 0
}

if [[ $# -eq 0 ]]; then
	# When no arguments are given run bash from within the container.
	echo "Same as 'build.sh' script but running from Docker image '${img_name}' but allows Docker specific commands.

Usage: cmake/lib/bin/docker-build.sh [command] <args...>
  pull      : Pulls the docker image '${img_name}' from the Docker registry.
  run       : Runs a command as user 'user' in the container using Docker command
              'run' or 'exec' depending on a running container in the background.
  detach    : Detaches a container named '${container_name}' in the background.
  attach    : Attaches to the  in the background running container named '${container_name}'.
  status    : Returns info of the running container '${container_name}' in the background.
  stop      : Stops the container named '${container_name}' running in the background.
  kill      : Kills the container named '${container_name}' running in the background.
  versions  : Shows versions of most installed applications within the container.

Set environment variable 'DOCKER_BUILD=1' for using 'docker' as offset in the build directory to prevent mixing host build directories.
When a the container is detached it executes the 'build.sh' script by attaching to the container which is much faster.
"
else
	# Process the given commands additional to the 'build.sh' script.
	case "$1" in
		pull)
			# Pull the Docker image from the registry.
			docker pull "${img_name}"
			;;

		versions)
			# Just reenter the script using the the correct arguments.
			docker_run /home/user/bin/versions.sh
			;;

		run)
			shift 1
			docker_run "${@}"
			;;

		detach)
			# Check if the container is running.
			if is_detached; then
				echo "Container '${container_name}' is already running."
				exit 1
			fi
			# Name of the container only useful for detached running.
			options+=(--name "${container_name}")
			options+=(--detach)
			docker_run sleep infinity
			;;

		attach)
			# Check if the container is running.
			if ! is_detached; then
				echo "Container '${container_name}' is not running."
				exit 1
			fi
			# Remove the attach command from the arguments list.
			shift 1
			# Connect to the last started container as user 'user'.
			docker exec --interactive --tty "${container_name}" sudo --login --user=user -- "${@}"
			;;

		status)
			# Show the status of the container.
			docker ps --filter name="${container_name}"
			;;

		stop | kill)
			if is_detached; then
				echo "Container ID is '${cntr_id}' and performing '${1}' command."
				docker "${1}" "${cntr_id}"
			else
				echo "Container '${container_name}' is not running."
			fi
			;;

		*)
			# Stop this docker container only.
			if is_detached; then
				docker exec --interactive --tty "${container_name}" sudo --login --user=user -- "/mnt/project/${project_subdir}/build.sh" "${@}"
			else
				# Execute/run the build script from the Docker container.
				docker_run "/mnt/project/${project_subdir}/build.sh" "${@}"
			fi
			;;
	esac
fi
