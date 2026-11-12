# Trial DevOps

Test project for the [`cmake/lib`](cmake/lib/) CMake boilerplate submodule.

## Purpose

This repository exists to exercise and validate the CMake build infrastructure provided by the
`cmake/lib` Git submodule. It contains minimal C++ applications that cover the various build
paths, toolchains, and features supported by the submodule.

For full documentation of the build system, see the submodule's
[README](cmake/lib/README.md) and [build script docs](build.md).

## Project Structure

| Path                | Description                                                                  |
|---------------------|------------------------------------------------------------------------------|
| `cmake/`            | Project cmake presets, package configurations                                |
| `cmake/lib/`        | Git submodule — CMake boilerplate library (build scripts, presets, packages) |
| `src/cli/`          | Console application (**hello-world**)                                        |
| `src/qt/`           | Qt GUI application (**hello-world-qt**)                                      |
| `src/hwl/`          | Shared library (**hello-lib**)                                               |
| `src/tests/catch/`  | Catch2 unit tests                                                            |
| `src/tests/google/` | GoogleTest unit tests                                                        |
| `src/tests/app/`    | Additional test applications (coroutines, polling)                           |
| `gitlab-ci/`        | GitLab CI/CD pipeline configuration                                          |
| `doc/`              | Doxygen documentation sources                                                |
| `build.py`          | Python build script (from `cmake/lib`)                                       |
| `build.ini`         | Build configuration (Qt version, toolchains, environment)                    |
| `CMakePresets.json` | CMake preset configurations                                                  |
| `init-repo.py`      | Post-clone helper — fixes symlinks and submodule URLs                        |

## Quick Start

```bash
# Clone with submodules
git clone --recursive <repository-url> trial-devops
cd trial-devops

# Fix symlinks on Windows / Cygwin
python init-repo.py

# Build and test with default GNU toolchain
./build.py -mbt gnu-debug
```

## Build Configuration

The project uses CMake presets defined in `CMakePresets.json`. The `build.py` script provides a
unified interface for all build operations. Configuration is stored in `build.ini`.

Current configured versions (from `build.ini`):

| Component    | Version                                          |
|--------------|--------------------------------------------------|
| Qt           | 6.12.0                                           |
| Catch2       | 3.16.0                                           |
| GoogleTest   | 1.18.0                                           |
| Docker image | `nexus.scanframe.com/amd64/gnu-cpp:24.04-6.12.0` |

## Supported Toolchains

| Toolchain | Description                                     |
|-----------|-------------------------------------------------|
| `gnu`     | Native GNU (gcc/g++) on Linux                   |
| `ga`      | GNU cross-compile for aarch64                   |
| `gw`      | MinGW-w64 cross-compile to Windows (Linux host) |
| `mingw`   | MinGW-w64 native on Windows                     |
| `msvc`    | MSVC native on Windows or via Wine              |

Build commands can be wrapped with `wine` or `docker` subcommands for nested execution
environments. See [build.md](build.md) for details.

## CI/CD Pipeline

GitLab CI configuration is located in [`gitlab-ci/`](gitlab-ci/). The main pipeline
[`main.gitlab-ci.yml`](gitlab-ci/main.gitlab-ci.yml) triggers child pipelines for building,
testing, and coverage reporting.

Pipeline stages:

1. **check** — Environment validation and code format checking
2. **build** — Child pipelines for each toolchain (GNU, MinGW, aarch64)
3. **report** — Coverage report aggregation

The pipeline can be controlled via the `SF_SIGNAL` GitLab variable:

| Value     | Behavior                          |
|-----------|-----------------------------------|
| `skip`    | Do not trigger any pipelines      |
| `test`    | Run cache and artifact tests only |
| `deploy`  | Enable manual deployment jobs     |
| *(empty)* | Normal pipeline execution         |

## Code Format

A pre-commit hook can use [`check-format.sh`](check-format.sh) to validate formatting before
commits. The CI pipeline also runs this check in the `check-env` job.

## Documentation

- Build script: [build.md](build.md)
- Code conventions: [doc/code-conventions.md](doc/code-conventions.md)
- Submodule docs: [cmake/lib/README.md](cmake/lib/README.md)
