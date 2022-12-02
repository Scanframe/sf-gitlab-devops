# The File 'CMakePresets.json'

<!-- TOC -->
* [The File 'CMakePresets.json'](#the-file--cmakepresetsjson)
  * [Introduction](#introduction)
  * [How To Make/Build](#how-to-makebuild)
    * [CMake Steps](#cmake-steps)
    * [The Configure Step](#the-configure-step)
    * [The Build Step](#the-build-step)
  * [Build The Whole Project in Short](#build-the-whole-project-in-short)
  * [Running CTest](#running-ctest)
<!-- TOC -->

## Introduction

Most IDE's can import this JSON-file in their projects to build the project for different purposes (type) like Debug and Release.

The [Cmake manual](https://cmake.org/cmake/help/latest/manual/cmake-presets.7.html) has more on this.

## How To Make/Build

### CMake Steps

Cmake uses 2 steps:
1) Configure
2) Build

### The Configure Step

With CMake the make directory is created in a **configuration** step which also 
downloads external projects/repositories.
<br>External projects like [Catch2](https://github.com/catchorg/Catch2.git) which is used here.

To see what cmake (CMakePresets.json) offers regarding configuration presets use the following command.

```bash
cmake --list-presets
```  

The result of items in depends on the generator a `cmake` binary has built-in when compiled.

For instance the result in Linux is as follows also using CLion's brought cmake.

```text
Available configure presets:

  "Debug-GNU" - Debug GNU Compiler on Linux
  "Debug-GW"  - Debug MinGW Compiler on Linux
```

For instance the result in Windows is as follows using CLion's brought cmake.

```text
Available configure presets:

  "Debug-GNU"   - Debug GNU Compiler on Linux
  "Debug-GW"    - Debug MinGW Compiler on Linux
  "Debug-MinGW" - Debug Linux MinGW Compiler on Windows
  "Debug-MSVC"  - Debug Linux MinGW Compiler on Windows
```

There is a difference for sure.

The execution of a **configure-step** is as follows:

```bash
cmake --preset "Debug-GNU"
```


### The Build Step

The next step is a **build-step** step which can only be performed after **configure-step** was successful.
<br>(_When during builds weird unexplainable stuff is happening delete the **cmake-build-xxx** directory._)

To see what cmake offers regarding build presets.

```bash
cmake --build --list-presets
```

For both Linux and Windows the lists are the same although in Linux the 
linked generator for the Windows builds is not available (probably a bug).

```text
Available build presets:

  "Debug-GNU"   - Debug build Linux GNU Compiler
  "Debug-GW"    - Debug build Linux MinGW Compiler
  "Debug-MinGW" - Debug build Windows MinGW Compiler
  "Debug-MSVC"  - Debug build Windows MSVC Compiler
```

The execution of a **build-step** is as follows.

This will list the possible make targets available for the project.

```bash
cmake --build --preset "Debug-GNU" --target help
```
The result is as follows.

```text
The following are some of the valid targets for this Makefile:
... all (the default if no target is provided)
... clean
... depend
... edit_cache
... rebuild_cache
... exif
... exif-hello-world
... manual
... Catch2
... Catch2WithMain
... hello-world
... hello-world-test
```

Targets like `clean`, `all`,  `depend` etcetera are cmake (generator) defaults.
<br>The `all` target is the default when the `--target` option is omitted on the command line. 


## Build The Whole Project in Short

```bash
cmake --preset "Debug-GNU"
cmake --build --preset "Debug-GNU"
```

## Running CTest

The command `ctest --list-presets` lists all the presets available for testing.
<br>No filtering on available generators either.  

```text
Available test presets:

  "Debug-GNU"
  "Debug-GW"
  "Debug-MinGW"
  "Debug-MSVC"
```

Execution of a test-preset is as follows.

```bash
ctest --preset "Debug-GNU" 
```
It plainly executes all declared targets added as test using `add_test()`.
