#!/bin/bash
# Remove Nur for the current user. Remove the layouts from Input Sources first, then log out and back in.
# Thin wrapper around ../install.sh --uninstall.
set -euo pipefail
exec sh "$(dirname "$0")/../install.sh" --uninstall
