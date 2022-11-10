# GitLab DevOps Trial Project/Repository

<!-- TOC -->
* [GitLab DevOps Trial Project/Repository](#gitlab-devops-trial-projectrepository)
  * [Introduction](#introduction)
  * [The Application](#the-application)
  * [Learning points from the Trial](#learning-points-from-the-trial)
  * [Prerequisites](#prerequisites)
    * [Linux Packages](#linux-packages)
    * [GitLab Runner](#gitlab-runner)
      * [Considerations](#considerations)
      * [Installation](#installation)
      * [Registration](#registration)
<!-- TOC -->

## Introduction

This repository is to test GitLab's pipeline for CI (Continuous Integration) and CD (Continuous Delivery).
This using **GitLab-Runner** on a virtual machine.

## The Application

The build is a simple 'HelloWorld' application build for Linux and for Windows.
Both using a CMake special tool-chain.

## Learning points from the Trial

1. Auto compile on VM after new Git push on 'staging' branch.
2. Reporting in GitLab when compile failure. 
3. Reporting in GitLab when unit-tests fail.
4. Build a Debian package after a push on the 'release' branch. (maybe Windows too)

## Prerequisites

To be able to perform the builds the next packages need to be installed.

### Linux Packages

#### Required

```bash
apt-get install git cmake gcc g++ mingw-w64 bindfs wine
```

#### Recommended

```bash
apt-get install gcc-12 g++-12
```

### GitLab Runner

#### Considerations

For learning how a CI/CD pipeline is operating a VirtualBox instance is created using an
Ubuntu Server v22.04 (as of writing).

#### Installation

See the GitLab [instructions](https://docs.gitlab.com/runner/install/linux-manually.html).
The latest GitLab Runner package 
can be downloaded from this ([link](https://gitlab-runner-downloads.s3.amazonaws.com/latest/index.html))

```bash
wget -P ~/download "https://gitlab-runner-downloads.s3.amazonaws.com/latest/deb/gitlab-runner_amd64.deb"
dpkg -i gitlab-runner_amd64.deb
apt-get install -f ~/download/gitlab-runner_amd64.deb
```

The standard user under which the runner runs is `gitlab-runner` and the working directory is `~/builds/`.
To change this the gitlab-runner service file `/etc/systemd/system/gitlab-runner.service` needs to edited.
Other configuration is available in  `/etc/gitlab-runner/config.toml` for runner instance running 
as a service.

#### Registration

Command to register a runner at a GitLab server.

```bash
sudo gitlab-runner register --url https://git.scanframe.com/ --registration-token $REGISTRATION_TOKEN
```

**Making it RUN**

It seems that the one of the **tags** (vbox, cplusplus) must correspond with one of the tags in the 
GitLab web-application Runner configuration.

```yaml
default:
  tags:
    - cplusplus
```

**CA SSL Certificate Error**

Somehow when there are problems with CA SSL certificates add the following.
to file `/etc/gitlab-runner/config.toml`. 

```toml
[[runners]]
environment = ["GIT_SSL_NO_VERIFY=true"]
```

Passing the location for binding the jobs when a fixed path is needed between jobs. 
```toml
[[runners]]
environment = ["GIT_SSL_NO_VERIFY=true", "BIND_DIR=/home/gitlab-runner/binder"]
```

#### Passing files between jobs

In C++ the CMake generation of makefiles is a separate job and results in a `cmake-build-xxxx-xxx` directories.<br>
In this project the 2 final targets are build Linux and Windows.
To have or transfer the files from one job to another which depends on them the **artifacts** system is used.

_Somehow the **cache** system is not working since it deletes depended on directories it should actually cache._

The artifacts are stored on the GitLab server in `/var/opt/gitlab/gitlab-rails/shared/artifacts/` 
in some hashed names subdirectories. 

