#!/bin/bash
# Install the bundle for the current user (no sudo needed).
set -euo pipefail
cd "$(dirname "$0")/.."
DEST="$HOME/Library/Keyboard Layouts"
mkdir -p "$DEST"
rm -rf "$DEST/Nur.bundle" "$DEST/Armenian.bundle"  # Armenian.bundle = pre-1.0 name
cp -R Nur.bundle "$DEST/"
xattr -dr com.apple.quarantine "$DEST/Nur.bundle" 2>/dev/null || true
echo "Installed to $DEST/Nur.bundle"
echo "Log out and back in, then add the layouts in System Settings > Keyboard > Input Sources > Edit > + > Armenian."
