# GitLab-CI/CD Setup

## Introduction

Explains how the structure and branch-names are set up for this C++ project.
In short the branch-name and GitLab protected status of the branch determine 
which jobs are executed in the CI/CD-pipeline.

The setup is that per branch only one OS is targeted for running jobs on.
This means only that only GitLab-Runners of a specific OS are used to execute the jobs on. 

## Directory Structure & Files (.gitlab)

The first level of directories are the operating systems `lnx` and `win` 
respectively **Linux** and **Windows**. One level further a distinction 
is made per compiler for that OS (i.e. `gnu` and `gw`). 

### Files

Each directory contains 2 files:

1) A template file (`tpl.gitlab-ci.yml`) contains job templates to configure jobs 
using the `extends:` key of a job section.
2) A jobs file  (`jobs.gitlab-ci.yml`) contains the jobs inheriting the templates 
from former mentioned file. 

The individual template and jobs files are included on the bases of the postfix of the branch name.

Since only a single OS of GitLab-Runners is used (at yhis time) for a branch the job 
tags are set using the `default:` jobs config section with variables set in `var-<arch>.gitlab-ci.yml`
file which is included on the bases of CPU architecture and OS.

```yaml
# Defaults for all jobs.
default:
  # Tags determine the selection of a runner.
  tags:
    # Variables 'SF_TARGET_OS' and 'SF_TARGET_ARCH' depends on the include-file
    # which on its turn depends on the commit branch name.
    - cplusplus
    - "${SF_TARGET_OS}"
    - "${SF_TARGET_ARCH}"
```

### Structure

```text
.gitlab
├── GITLAB-CI.md
├── lnx
│   ├── gnu
│   │   ├── jobs.gitlab-ci.yml
│   │   └── tpl.gitlab-ci.yml
│   ├── gw
│   │   ├── jobs.gitlab-ci.yml
│   │   └── tpl.gitlab-ci.yml
│   ├── jobs.gitlab-ci.yml
│   ├── tpl.gitlab-ci.yml
│   ├── var-amd64.gitlab-ci.yml
│   └── var-arm64.gitlab-ci.yml
├── main.gitlab-ci.yml
├── tpl.gitlab-ci.yml
└── win
    ├── mingw
    │   ├── jobs.gitlab-ci.yml
    │   └── tpl.gitlab-ci.yml
    ├── msvc
    │   ├── jobs.gitlab-ci.yml
    │   └── tpl.gitlab-ci.yml
    ├── jobs.gitlab-ci.yml
    ├── tpl.gitlab-ci.yml
    └── var-amd64.gitlab-ci.yml
```

## Jobs & Execution

Jobs are executed depending on the postfix of the branch-name.
The branch-name format for job execution is `<prefix>-<os>-<arch>` where:
* `prefix` is a free to choose part of the name.
* `os` for Operating system like:
  * `lnx` for Linux
  * `win` for Windows
* `arch` for Architecture
  * `amd64` for x86 64bit CPU's
  * `arm64` for Advanced RISC Machine designed CPU's

By using the `workflow:` section setting a rule for only pipeline execution on protected branches.
(_Protected branches is configured in GitLab per branch_)
This allows for other branches to skip pipeline execution all together.
