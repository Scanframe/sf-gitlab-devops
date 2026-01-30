# JetBrains CLion - C++ IDE

## Native Toolchain

To develop using CLion natively requires installing prerequisite packages to be installed to perform the
CMake workflow. To install these packages is done executing the `build.py install` with the `--required` option.

### Linux Host

Command for installing tool packages for Linux builds.

```shell
./build.py install --required lnx
```

Command for installing tool packages for Windows builds on a Linux host.

```shell
./build.py install --required win
```

### Windows Host

Command for installing tool packages for Windows builds on a Linux host.

```shell
./build.py install --required win
```

## Docker Toolchain

### Toolchain Configuration

For CLion add a **Docker** toolchain where the image to use is `amd64/gnu-cpp:24.04-6.10.1` when it
was build locally or for example `nexus.scanframe.com/amd64/gnu-cpp:24.04-6.10.1`
when it was build remote and uploaded to the self-hosted Nexus service.

The **Docker Qt 6.10.1** toolchain **Container Settings** are as follows:

```
-u 0:0
-e DISPLAY
--net host
--cap-add SYS_ADMIN
--device /dev/fuse
--security-opt apparmor:unconfined
--rm
-v /home/<linux-username>/.Xauthority:/home/user/.Xauthority:ro
-v <project-dir>:/mnt/project
```

The volume mount for `.Xauthority` and `DISPLAY` environment variable is to allow Qt GUI applications to use the host's
X-server.

Option `-u 0:0` is needed for the entry point to change the users `user` `uid` and `gid` to match those to the
owner of the mounted project directory or the passed environment variable `-e LOCAL_USER=<local-uid>:<local-gid>`.
This is to prevent inaccessible files by the host. Using the owner of the mounted directory is easier for
porting a project between users. Option `--privileged` can be used instead of options `--cap-add SYS_ADMIN 
--device /dev/fuse --security-opt apparmor:unconfined` when there is an issue.

### CMake Project Configuration

At **Build, Execution, Deployment > CMake** set fields (for project `gw-debug`):

* **Toolchain**: to the Docker correct image for the Qt version.
* **Generator**: to `Let CMake decide`.
* **CMake options**: To `--preset "gw-debug"`.
* **Build directory**: To `cmake-build/gw-debug` and must explicitly be a relative since
	the container has a different project root than the native path.
* **Build options**: Like `--preset "gw-debug"`.

> To expedite command execution, run the Docker container in the background with   
> the `build.py docker` scripts' `start` command.

### Run/Debug Configurations

#### Linux Host: Windows Project

The CMake project takes care of test applications created with **Catch2** or **GoogleTest** by calling
the `WineExec.sh` or `LinuxExec.sh` scripts when required.
The `LinuxExec.sh` also checks if QEMU is to be called when the architecture of the executable does not correspond.

For the non-test applications this must be configured manually. When a CMake project is loaded,
CLion creates once each **Run/Debug Configuration** automatically, it and keeps track of which
were imported the `.idea/workspace.xml` file.

The XPath expression to find the **Run/Debug** configurations is:

```xpath
//project/component[@name="RunManager"]/list/item/@itemvalue
```
To list them in the console:

```shell
xmllint --xpath '//project/component[@name="RunManager"]/list/item/@itemvalue' .idea/workspace.xml
```

> When accidentally deleted a Run/Debug configuration, edit the file
> and remove the corresponding entry and reload the CMake project.

For non-test application, the best practice is to duplicate the Run/Debug configuration
when using a Linux host and Windows host on the same source-tree using a file server.
This way, the Run/Debug configurations do not have to be edited each time when changing hosts.

> Give the duplicate entry a ` (win)` postix to distinguish it from the Linux host entry.

Only for running a Windows application (Linux host), the following Run/Debug fields
must be configured like this:

* **Executable**: `cmake/lib/bin/WineExec.sh`
* **Program arguments**: `$CMakeCurrentProductFile$`
* **Working directory**: `$ProjectFileDir$`

### Docker Container & JetBrains Gateway (SSH)

[JetBrains Gateway](https://www.jetbrains.com/remote-development/gateway/ "Link to JetBrains") can
access the Docker container. The `build.py` with the `docker sshd` command runs an SSH service in the
background with a listening port on `8022`. The **SSH** credentials are for user `user` and for
password also `user`. The SSH service can be stopped with the `stop` command. The server can also attach
to the container with the `attach` command as if was started in the background with `start`

> The Docker image can be started locally or remote even on a  
> Raspberry Pi 5 having an `aarch64` architecture.

Command examples:

```shell
# Starts the container to run in the background.
./build.py docker sshd
# Stops the container running in the background.
./build.py stop
```

## The 'document' Run/Debug Configuration

> **Note**: Only when tools are used natively on the host.

This entry compiles the **'document'** project and should open a browser to the
generated HTML documentation when it is run.

To open a browser when at run after successfully compiling, the following
Run/Debug configuration fields must be configured like this:

* **Executable** (Linux): Set to `bin/man/open.sh`.
* **Executable** (Windows): Set to `bin/man/open.cmd`.
* **Program arguments**: Set to `--app=file://$CMakeCurrentBuildDir$/html/index.html`.

For this a shell scripts [`bin/man/open.sh`](../bin/man/open.sh) [`bin/man/open.cmd`](../bin/man/open.sh)
open the Google Chrome browser for respectively Linux and Windows hosts.

> **Note**: The `--app` option is only available for Google Chrome to create a tabless window like an application. 
