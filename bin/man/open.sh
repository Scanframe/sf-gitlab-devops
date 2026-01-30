#!/bin/bash

# shellcheck disable=SC2034
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "$(uname -o)" == "Cygwin" ]]; then
	"$(ls -f /cygdrive/*/Program\ Files*/Google/Chrome/Application/chrome.exe | head -n 1)" --app="file://$(cygpath --mixed "${script_dir}/html/index.html")"
else
	google-chrome --app="file://${script_dir}/html/index.html"
fi