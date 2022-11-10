@echo off

:: Set environment to use version 14.29
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x86_amd64 -vcvars_ver=14.29

:: Depending on when CLion was installed the install directory differs.
if exist "C:\Program Files\JetBrains\CLion 2021.1\bin\clion64.exe" (
    "C:\Program Files\JetBrains\CLion 2021.1\bin\clion64.exe"
)
if exist "C:\Program Files\JetBrains\CLion 2021.3\bin\clion64.exe" (
    "C:\Program Files\JetBrains\CLion 2021.3\bin\clion64.exe"
)
