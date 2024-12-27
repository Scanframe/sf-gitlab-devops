@echo off

:: Keep variables localized to this script.
setlocal

:: Get the current script directory to form the executable directory.
set EXECUTABLE_DIR=%~dp0win64%SF_OUTPUT_DIR_SUFFIX%
:: Call the script from the library.
call %~dp0/../cmake/lib/bin/Win64Exec.cmd %*

endlocal
