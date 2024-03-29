# GitLab DevOps Trial Project/Repository

## Content

<!-- TOC -->
* [GitLab DevOps Trial Project/Repository](#gitlab-devops-trial-projectrepository)
  * [Content](#content)
  * [Introduction](#introduction)
  * [GitHub Cloning](#github-cloning)
  * [Docker C++ Build Image](#docker-c-build-image)
  * [The C++ Application Source](#the-c-application-source)
    * [Applications & Library](#applications--library)
    * [CMake Generic C++ Support Library](#cmake-generic-c-support-library)
      * [Catch2 Unittests](#catch2-unittests)
      * [Doxygen Manual/Document Generator](#doxygen-manualdocument-generator)
      * [Code Format Checking with Clang](#code-format-checking-with-clang)
      * [Build Script](#build-script)
  * [CI/CD Pipeline Configuration](#cicd-pipeline-configuration)
  * [MinIO Cache Server](#minio-cache-server)
  * [Sonatype Nexus](#sonatype-nexus)
  * [GitLab-Runner with Docker](#gitlab-runner-with-docker)
  * [CLion IDE Docker Integration](#clion-ide-docker-integration)
* [Gitlab Issues](#gitlab-issues)
  * [Child Coverage Report](#child-coverage-report)
<!-- TOC -->

## Introduction

This project is to test GitLab's CI/CD-pipeline with a **hello-world** C++ applications.
One for console and one for GUI using the Qt-framework.
Both applications are build for Linux and also for Windows using a MinGW cross-compiler
on Linux including the Catch2 unittest-framework.

The application has a shared library and is build using CMake and presets and a build script
to simplify pipeline configurations for building,
testing and packaging. The Gitlab-Runners use Docker containers for builds and the runner
is also a container itself. Runners are using a self-hosted caching service/server for
caching between jobs across different hosts machines/containers.

The used Docker containers are stored on a self-hosted Docker-repository and deployment on a
self-hosted apt-repository and for Windows a raw-repository.

Links:

* [GitLab](https://about.gitlab.com/)
* [CMake](https://cmake.org/)
* [Qt-Framework](https://www.qt.io/product/framework)
* [Doxygen](https://www.doxygen.nl/)
* [Docker](https://www.docker.com/)
* [MinIO](https://min.io/)
* [Sonatype Nexus](https://www.sonatype.com/)
* [CLion](https://www.jetbrains.com/clion/)

Repositories:

* [sf-docker-runner](https://github.com/Scanframe/sf-docker-runner)`
* [sf-cmake](https://github.com/Scanframe/sf-cmake)
* [Catch2](https://github.com/catchorg/Catch2)


## GitHub Cloning

Since the GitHub repository is a mirror from a private GitLab server the `.gitmodule` file needs to be changed.  
The script [github-clone.sh](github-clone.sh "Link to script.") facilitates this.s

Execute the script when downloading.

```shell
wget "https://raw.githubusercontent.com/Scanframe/sf-gitlab-devops/main/github-clone.sh" -qO - | bash
```

## Docker C++ Build Image

The Docker image used for the CI/CD-pipeline en also for compiling in [CLion](https://www.jetbrains.com/clion/) is configured
by the in the GitHub [`sf-docker-runner`](https://github.com/Scanframe/sf-docker-runner) repository bash script `cpp-builder.sh` and `cpp-builder/Dockerfile`.  
The bash-script assembles all files needed to create this monster of an image of 2.8 GByte and push it to the self-hosted
[Sonatype Nexus server](https://nexus.scanframe.com/#browse/browse:docker-image:v2/gnu-cpp/tags/dev).

Execute the script `cpp-builder.sh` and view its sub-commands.

```shell
./cpp-builder.sh --help
```

```
Usage: cpp-builder.sh [<options>] [info | login | logout | push | pull | build | buildx | run | make | stop | kill | status | attach]
Execute a single or multiple actions for docker and/or it's container.

Options:
-h, --help    : Show this help.
-p, --project : Project directory which is mounted in '/mnt/project' and has a symlink '~/project'.

Commands:
build     : Builds the docker image tagged 'gnu-cpp:dev' for self-hosted Nexus repository and requires zipped Qt libraries.
push      : Pushes the docker image to the self-hosted Nexus repository.
pull      : Pulls the docker image from the self-hosted Nexus repository.
base-push : Pushes the base image 'ubuntu:22.04' to the self-hosted Nexus repository.
info      : Show general docker information.
prune     : Remove all Docker build cache.
login     : Log Docker in on the Nexus repository.
logout    : Log docker out from any repository.
qt-lnx    : Generates the 'qt-win.zip' from the current users Linux Qt library.
qt-win    : Generates the qt-win-zip from the current users Windows Qt library.
qt-lnx-up : Uploads the generated zip-file to the Nexus server as 'repository/shared/library/qt-lnx.zip'.
qt-win-up : Uploads the generated zip-file to the Nexus server as 'repository/shared/library/qt-win.zip'.
run       : Runs the docker container named 'gnu-cpp' in the foreground mounting the passed project directory.
stop      : Stops the container named 'gnu-cpp' running in the background.
kill      : Kills the container named 'gnu-cpp' running in the background.
status    : Return the status of named 'gnu-cpp' the container running in the background.
attach    : Attaches to the  in the background running container named 'gnu-cpp'.
versions  : Shows versions of most installed applications within the container.
```

The image contains all needed packages for builds and each of them are listed here with their versions.

> List is generated by script **`home/user/bin/version.sh`**.

| Part         | Version | Part        | Version |
|--------------|---------|-------------|---------|
| Ubuntu       | 22.04   | GCC         | 11.4.0  |
| C++          | 11.4.0  | MinGW GCC   | 11.4.0  |
| MinGW C++    | 11.4.0  | CMake       | 3.28.3  |
| GNU-Make     | 4.3     | Ninja-Build | 1.10.1  |
| CLang-Format | 19.0.0  | Gdb         | 12.1    |
| GNU-Linker   | 2.38    | Qt-Lib-Lnx  | 6.6.1   |
| Qt-Lib-Win   | 6.6.1   | Doxygen     | 1.9.1   |
| Graphviz     | 2.43.0  | Exif-Tool   | 12.40   |
| Dpkg         | 1.21.1  | RPM         | 4.17.0  |
| OpenJDK      | 11.0.21 | BindFS      | 1.14.7  |
| Fuse-ZIP     | 0.6.0   | JQ          | 1.6     |

## The C++ Application Source

### Applications & Library

The application source is located in this repository.  
The generic '**hello-world**' console application in [`gen/main.cpp`](./src/gen/main.cpp).  
The Qt cross-platform '**hello-world-qt**' GUI-application in [`qt/main.cpp`](./src/qt/main.cpp).  
The cross-platform '**hello-lib**' shared/dynamic/library in [`hwl/src/main.cpp`](./src/hwl/src/hello.cpp).

### CMake Generic C++ Support Library

The CMake Linux package contains more than the `cmake` executable.

| App   | Description                                                                                                                                                                                                                                                                                  |
|-------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| CMake | CMake is an open-source, cross-platform build system. It uses configuration files (CMakeLists.txt) to generate native build scripts for various platforms and compilers. CMake simplifies the build process by providing a consistent interface for managing complex build configurations.   |
| CTest | CTest is a testing tool that integrates with CMake. It allows developers to define and run tests for their CMake-based projects. CTest can execute tests in parallel, generate test reports, and integrate with Continuous Integration (CI) systems for automated testing.                   |
| CPack | CPack is a packaging tool designed to create distribution packages for software projects built with CMake. It can generate package formats such as DEB, RPM, NSIS, and ZIP. CPack simplifies the process of creating installable packages for different operating systems and distributions. |

To allow reuse of scripts for the ease of usage a library [sf-cmake](https://github.com/Scanframe/sf-cmake) is created and used as a Git-submodule.

#### Catch2 Unittests

To make it more challenging the **Catch2** unit-test library is imported.
The test application sources are located in [`./src/tests`](./src/tests).

```cmake
# FetchContent added in CMake 3.11, downloads during the configure step.
include(FetchContent)
# Import Catch2 library for testing.
FetchContent_Declare(
	Catch2
	GIT_REPOSITORY https://github.com/catchorg/Catch2.git
	GIT_TAG v3.1.1
)
# Adds Catch2::Catch2
FetchContent_MakeAvailable(Catch2)
```

#### Doxygen Manual/Document Generator

The `cmake/lib/SfDoxygenConfig.cmake` package adds a function `Sf_AddDoxygenDocumentation()` which in its turn adds a manual target.

Look at [Doxygen](https://www.doxygen.nl/) website for the syntax in C++ header comment blocks or Markdown files.

```cmake
# Required first entry checking the cmake version.
cmake_minimum_required(VERSION 3.27)
# Set the global project name.
project("doc")
# Add doxygen project when SfDoxygen was found.
# On Windows this is only possible when doxygen is installed in Cygwin.
find_package(SfDoxygen QUIET)
if (SfDoxygen_FOUND)
	# Get the markdown files in this project directory including the README.md.
	file(GLOB _SourceList RELATIVE "${CMAKE_CURRENT_BINARY_DIR}" "*.md" "../*.md")
	message("${_SourceList}")
	# Get all the header files from the application.
	file(GLOB_RECURSE _SourceListTmp RELATIVE "${CMAKE_CURRENT_BINARY_DIR}" "../app/*.h" "../app/*.md")
	# Remove unwanted header file(s) ending on 'Private.h'.
	list(FILTER _SourcesListTmp EXCLUDE REGEX ".*Private\\.h$")
	# Append the list with headers.
	list(APPEND _SourceList ${_SourceListTmp})
	# Adds the actual manual target.
	Sf_AddDoxygenDocumentation("${PROJECT_NAME}" "${PROJECT_SOURCE_DIR}" "${PROJECT_SOURCE_DIR}/../bin/man" "${_SourceList}")
endif ()
```

#### Code Format Checking with Clang

To enable format check before a commit modify or add the script `.git/hooks/pre-commit` with the following content.
It calls the [check-format.sh](./check-format.sh) script which in directly calls
the [`clang-format.sh`](https://github.com/Scanframe/sf-cmake/blob/main/bin/clang-format.sh) script
from the CMake support library. It also checks if it is a commit to the main or master branch and prevents it.

```bash
#!/bin/bash

# Redirect output to stderr.
exec 1>&2
# Get the branch name.
branch="$(git rev-parse --abbrev-ref HEAD)"
# Check if it is 'main' and prevent a commit on it.
if [[ "${branch}" == "main" || "${branch}" == "master" ]]; then
	echo "You can't commit directly to the '${branch}' branch!"
	exit 1
fi

# When the file 'check-format.sh' exists call it to check if the formatting is correct.
if [[ -f check-format.sh ]]; then
	if ! ./check-format.sh; then
		echo "Source is not formatted correctly!"
		exit 1
	fi
fi
```

This same script is used in the main pipeline configuration script [`main.gitlab-ci.yml`](.gitlab/main.gitlab-ci.yml)
in the job named '**check-env**'.  
So when the format is incorrect the pipeline will fail.

#### Build Script

The [`./build.sh`](build.sh) script make a call to the CMake support library
bash-script [`Build.sh`](https://github.com/Scanframe/sf-cmake/blob/main/bin/Build.sh).

```
Usage: /mnt/project/build.sh [<options>] [<presets> ...]
  -d, --debug      : Debug: Show executed commands rather then executing them.
  -i, --info       : Return information on all available build, test and package presets.
  -s, --submodule  : Return branch information on all Git submodules of last commit.
  -p, --package    : Create packages using a preset.
  --required       : Install required Linux packages using debian apt package manager.
  -m, --make       : Create build directory and makefiles only.
  -f, --fresh      : Configure a fresh build tree, removing any existing cache file.
  -C, --wipe       : Wipe clean build tree directory.
  -c, --clean      : Cleans build targets first (adds build option '--clean-first')
  -b, --build      : Build target and make config when it does not exist.
  -B, --build-only : Build target only and fail when the configuration does note exist.
  -t, --test       : Runs the ctest application using a test-preset.
  -l, --list-only  : Lists the ctest test defined application by the project and selected preset.
  -n, --target     : Overrides the build targets set in the preset by a single target.
  -r, --regex      : Regular expression on which test names are to be executed.
  --gitlab-ci      : Simulate CI server by setting CI_SERVER environment variable (disables colors i.e.).
  Where <sub-dir> is the directory used as build root for the CMakeLists.txt in it.
  This is usually the current directory '.'.
  When the <target> argument is omitted it defaults to 'all'.
  The <sub-dir> is also the directory where cmake will create its 'cmake-build-???' directory.

  Examples:
    Make/Build project: /mnt/project/build.sh -b my-preset
```

To make it easy to run the same commands within the Docker builder image,
the [`docker-build.sh`](./docker-build.sh) is provided which takes the same
arguments as the `build.sh` script.

## CI/CD Pipeline Configuration

The CI/CD Pipeline configuration has a main [`cmake-build.gitlab-ci.yml`](.gitlab/build.gitlab-ci.yml) file which triggers a  
child-pipeline [`gitlab-ci/main.gitlab-ci.yml`](.gitlab/main.gitlab-ci.yml) twice.
Respectively **Linux** and **Windows** but having different variable assignments passed from the main pipeline.

The `SF_SIGNAL` variable is set in GitLab for the project.

| Value  | Description                                                                            |
|--------|----------------------------------------------------------------------------------------|
| skip   | Do not trigger any pipelines.                                                          |
| test   | Tests the caching and artifacts mechanism.                                             |
| deploy | Allows testing manual deployment of packages where child pipelines are manual as well. |
|        | When left empty or not defined the pipeline runs normal.                               |

```plantuml
@startuml
<style>
	FontName Arial
	FontSize 13
	root
	{
		Padding 0
		Margin 0
		HorizontalAlignment Left
	}
	frame {
		' define a new style, using CSS class syntax
			FontColor Black
			LineColor Gray
			' Transparency is also possible
			'BackgroundColor #52A0DC55
			BackgroundColor #F9F9F9-#E9E9E9
			'[From top left to bottom right <&fullscreen-enter>]
			RoundCorner 10
		}
	}
	rectangle
	{
		.event
		{
			'Green gradient
			BackgroundColor #77BC65-#069A2E
			RoundCorner 10
		}
		.gitlab-ci
		{
			BackgroundColor #FFDE59-#B47804
		}
	}
	arrow
	{
		LineColor darkred
	}
}
</style>

skinparam TitleFontStyle Bold
skinparam TitleFontSize 20
skinparam RankSep 40
skinparam NodeSep 10

title "CI-Pipeline & Triggers"

frame "Pipeline" as pipeline {
	left to right direction
	frame "Push Events" as events {
		rectangle "Merge Request" <<event>> as merge_event
		rectangle "Protected Branch" <<event>> as protected_event
	}
	frame "GitLab-CI" as gitlab_ci {
		rectangle "Child: GNU-Build" <<gitlab-ci>> as gnu_cmake
		rectangle "Child: GW-Build" <<gitlab-ci>> as gw_cmake
		rectangle "Child: GNU-Coverage" <<gitlab-ci>> as gnu_coverage
		rectangle "Main" <<gitlab-ci>> as main
	}
	'Connectors
	protected_event -> main : trigger
	merge_event --> main : trigger
	main --> gnu_cmake : trigger
	main --> gw_cmake : trigger
	main --> gnu_coverage : trigger
}
@enduml
```

## MinIO Cache Server

The Docker way is to use image `minio-server` and `minio-mc` respectively for service and control console.  
For using Docker a script [`minio.sh`](https://github.com/Scanframe/sf-docker-runner/blob/main/minio.sh) is created to simplify it in
the [`sf-docker-runner`](https://github.com/Scanframe/sf-docker-runner) repository.  
To install a MinIO service from scratch using a Debian package is described in
the [wiki-page](https://wiki.scanframe.com/en/Configuration/Linux/minio-installation).

## Sonatype Nexus

To configure an APT-repository on a Sonatype Nexus server is described in
this [wiki-page](https://wiki.scanframe.com/en/Configuration/Linux/nexus-apt-hosted-repo "Link to Scanframe WikiJS.").  
For uploading files to a Nexus repository is the [`upload-nexus.sh`](cmake/lib/bin/upload-nexus.sh) script.

## GitLab-Runner with Docker

To run a GitLab-Runner service using Docker use image `gitlab/gitlab-runner:latest`.  
For using Docker a script [`gitlab-runner.sh`](https://github.com/Scanframe/sf-docker-runner/blob/main/gitlab-runner.sh) is created.
The script sets all the needed Docker options required by the 'C++ Build Image' (`gnu-cpp:dev`) to
have fuse available for `bindfs` `fuze-zip` and mounting it in the [`sf-docker-runner`](https://github.com/Scanframe/sf-docker-runner) repository.

## CLion IDE Docker Integration

For CLion add a Docker toolchain where the image to use is `gnu-cpp:dev` when it was build locally
or for example `nexus.scanframe.com:8090/gnu-cpp:dev` when it was build remote and uploaded
to the self-hosted Nexus service.

The '**Docker**' toolchain '**Container Settings**' are as follows:

```
-u 0:0 
-e LOCAL_USER=1000:1000 
-e DISPLAY 
-v /home/<linux-username>/.Xauthority:/home/user/.Xauthority:ro 
--privileged 
--net host 
--rm
```

The volume mount for `.Xauthority` and `DISPLAY` environment variable is to allow
Qt GUI applications to use the host's X-server.  
Option `--privileged` is needed for it to use `fuse`.

# Gitlab Issues

## Child Coverage Report

Child pipelines cannot not report coverage, to enable this using can be done on the console.

> In GitLab [Issue](https://gitlab.com/gitlab-org/gitlab/-/issues/363557 "Issue link.") the feature
> can be enabled but seems not to work when tested at this moment.

**Enter the Console**

_This might take a while... a minute or so._

```shell
sudo gitlab-rails console
```

Paste the commands in the console when it started (prompt visible).

**Console Commands**

Enable the global feature.

```
Feature.enable(:ci_child_pipeline_coverage_reports)
```

The response is currently.

```text
WARNING: Understand the stability and security risks of enabling in-development features with feature flags.
See https://docs.gitlab.com/ee/administration/feature_flags.html#risks-when-enabling-features-still-in-development for more information.                                                                 
=> true
```

Check the status of the feature.

```
Feature.get(:ci_child_pipeline_coverage_reports)
```

Disable the feature.

```
Feature.disable(:ci_child_pipeline_coverage_reports)
```
