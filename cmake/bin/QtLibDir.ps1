##
## Finds Qt build directory.
##

#
# To allow execution of scripts execute
#    Set-ExecutionPolicy -Scope CurrentUser Unrestricted
#

Param
(
	# Directory to search through.
	[string]$QtRootDir = "P:\Qt\"
)

Process
{
	# Exit code initialized with failure.
	$ExitCode = 1
	# Holds all the possible Qt version directories.
	$Versions = @()
	# Iterate through the directories in the Qt root directory.
	foreach($dir in @(Get-ChildItem -Path $QtRootDir -Directory "*"))
	{
		if ($dir.Basename -match "^[0-9]+\.[0-9]+\.[0-9]+$")
		{
			$Versions += $dir.Basename
		}
	}
	# Continue
	if ($Versions.count)
	{
		# Sort ascending just in case.
		$Versions = $Versions | sort
		# Write to the output without a new line.
		Write-Host -NoNewline $Versions[$Versions.count -1]
		# Set exit code to success.
		$ExitCode = 0
	}
	# Signal success.
	exit $ExitCode;
}
