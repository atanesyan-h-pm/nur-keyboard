#!/bin/sh
# Nur — Armenian keyboard layouts for macOS
#
# Install:    curl -fsSL https://atanesyan-h-pm.github.io/nur-keyboard/install.sh | sh
# Uninstall:  curl -fsSL https://atanesyan-h-pm.github.io/nur-keyboard/install.sh | sh -s -- --uninstall
#
# Installs for the current user only (~/Library/Keyboard Layouts); no admin password needed.
# Run from a checkout (sh install.sh), it installs that checkout's Nur.bundle instead of downloading.

# Everything is inside main() so a partially downloaded script never runs.
main() {
  set -eu
  REPO="atanesyan-h-pm/nur-keyboard"
  BRANCH="main"
  DEST="$HOME/Library/Keyboard Layouts"

  if [ "$(uname -s)" != "Darwin" ]; then
    echo "Nur is for macOS only." >&2
    exit 1
  fi

  if [ "${1:-}" = "--uninstall" ]; then
    rm -rf "$DEST/Nur.bundle" "$DEST/Armenian.bundle"
    echo "Nur removed."
    echo "Remove the AM Nur layouts in System Settings > Keyboard > Text Input > Input Sources > Edit…,"
    echo "then log out and back in."
    return 0
  fi

  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT

  here=""
  if [ -f "$0" ]; then   # run as a file (sh install.sh), not piped from curl
    here=$(cd "$(dirname "$0")" && pwd)
  fi
  if [ -n "$here" ] && [ -f "$here/Nur.bundle/Contents/Info.plist" ]; then
    src="$here/Nur.bundle"
    echo "Installing Nur from $here"
  else
    echo "Downloading Nur from github.com/$REPO …"
    curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar -xz -C "$tmp"
    src=$(find "$tmp" -maxdepth 2 -type d -name Nur.bundle | head -n 1)
    if [ -z "$src" ]; then
      echo "Download failed: Nur.bundle not found in the archive." >&2
      exit 1
    fi
  fi

  mkdir -p "$DEST"
  rm -rf "$DEST/Nur.bundle" "$DEST/Armenian.bundle"   # Armenian.bundle = pre-1.0 name
  cp -R "$src" "$DEST/"
  xattr -dr com.apple.quarantine "$DEST/Nur.bundle" 2>/dev/null || true

  echo ""
  echo "Nur is installed in $DEST/Nur.bundle"
  echo ""
  echo "Next:"
  echo "  1. Log out and log back in (Apple menu > Log Out)."
  echo "  2. System Settings > Keyboard > Text Input > Input Sources > Edit… > + > Armenian,"
  echo "     choose the AM Nur layouts and click Add."
}

main "$@"
