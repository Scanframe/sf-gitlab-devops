#!/bin/bash

# shellcheck disable=SC2034
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
google-chrome --app="file://${SCRIPT_DIR}/html/index.html"