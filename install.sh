#!/bin/sh
# Nur — Armenian keyboard layouts for macOS
#
# Install:      curl -fsSL https://atanesyan-h-pm.github.io/nur-keyboard/install.sh | sh
# Uninstall:    curl -fsSL https://atanesyan-h-pm.github.io/nur-keyboard/install.sh | sh -s -- --uninstall
# Clear cache:  curl -fsSL https://atanesyan-h-pm.github.io/nur-keyboard/install.sh | sh -s -- --clear-cache
#
# Installs for the current user only (~/Library/Keyboard Layouts); no admin password needed.
# Run from a checkout (sh install.sh), it installs that checkout's Nur.bundle instead of downloading.

# Everything is inside main() so a partially downloaded script never runs.
main() {
  set -eu
  REPO="atanesyan-h-pm/nur-keyboard"

  # Release to download. Pinned to a tag (not the moving main branch) so every user gets the same,
  # reviewed files.
  VERSION="v1.1.0"
  # SHA-256 of https://github.com/$REPO/archive/refs/tags/$VERSION.tar.gz.
  # On each release, after pushing the tag, set it to the output of:
  #   curl -fsSL https://github.com/atanesyan-h-pm/nur-keyboard/archive/refs/tags/<tag>.tar.gz | shasum -a 256
  # When empty, the download is installed without checksum verification (with a warning).
  EXPECTED_SHA256="da66baa44287dcc23ddc70377f4b58f1052150b46d6112e96b13a245276f0a1a"

  DEST="$HOME/Library/Keyboard Layouts"
  SETTINGS="System Settings > Keyboard > Text Input > Input Sources > Edit…"

  usage() {
    echo "usage: install.sh [--uninstall | --clear-cache | --help]"
    echo "  (no option)    install Nur for the current user"
    echo "  --uninstall    remove Nur (remove the AM Nur layouts in System Settings first)"
    echo "  --clear-cache  clear macOS's keyboard-layout cache, e.g. when layouts don't show up"
  }

  action=install
  while [ $# -gt 0 ]; do
    case "$1" in
      --uninstall|--clear-cache)
        if [ "$action" != install ]; then
          echo "install.sh: use only one of --uninstall and --clear-cache" >&2; usage >&2; exit 2
        fi
        action=${1#--}
        ;;
      -h|--help) usage; return 0 ;;
      *) echo "install.sh: unknown option '$1'" >&2; usage >&2; exit 2 ;;
    esac
    shift
  done

  if [ "$(uname -s)" != "Darwin" ]; then
    echo "Nur is for macOS only." >&2
    exit 1
  fi

  # Remove macOS's per-user keyboard-layout cache, so the next login re-reads Keyboard Layouts.
  # macOS rebuilds it at login. Never fails the run.
  clear_cache() {
    d=$(getconf DARWIN_USER_CACHE_DIR 2>/dev/null) || d=""
    d=${d%/}   # works with or without a trailing slash
    if [ -n "$d" ] && [ -d "$d" ]; then
      rm -f "$d"/com.apple.IntlDataCache.le* 2>/dev/null || true
    fi
  }

  # True if any Nur layout is still turned on in Input Sources: today's ids (-21001…), future ones,
  # the pre-1.0 "Armenian …" names (same ids), and the "Nur …" / "AM Nur …" names.
  nur_enabled() {
    defaults read com.apple.HIToolbox AppleEnabledInputSources 2>/dev/null \
      | grep -Eq 'KeyboardLayout ID" = "?-2100[0-9]+|KeyboardLayout Name" = ".*Nur'
  }

  # Names of enabled Nur entries (by id or name) that have no layout file in the installed bundle:
  # entries left over from an older version with different names. macOS lists them, but they can't
  # be selected. One name per line.
  #
  # `defaults read` prints an old-style plist with non-ASCII text escaped (\U0570…) and quotes
  # backslashed; plutil turns it into XML with real UTF-8, so the names shown to the user are readable.
  # If plutil can't parse it, fall back to reading the old-style text directly.
  stale_entries() {
    raw=$(defaults read com.apple.HIToolbox AppleEnabledInputSources 2>/dev/null) || raw=""
    [ -n "$raw" ] || return 0
    if xml=$(printf '%s\n' "$raw" | plutil -convert xml1 -o - - 2>/dev/null); then
      printf '%s\n' "$xml" | awk '
        /<dict>/ { id = ""; name = ""; key = "" }
        /<key>/  { key = $0; sub(/.*<key>/, "", key); sub(/<\/key>.*/, "", key); next }
        /<(string|integer)>/ {
          v = $0; sub(/.*<(string|integer)>/, "", v); sub(/<\/(string|integer)>.*/, "", v)
          if (key == "KeyboardLayout ID") id = v
          if (key == "KeyboardLayout Name") {
            gsub(/&lt;/, "<", v); gsub(/&gt;/, ">", v); gsub(/&quot;/, "\"", v); gsub(/&apos;/, "'"'"'", v); gsub(/&amp;/, "\\&", v)
            name = v
          }
        }
        /<\/dict>/ { if (name != "" && (id ~ /^-2100[0-9]+$/ || name ~ /Nur/)) print name }'
    else
      printf '%s\n' "$raw" | awk '
        /\{/ { id = ""; name = "" }
        /"KeyboardLayout ID" =/   { id = $0;   sub(/.*= *"?/, "", id);   sub(/"?;.*/, "", id) }
        /"KeyboardLayout Name" =/ { name = $0; sub(/.*= *"?/, "", name); sub(/"?;.*/, "", name) }
        /\}/ { if (name != "" && (id ~ /^-2100[0-9]+$/ || name ~ /Nur/)) print name }'
    fi | while IFS= read -r n; do
      [ -f "$DEST/Nur.bundle/Contents/Resources/$n.keylayout" ] || echo "$n"
    done
  }

  # Can we talk to the user? Piped from curl, stdin is the script, so prompts read /dev/tty.
  have_tty() { (exec </dev/tty) 2>/dev/null; }

  if [ "$action" = clear-cache ]; then
    clear_cache
    echo "Cleared the keyboard-layout cache. Log out and log back in to finish."
    return 0
  fi

  if [ "$action" = uninstall ]; then
    if nur_enabled; then
      echo "Nur layouts are still turned on. Remove them first, so no broken entries are left behind:"
      echo "  $SETTINGS"
      echo "  select each AM Nur layout and click the minus (−) button."
      if have_tty; then
        printf "Press Return once you've removed them (Ctrl-C to cancel)… "
        read -r _ </dev/tty || true   # || true: Ctrl-D (EOF) must not abort under set -e
        echo ""
        if nur_enabled; then
          echo "Some Nur layouts still look turned on; removing Nur anyway." >&2
        fi
      fi
    fi
    rm -rf "$DEST/Nur.bundle" "$DEST/Armenian.bundle"   # Armenian.bundle = pre-1.0 name
    clear_cache
    echo "Nur removed. Log out and log back in to finish."
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

  # Upgrading over an older Nur while its layouts are turned on leaves entries in Input Sources that
  # point at the old names and can't be switched to. Remember whether this is an upgrade.
  upgrade=no
  if [ -e "$DEST/Nur.bundle" ] || [ -e "$DEST/Armenian.bundle" ]; then upgrade=yes; fi

  mkdir -p "$DEST"
  rm -rf "$DEST/Nur.bundle" "$DEST/Armenian.bundle"   # Armenian.bundle = pre-1.0 name
  cp -R "$src" "$DEST/"
  xattr -dr com.apple.quarantine "$DEST/Nur.bundle" 2>/dev/null || true
  clear_cache

  echo ""
  echo "Nur is installed in $DEST/Nur.bundle"
  echo ""
  stale=""
  if [ "$upgrade" = yes ]; then stale=$(stale_entries); fi
  if [ -n "$stale" ]; then
    echo "Upgrade note: these older Nur layouts are still turned on, and no longer exist under that name:"
    printf '%s\n' "$stale" | sed 's/^/    /'
    echo "  1. Log out and log back in (Apple menu > Log Out)."
    echo "  2. $SETTINGS: select each one above and click the minus (−) button."
    echo "  3. Click +, choose Armenian, and add the AM Nur layouts you want."
  elif [ "$upgrade" = yes ] && nur_enabled; then
    echo "Updated. Log out and log back in to use the new version of your AM Nur layouts."
  else
    echo "Next:"
    echo "  1. Log out and log back in (Apple menu > Log Out)."
    echo "  2. $SETTINGS > + > Armenian,"
    echo "     choose the AM Nur layouts and click Add."
  fi
}

main "$@"
