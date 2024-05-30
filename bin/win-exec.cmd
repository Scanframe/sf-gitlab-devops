@echo off

:: Keep variables localized to this script.
setlocal

:: Get the current script directory for the calling .
set exec_dir=%~dp0
:: Call the script from the library.
call %~dp0/../cmake/lib/bin/Win64Exec.cmd %*

endlocal
