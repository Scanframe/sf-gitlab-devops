#!/usr/bin/env python3

import os
import subprocess
import sys
import platform
import shutil
from pathlib import Path
from typing import List, Optional, Union, Dict, Iterable

# Get the script directory, which is the root of the repository.
ROOT_DIR: Path = Path(__file__).parent.resolve()

def run_command(cmd: List[str], cwd: Optional[Path] = None, env: Optional[Dict[str, str]] = None, capture_output: bool = False, check: bool = True) -> Union[subprocess.CompletedProcess[str], subprocess.CalledProcessError]:
	"""Runs a command and returns the result."""
	try:
		return subprocess.run(cmd, cwd=cwd, env=env, capture_output=capture_output, check=check, text=True)
	except subprocess.CalledProcessError as e:
		if check:
			print(f"! Command failed: {' '.join(cmd)}")
			if e.stdout:
				print(e.stdout)
			if e.stderr:
				print(e.stderr)
			raise
		return e

def check_commands(commands: Iterable[str]) -> None:
	"""Checks if the required commands are available."""
	for cmd in commands:
		if not shutil.which(str(cmd)):
			raise RuntimeError(f"Missing command '{cmd}' for this script!")

def is_windows() -> bool:
	"""Checks if the current platform is Windows."""
	return sys.platform == "win32" or (os.name == "nt")

def is_cygwin() -> bool:
	"""Checks if the current environment is Cygwin."""
	return platform.system().startswith("CYGWIN") or platform.system().startswith("MSYS")

def check_developer_mode() -> bool:
	"""Checks if Developer Mode is enabled on Windows."""
	if not is_windows():
		return True
	
	try:
		import winreg
		key = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock")
		value, regtype = winreg.QueryValueEx(key, "AllowDevelopmentWithoutDevLicense")
		if value == 1:
			return True
	except (ImportError, FileNotFoundError):
		pass
	
	print("Developer mode is not enabled in the Windows Settings.")
	print("Updating the registry to enable Developer Mode, allowing the creation of symbolic links.")
	try:
		# Attempt to enable Developer Mode. This requires elevation.
		cmd: List[str] = ["reg", "add", "HKLM\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\AppModelUnlock", "/v", "AllowDevelopmentWithoutDevLicense", "/t", "REG_DWORD", "/d", "1", "/f"]
		# If we're not admin, this might fail unless we use sudo-like mechanism or run as admin.
		# On Windows, 'sudo' is not standard.
		run_command(cmd)
		return True
	except Exception as e:
		print(f"! Failed to enable Developer Mode: {e}")
		print("Please enable Developer Mode manually in 'Settings -> Update & Security -> For developers'.")
		return False

def symlink2native(target_dir: Union[str, Path]) -> None:
	"""Converts Cygwin symbolic links to native Windows symbolic links."""
	if not is_windows() and not is_cygwin():
		return

	target_path: Path = Path(target_dir).resolve()
	if not target_path.is_dir():
		print(f"Target directory '{target_dir}' does not exist!")
		return

	if not check_developer_mode():
		return

	magic: str = "-#symlink#"
	
	# We need to find all symbolic links in the target directory.
	# In Cygwin, 'find' works. In native Windows, we might need a different approach.
	links: List[str] = []
	if is_cygwin():
		# Using 'find' to list symbolic links.
		result = run_command(["find", ".", "-maxdepth", "1", "-type", "l"], cwd=target_path, capture_output=True)
		if isinstance(result, subprocess.CompletedProcess):
			links = result.stdout.splitlines()
	else:
		# Native Windows approach to find symbolic links/junctions.
		for item in target_path.iterdir():
			if item.is_symlink():
				links.append("./" + item.name)

	for link_rel in links:
		link_path: Path = target_path / link_rel
		
		# Check if it's already a native symbolic link.
		# On Windows, we can use fsutil to check.
		if is_windows():
			try:
				# We need the Windows path.
				win_path: str = str(link_path).replace('/', '\\')
				result_fsutil = run_command(["fsutil", "reparsepoint", "query", win_path], capture_output=True, check=False)
				if isinstance(result_fsutil, subprocess.CompletedProcess) and "Tag value: Symbolic Link" in result_fsutil.stdout:
					continue
			except Exception:
				pass

		print(f"Converting: {link_rel}")
		try:
			dest: str = os.readlink(link_path)
			print(f"Destination: {dest}")
			
			magic_link: Path = link_path.with_name(link_path.name + magic)
			original_backup: Path = link_path.with_name(link_path.name + magic + "org")
			
			# Create native symlink. 
			# In Cygwin, we can use 'CYGWIN=winsymlinks:native ln -rs'.
			if is_cygwin():
				env: Dict[str, str] = os.environ.copy()
				env["CYGWIN"] = "winsymlinks:native"
				run_command(["ln", "-rs", dest, str(magic_link)], env=env)
			else:
				# Native Python way to create symlink.
				# target_is_directory must be specified for Windows.
				target_is_dir: bool = (link_path.parent / dest).is_dir()
				os.symlink(dest, magic_link, target_is_directory=target_is_dir)
			
			# Replace original.
			link_path.rename(original_backup)
			magic_link.rename(link_path)
			original_backup.unlink()
			
		except Exception as e:
			print(f"! Failed to convert {link_rel}: {e}")

def fix_submodule_url() -> None:
	"""Fixes the submodule URL for a repository cloned from GitHub."""
	try:
		result = run_command(["git", "config", "remote.origin.url"], capture_output=True, check=False)
		if isinstance(result, subprocess.CompletedProcess) and result.returncode == 0:
			origin_url: str = result.stdout.strip()
			if os.path.dirname(origin_url) == 'https://github.com/Scanframe':
				print("Fixing cmake library submodule URL.")
				run_command(["git", "config", "--file", ".gitmodules", "submodule.cmake/lib.url", "https://github.com/Scanframe/sf-cmake.git"])
	except Exception as e:
		print(f"! Warning: Failed to fix submodule URL: {e}")

def main() -> int:
	# Change to the script directory.
	os.chdir(ROOT_DIR)

	# Check required commands.
	check_commands(["git"])

	# Fix submodule URL.
	fix_submodule_url()

	# Update submodules.
	print("Git: Updating submodules recursively.")
	run_command(["git", "submodule", "update", "--init", "--recursive"])

	# Convert symbolic links on Windows/Cygwin.
	if is_windows() or is_cygwin():
		print("Windows required junction to symbolic link conversion.")
		symlink2native(".")

	return 0

if __name__ == "__main__":
	exitcode = 0
	try:
		exitcode = main()
	except KeyboardInterrupt:
		print("\n! Interrupted by user.")
		exitcode = 130
	except Exception as e:
		print(f"! Exception({e.__class__.__name__}): {e}")
		exitcode = 1
	sys.exit(exitcode)
