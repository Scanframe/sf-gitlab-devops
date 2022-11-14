<#

# Gets the current script directory and make it the current working.
Push-Location -Path (Split-Path -Parent $MyInvocation.MyCommand.Definition)
# Run the imported script.
. ".\cmake\bin\Build.ps1"
ProcessBuild $MyInvocation $MyInvocation.Line
# Restore the previous working directory location.
Pop-Location

#>
function ProcessBuild
{
	# Argument passed is My invocation.
	Param ($Invocation)
	# Regular expression to get only the arguments part.
	$RegEx = (-Join ("^.*", ([regex]::Escape($Invocation.MyCommand.Name)), "\s*"))
	$Arguments = ($Invocation.Line) -replace $RegEx , ""
	# Exit code initialized with failure.
	$ExitCode = 1
	# TODO: Make a decision.
	[bool]$GitBash = $True
	# Get the current username.
	$Username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
	# Gets the current script directory.
	$ScriptDir = split-path -parent $Invocation.MyCommand.Definition
	# Get the current script filename.
	$ScriptName = $Invocation.MyCommand.Name
	# Use Cygwin-bash or Git-bash.
	if ($GitBash -eq "True")
	{
		# Path to cygwin bash application.
		$BashBin = (-Join ($env:ProgramW6432, "\Git\bin\bash.exe"))
		# Path to Cygwin convert application for paths.
		$CygpathBin = (-Join ($env:ProgramW6432, "\Git\usr\bin\cygpath.exe"))
		# Relative path is allowed.
		$BashScript = "./build.sh"
	}
	else
	{
		# Path to cygwin bash application.
		$BashBin = "C:\cygwin64\bin\bash.exe"
		# Path to Cygwin convert application for paths.
		$CygpathBin = 'C:\cygwin64\bin\cygpath.exe'
		# Get script directory Cygwin style.
		$ScriptDirUnix = ((& "$CygpathBin" -u "$ScriptDir") | Out-String).Replace("`n", "").Replace("`r", "")
		# Append the the file to it.
		$BashScript = -Join ($ScriptDirUnix, "/build.sh")
	}
	# Report what is being executed
	Write-Host "Powershell: $ScriptName"
	Write-Host "User: $Username"
	Write-Host "Bash: $BashScript $Arguments"
	# Show additional help when no arguments are added.
	if ($Arguments.Length -eq 0)
	{
		Write-Host ( -join ("Usage: `t", $MyInvocation.MyCommand.Name, "<bash-args>"))
		Write-Host "`tThe bash arguments are passed to the bash script."
	}
	# Execute the script.
	& $BashBin -c "$BashScript $Arguments"
	# Signal success or failure.
	exit $ExitCode;
}
