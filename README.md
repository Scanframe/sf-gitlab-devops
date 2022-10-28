# GitLab DevOps Trial Project/Repository

<!-- TOC -->
* [GitLab DevOps Trial Project/Repository](#gitlab-devops-trial-projectrepository)
  * [Introduction](#introduction)
  * [The Application](#the-application)
  * [Learning points from the Trial](#learning-points-from-the-trial)
  * [Prerequisites](#prerequisites)
    * [Linux Packages](#linux-packages)
    * [GitLab Runner](#gitlab-runner)
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
 
```bash
apt install \
  git \
  cmake \
  gcc-12 \
  g++-12 \
  mingw-w64 \
  wine
```

### GitLab Runner

#### Installation

See the GitLab [instructions](https://docs.gitlab.com/runner/install/linux-manually.html).
The latest GitLab Runner package 
can be downloaded from this ([link](https://gitlab-runner-downloads.s3.amazonaws.com/latest/index.html))

```bash
wget -P ~/download "https://gitlab-runner-downloads.s3.amazonaws.com/latest/deb/gitlab-runner_amd64.deb"

dpkg -i gitlab-runner_amd64.deb

apt-get install -f ~/download/gitlab-runner_amd64.deb
```

#### Registration

Command to register a runner.

```bash
sudo gitlab-runner register --url https://git.scanframe.com/ --registration-token $REGISTRATION_TOKEN
```

# What Now?!

### GitLab Runner Service

The service uses config file `/etc/gitlab-runner/config.toml` 


