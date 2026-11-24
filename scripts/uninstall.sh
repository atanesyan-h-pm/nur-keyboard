#!/bin/bash
# Remove the bundle. Remove the layouts from Input Sources first, then log out and back in.
set -euo pipefail
rm -rf "$HOME/Library/Keyboard Layouts/Nur.bundle" "$HOME/Library/Keyboard Layouts/Armenian.bundle"
echo "Removed. Log out and back in to finish."
