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

  # Release to download. Pinned to a tag (not the moving main branch) so every user gets the same,
  # reviewed files.
  VERSION="v1.0.0"
  # SHA-256 of https://github.com/$REPO/archive/refs/tags/$VERSION.tar.gz.
  # On each release, after pushing the tag, set it to the output of:
  #   curl -fsSL https://github.com/atanesyan-h-pm/nur-keyboard/archive/refs/tags/<tag>.tar.gz | shasum -a 256
  # When empty, the download is installed without checksum verification (with a warning).
  EXPECTED_SHA256="1b0f55a16112d4a855b4bd86b60944d29dd6e3c3e780054f0103482deeb80f90"

  DEST="$HOME/Library/Keyboard Layouts"

  if [ "$(uname -s)" != "Darwin" ]; then
    echo "Nur is for macOS only." >&2
    exit 1
  fi

  if [ "${1:-}" = "--uninstall" ]; then
    rm -rf "$DEST/Nur.bundle" "$DEST/Armenian.bundle"   # Armenian.bundle = pre-1.0 name
    echo "Nur removed."
    echo "Remove the AM Nur layouts in System Settings > Keyboard > Text Input > Input Sources > Edit…,"
    echo "then log out and back in."
    return 0
  fi

  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT

  # Local checkout? Only when this script was run as a file named install.sh (sh install.sh,
  # ./install.sh, scripts/install.sh). Piped from curl, $0 is the shell ("sh", "/bin/sh", "-sh", …),
  # so a stray file or folder named like the shell in the current directory can't be mistaken for it.
  here=""
  self="$0"
  case "$(basename -- "$self")" in
    install.sh)
      if [ -f "$self" ]; then
        # Resolve symlinks so a linked install.sh finds the Nur.bundle next to the real file.
        while [ -L "$self" ]; do
          link=$(readlink "$self")
          case "$link" in
            /*) self="$link" ;;
            *) self="$(dirname -- "$self")/$link" ;;
          esac
        done
        here=$(cd -- "$(dirname -- "$self")" && pwd -P)
      fi
      ;;
  esac

  if [ -n "$here" ] && [ -f "$here/Nur.bundle/Contents/Info.plist" ]; then
    src="$here/Nur.bundle"
    echo "Installing Nur from $here"
  else
    url="https://github.com/$REPO/archive/refs/tags/$VERSION.tar.gz"
    echo "Downloading Nur $VERSION from github.com/$REPO …"
    curl -fsSL "$url" -o "$tmp/nur.tar.gz"
    if [ -n "$EXPECTED_SHA256" ]; then
      if ! echo "$EXPECTED_SHA256  $tmp/nur.tar.gz" | shasum -a 256 -c - >/dev/null; then
        echo "Checksum mismatch for $url — not installing." >&2
        exit 1
      fi
      echo "Checksum verified."
    else
      echo "Warning: no checksum is set for $VERSION; installing without verification." >&2
    fi
    mkdir "$tmp/src"
    tar -xzf "$tmp/nur.tar.gz" -C "$tmp/src"
    src=$(find "$tmp/src" -maxdepth 2 -type d -name Nur.bundle | head -n 1)
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
