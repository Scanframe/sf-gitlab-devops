# Gets the current script directory and make it the current working.
Push-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition)
# Run the imported script.
. ".\cmake\lib\bin\build.ps1"
ProcessBuild $MyInvocation $MyInvocation.Line
# Restore the previous working directory location.
Pop-Location
