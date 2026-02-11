#!/bin/bash

# shellcheck disable=SC2034
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# File to open.
index_file="${script_dir}/html/index.html"

if [[ "$(uname -o)" == "Cygwin" ]]; then
	"$(ls -f /cygdrive/*/Program\ Files*/Google/Chrome/Application/chrome.exe | head -n 1)" --app="file://$(cygpath --mixed "${index_file}")"
else
	if command -v google-chrome &> /dev/null; then
		google-chrome --app="file://${index_file}"
	elif command -v microsoft-edge-stable &> /dev/null; then
		microsoft-edge-stable --app="file://${index_file}"
	else
		xdg-open "${index_file}"
	fi
fi