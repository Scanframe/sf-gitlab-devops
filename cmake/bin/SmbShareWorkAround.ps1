##
## Locks a directory to be used as a work-around for a
## bug when sources are on a SMB shared directory.
##

## @echo off
## mkdir CMakeFiles\CMakeTmp\CMakeFiles
## start cmd /c "cd /d CMakeFiles\CMakeTmp\CMakeFiles && pause"

#
# To allow execution of scripts execute
#    Set-ExecutionPolicy -Scope CurrentUser Unrestricted
#

Param
(
	# Binary directory to be locked.
	[string]$BinaryDir = "S:\qt-concepts\cmake-build-debug-mingw"
)

Process
{
	if (!(Test-Path -Path $BinaryDir))
	{
		Write-Warning "Given path '$BinaryDir' does not exist and thus bailing out!"
		exit 0
	}
	# Get the drive from the given path.
	$Drive = Split-Path -Path $BinaryDir -Qualifier
	# execute external application to find out if the file is on a shared drive.
	$Result = (cmd /c fsutil fsinfo drivetype $Drive)
	# Check for an empty drive.
	if (!$Result)
	{
			Write-Error "Call to 'fsutil' failed..."
			# Signal an error.
			exit 1
	}
	# Check for a not a network drive.
	if ( ! $Result -like '*/Network*')
	{
			Write-Output "Drive '$Drive' is not on a network."
		# Signal success.
		exit 0
	}
	# Notify that the drive is on a network.
	Write-Output "Drive '$Drive' is on a network."
	# Assemble to be locked directory.
	$LockDir = "$BinaryDir\CMakeFiles\CMakeTmp\CMakeFiles"
	# Assemble the lock file.
	$LockFile = "$LockDir\_locked_"
	# Create the missing directory.
	New-Item $LockDir -ItemType Directory -ea 0
	# Create the lock file when it does not exist.
	if ((Test-Path -Path $LockFile))
	{
		Write-Output "Not locking due to existing file: '$LockFile'"
		# This is not a failure.
		exit 0
	}
	else
	{
		# Create the lock file.
		New-Item $LockFile -ItemType File -ea 0
		# Create a command window with the current directory to the lock directory so it cannot be deleted.
		# Also clean up when window is destroyed.
		Start-Process -FilePath $Env:ComSpec -ArgumentList "/c cd && pause && del ""$LockFile""" -WorkingDirectory $LockDir
	}
	# Signal success.
	exit 0;
}
