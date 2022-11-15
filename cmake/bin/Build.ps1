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
	# Save the current console color.
	$ColorSaved = $Host.UI.RawUI.ForegroundColor
	# Regular expression to get only the arguments part.
	$RegEx = (-Join ("^.*", ([regex]::Escape($Invocation.MyCommand.Name)), "\s*"))
	$Arguments = ($Invocation.Line) -replace $RegEx , ""
	# Get the current username.
	$Username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
	# Gets the current script directory.
	$ScriptDir = split-path -parent $Invocation.MyCommand.Definition
	# Get the current script filename.
	$ScriptName = $Invocation.MyCommand.Name
	# Path to cygwin bash application.
	$BashBin = "C:\cygwin64\bin\bash.exe"
	# Check if it exists.
	if ((Test-Path -Path "${BashBin}"))
	{
		# Path to Cygwin convert application for paths.
		$CygpathBin = 'C:\cygwin64\bin\cygpath.exe'
		# Get script directory Cygwin style.
		$ScriptDirUnix = ((& "$CygpathBin" -u "$ScriptDir") | Out-String).Replace("`n", "").Replace("`r", "")
		# Need absolute path for Cygwin since it starts at the home driectory.
		$BashScript = -Join ($ScriptDirUnix, "/build.sh")
	}
	else
	{
		# Path to Git accompanied bash application.
		$BashBin = (-Join ($env:ProgramW6432, "\Git\bin\bash.exe"))
		# Use Cygwin-bash or Git-bash.
		if ((Test-Path -Path "${BashBin}"))
		{
			# Path to Cygwin convert application for paths.
			$CygpathBin = (-Join ($env:ProgramW6432, "\Git\usr\bin\cygpath.exe"))
			# Relative path is allowed.
			$BashScript = "./build.sh"
		}
		else
		{
			$Host.UI.RawUI.ForegroundColor = "Red"
			Write-Host "Bash application could not found in default Cygwin or Git installed location!"
			# Return to the initial color.
			$Host.UI.RawUI.ForegroundColor = $ColorSaved
			exit 1
		}
	}
	# Report what and how is being executed
	$Host.UI.RawUI.ForegroundColor = "Green"
	Write-Host "- Powershell: $ScriptName"
	Write-Host "- User: $Username"
	Write-Host "- Bash-App: $BashBin"
	Write-Host "- Bash: $BashScript $Arguments"
	# Show additional help when no arguments are added.
	if ($Arguments.Length -eq 0)
	{
		Write-Host ( -join ("Usage: `t", $MyInvocation.MyCommand.Name, "<bash-args>"))
		Write-Host "`tThe bash arguments are passed to the bash script."
	}
	# Return to the initial color.
	$Host.UI.RawUI.ForegroundColor = $ColorSaved
	# Execute the script.
	& $BashBin --login -c "$BashScript $Arguments"
	$ExitCode = $LASTEXITCODE
	if ($ExitCode)
	{
		$Host.UI.RawUI.ForegroundColor = "Red"
		Write-Host "Bash or shell script failed execution!"
	}
	# Return to the initial color.
	$Host.UI.RawUI.ForegroundColor = $ColorSaved
	# Signal success or failure.
	exit $ExitCode
}
