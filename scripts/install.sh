#!/bin/bash
# Install this checkout's Nur.bundle for the current user.
# Thin wrapper: all install logic lives in ../install.sh, which installs the local bundle
# (no download) when run as a file from a checkout.
set -euo pipefail
exec sh "$(dirname "$0")/../install.sh" "$@"
