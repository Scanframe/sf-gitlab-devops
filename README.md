# GitLab DevOps Trial Project/Repository

_To this project a gitlab-runner is to be configured for using a self-hosted minio server for caching._

## Content

<!-- TOC -->
* [GitLab DevOps Trial Project/Repository](#gitlab-devops-trial-projectrepository)
  * [Content](#content)
  * [Introduction](#introduction)
    * [Intended Learning Points](#intended-learning-points)
  * [C++ Source](#c-source)
    * [Main App](#main-app)
    * [Unittest App](#unittest-app)
  * [Prerequisites](#prerequisites)
    * [Virtual Machines](#virtual-machines)
    * [GitLab-Runner & Developer Station](#gitlab-runner--developer-station)
      * [Linux Packages](#linux-packages)
        * [Runner & Workstation](#runner--workstation)
        * [GitLab-Runner Only](#gitlab-runner-only)
      * [Windows Packages](#windows-packages)
        * [Runner & Workstation](#runner--workstation)
        * [GitLab-Runner Only](#gitlab-runner-only)
          * [Optional](#optional)
    * [Server Services (Linux)](#server-services--linux-)
      * [GitLab (CE) Server (LXC-container)](#gitlab--ce--server--lxc-container-)
      * [Apache Proxy Server (Optional for public access)](#apache-proxy-server--optional-for-public-access-)
  * [GitLab Runner Installation](#gitlab-runner-installation)
      * [Installation](#installation)
      * [Registration](#registration)
        * [Making it Run](#making-it-run)
        * [Error: CA SSL Certificate](#error--ca-ssl-certificate)
        * [Additional Configuration](#additional-configuration)
          * [Linux](#linux)
          * [Windows](#windows)
      * [Passing Working files between jobs (cache)](#passing-working-files-between-jobs--cache-)
      * [Resulting files between jobs (cache)](#resulting-files-between-jobs--cache-)
  * [MinIO AWS S3 API Compatible Cache Service](#minio-aws-s3-api-compatible-cache-service)
<!-- TOC -->

## Introduction

This repository is to test GitLab's pipeline for CI (Continuous Integration) and CD (Continuous Delivery).
This using **GitLab-Runner** on several virtual machines and a Raspberry Pi.
Only compiling to 64-bit code for all platforms.

Runners Tested on and links for downloading:

* [Linux Ubuntu Server](https://ubuntu.com/download/server)
* [Windows](https://developer.microsoft.com/en-us/windows/downloads/virtual-machines/)
* [Armbian](https://www.armbian.com/uefi-arm64/)

The Linux server platform is also capable able to cross compile Windows applications using the `gw` compiler.

### Intended Learning Points

1. Auto compile on VM after new Git push on 'staging' branch.
2. Reporting in GitLab when compile failure.
3. Reporting in GitLab when unit-tests fail.
4. Build a Debian package after a push on the 'release' branch. (maybe Windows too)

## C++ Source

### Main App

The build is a simple `hello-world` application locate in `./app.

```c++
#include <iostream>

int main(int argc, char** argv)
{
  std::cout << "Hello, World!" << std::endl;
  return 0;
}
```

### Unittest App

To make it more challenging the **Catch2** unit-test library is imported.
The test application and tests are located in `./app/tests`.

```cmake
# FetchContent added in CMake 3.11, downloads during the configure step
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

A simple unit test and application is created in `./app/tests` directory.
The compile-target is `hello-world-test`.

```c++
#include <catch2/catch_all.hpp>

TEST_CASE("sf::StringSplit", "[generic][strings]")
{
	using Catch::Matchers::Equals;

	SECTION("Strings")
	{
		std::vector<std::string> sl;
		sl.insert(sl.end(), "Hello");
		sl.insert(sl.end(), "World");
		sl.insert(sl.end(), "3");
		sl.insert(sl.end(), "4.0");
		CHECK(sl == std::vector<std::string>{"Hello", "World", "3", "4.0"});
	}
}
```

## Prerequisites

### Virtual Machines

For this project 2 virtual machines are needed and optional a Raspberry Pi.

* [Linux Ubuntu Server](https://ubuntu.com/download/server) 
* [Windows Development Environment](https://developer.microsoft.com/en-us/windows/downloads/virtual-machines/) Provides an OVA-file VirtualBox import
* [Linux Armbian](https://www.armbian.com/uefi-arm64/) Raspberry Pi4

### GitLab-Runner & Developer Station

#### Linux Packages

##### Runner & Workstation

To compile on your working station the repository **./build.sh** script offers an **-p | --packages** option 
which installs all needed packages for this project to be able to compile.

```bash
# Install the git command 
sudo apt install git
# Clone the repo in the users source directory. 
git -C ~/source clone "https://github.com/Scanframe/gitlab-devops.git"
# Install the needed packages.
~/source/build.sh --packages 
```

##### GitLab-Runner Only 

Download the debian package for the Linux VM GitLab-Runner.

```bash
wget -P ~/download "https://gitlab-runner-downloads.s3.amazonaws.com/latest/deb/gitlab-runner_amd64.deb"
dpkg -i gitlab-runner_amd64.deb
```

#### Windows Packages

##### Runner & Workstation

To have a MinGW compiler for this project JetBrains **CLion** is the easiest because it brings it all.

* [JetBrains CLion](https://www.jetbrains.com/clion/download/) accompanied installs the MinGW compiler. (30 day trial)
* [Git for Windows](https://git-scm.com/download/win) Also has the required **bash.exe**. (1 click install by CLion)
* [QT installer](https://www.qt.io/download-thank-you) installs accompanied the MinGW compiler.
* [Visual Studio Community Edition](https://visualstudio.microsoft.com/vs/community/) (free)
* [Cygwin](https://www.cygwin.com/) is alternative for Git-bash and allows installing applications like doxygen for creating manuals from code.

For installing Cygwin and configuring see this [manual](https://wiki.scanframe.com/applications/cygwin).

##### GitLab-Runner Only

Download the [GitLab-Runner](https://docs.gitlab.com/runner/install/windows.html) application.

Since it is going to be running as a service the file was moved into "%ProgramFiles%\GitLab\Runner" where 
also the configuration file `config.toml` will reside. 

###### Optional 

This is a CLI way of downloading and installing most of the requirements. 
It is doubtful if all applications windup in their expected destinations for the scripts.

```bat
# Needs elevation of the CLI.
winget install --id JernejSimoncic.Wget -e --source winget --scope machine
winget install --id Git.Git -e --source winget --scope machine
winget install --id GitLab.Runner --scope machine
```

### Server Services (Linux)

#### GitLab (CE) Server (LXC-container)

For this a **[GitLab Server Community Edition](https://about.gitlab.com/install/)** is used 
in an LXC container using Debian 10 LTS (buster)<br>
_Reason for Debian is that the LTS lasts longer then an Ubuntu LTS version (just being lazy)_

[Here is a manual](https://wiki.scanframe.com/en/applications/gitlab) to set up a GitLab CE server with 
unattended updates so in practise Gitlab and Linux need no attention ever. 
Once in a while just check the GitLAb Admin page to see if the installation it is up-to-date.
_(GitLab has update almost every other day.)_

A paid **[GitLab.com](https://gitlab.com)** account where CI.CD pipelines are enabled is also possible.

#### Apache Proxy Server (Optional for public access) 

The host server for the LXC-containers uses an Apache WebServer which deals with the SSL certificates 
from **[acme.sh](https://github.com/acmesh-official/acme.sh)** which are used by the https proxy to 
the GitLab Web-application in the LXC-container.<br>
On how to do that check **[this](https://app.scanframe.com/?page=help-linux#acme-letsencrypt-certificates.md)**.

Incomplete Apache configuration include-file for the GitLab LXC-container where all 
variables are set before including this one.

```apacheconf
# Https configuration.
<IfModule ssl_module>
  <VirtualHost *:443>
    ServerName ${DOMAIN}
    LogLevel info
    ErrorLog ${APACHE_LOG_DIR}/git-error.log
    CustomLog ${APACHE_LOG_DIR}/git-access.log clf
    # SSL Certificates
    SSLEngine On
    SSLCertificateFile "${BASE_DIR}/ssl-certs/${DOMAIN}-cert.pem"
    SSLCertificateKeyFile "${BASE_DIR}/ssl-certs/${DOMAIN}-key.pem"
    SSLCertificateChainFile "${BASE_DIR}/ssl-certs/${DOMAIN}-letsencrypt.pem"
    # SSL Protocol and CypherSuite only allowing valid cyphers.
    Include "${CONFIG_DIR}/conf/ssl-proto-cypher.conf"
    ## RequestHeader set X-Forwarded-Proto "https"
    <Proxy *>
      Order deny,allow
      Allow from all
    </Proxy>
    ## SSLProxyEngine On
    ProxyRequests Off
    ServerSignature Off
    ProxyPreserveHost On
    AllowEncodedSlashes NoDecode
    <Location />
      Order deny,allow
      Allow from all
      ProxyPass http://${COINTAINER_IP}:80/
      ProxyPassReverse http://${COINTAINER_IP}:80/
    </Location>
    </VirtualHost>
</IfModule>
```

## GitLab Runner Installation

#### Installation

See the GitLab [instructions](https://docs.gitlab.com/runner/install/linux-manually.html).
The latest GitLab Runner package
can be downloaded from this ([link](https://gitlab-runner-downloads.s3.amazonaws.com/latest/index.html))

```bash
wget -P ~/download "https://gitlab-runner-downloads.s3.amazonaws.com/latest/deb/gitlab-runner_amd64.deb"
dpkg -i gitlab-runner_amd64.deb
```

The standard user under which the runner runs is `gitlab-runner` and the working directory is `~/builds/`.
To change this the gitlab-runner service file `/etc/systemd/system/gitlab-runner.service` needs to edited.
Other configuration is available in  `/etc/gitlab-runner/config.toml` for runner instance running
as a service.

#### Registration

Command to register a runner at the GitLab (CE) server.

```bash
sudo gitlab-runner register --url https://<gitlab-server-domain>/ --registration-token $REGISTRATION_TOKEN
```

##### Making it Run

A runner is selected to run a gitlab-ci individual job depending on if all **job:tags** are met by the runner.
In GitLab the tags of a runner can be determined even after a runner is registered.

##### Error: CA SSL Certificate 

Somehow when there are problems with CA SSL certificates add the following.
to file `/etc/gitlab-runner/config.toml`.

```toml
[[runners]]
environment = ["GIT_SSL_NO_VERIFY=true"]
```

##### Additional Configuration 

Passing the location for binding the jobs when a fixed path is needed between jobs.
An environment variable is configured for the runner.  

###### Linux 

For **Linux**, it is simple since the service runs by default under 
the **gitlab-runner** user and its own home directory. 

```toml
# Allow 3 paralel job running.
concurrent = 3
[[runners]]
environment = ["BIND_DIR=/home/gitlab-runner/binder"]
```

###### Windows

For Windows a lot of work is to be done since there is not a user created for running the service.
(_Security wise this does not look smart_)<br>
The service runs under the local **SYSTEM** user.

The **gitlab-ci** job scripts create Windows **symlinks** to have the same absolute path between jobs since CMake requires it.<br>
Since only by default Administrators can create symlinks security policies need to be changed.
Nice to have is a **God Mode** named folder `God Mode.{ED7BA470-8E54-465E-825C-99712043E01C}.` on the desktop to
find the important config stuff which is somewhat consistent between Windows versions.

```toml
# Allow 3 paralel job running.
concurrent = 3
[[runners]]
executor = "shell"
shell = "powershell"
builds_dir="C:\\GitLab-Runner\\builds"
cache_dir="C:\\GitLab-Runner\\cache"
```

Installing the GitLab-Runner service as the **User** in the developers VM image preinstall Windows is as follows.

```powershell
gitlab-runner-windows-amd64.exe install --working-directory "C:\GitLab-Runner" --user User --password "<user-password>" 
```
But first create this directory tree. 
```text
C:\GitLab-Runner
├───binder
├───builds
└───cache
```

#### Passing Working files between jobs (cache)

In C++ the CMake generation of makefiles is a separate job and results in a `cmake-build-*` directories.<br>
To have or transfer the files from one job to another which depends on them the **cache** system is used.
The cached files are stored locally by default but AWS among 2 others can be configured as cache servers.<br>
There is also a free application [**minio**](https://min.io/download) which has the AWES S3 API implemented 
and is a free option.

#### Resulting files between jobs (cache)

To have or transfer the resulting files from one job to another which depends on them the **artifacts** system is used.

The artifacts are B.T.W. stored on the GitLab server in `/var/opt/gitlab/gitlab-rails/shared/artifacts/`
in some hashed named subdirectories.

## Doxygen Code Manual

The `cmake/SfDoxyGenConfig.cmake` package adds a funtion `Sf_AddManual()` which in its turn adds a manual target.

Look at [Doxygen](https://www.doxygen.nl/) website for the syntax in C++ header comment blocks or Markdown files.

```cmake
# Required first entry checking the cmake version.
cmake_minimum_required(VERSION 3.18)
# Set the global project name.
project("manual")
# Add doxygen project when SfDoxyGen was found.
# On Windows this is only possible when doxygen is installed in Cygwin.
find_package(SfDoxyGen QUIET)
if (SfDoxyGen_FOUND)
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
  Sf_AddManual("${PROJECT_NAME}" "${PROJECT_SOURCE_DIR}" "${PROJECT_SOURCE_DIR}/../bin/man" "${_SourceList}")
endif ()
```

## MinIO AWS S3 API Compatible Cache Service

_To be implemented jet._