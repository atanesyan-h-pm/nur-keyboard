#!/bin/bash
# Package Nur.bundle as dist/Nur.bundle.zip for a GitHub Release (the Finder install option).
#
# Validates the bundle first, then zips a clean copy: no .DS_Store files, no extended attributes
# (quarantine, Finder info), no __MACOSX folder. Prints the path, size and SHA-256.
set -euo pipefail
cd "$(dirname "$0")/.."

# dist/ must never hold a zip that doesn't match the current tree: remove the previous one before
# anything else, and delete a half-made or unverified one if any later step fails.
out="$PWD/dist/Nur.bundle.zip"
rm -f "$out"
tmp=""
trap 'rc=$?; [ -n "$tmp" ] && rm -rf "$tmp"; [ $rc -eq 0 ] || rm -f "$out"' EXIT

scripts/validate.sh >/dev/null || { echo "package-release: scripts/validate.sh failed; fix that first" >&2; exit 1; }

mkdir -p dist
tmp=$(mktemp -d)

# Clean staging copy.
cp -R Nur.bundle "$tmp/"
find "$tmp/Nur.bundle" -name .DS_Store -delete
xattr -cr "$tmp/Nur.bundle"

# -X: leave out extra file attributes (uid/gid, Mac metadata). zip never writes __MACOSX/ entries;
# that's Finder's Compress command.
(cd "$tmp" && zip -r -X -q "$out" Nur.bundle)

# Self-check the archive.
unzip -tq "$out" >/dev/null || { echo "package-release: archive test failed" >&2; exit 1; }
listing=$(unzip -Z1 "$out")
if grep -Eq '(^|/)\.DS_Store$|^__MACOSX/' <<<"$listing"; then
  echo "package-release: archive contains .DS_Store or __MACOSX entries" >&2; exit 1
fi
layouts=$(grep -c '^Nur.bundle/Contents/Resources/[^/]*\.keylayout$' <<<"$listing" || true)
icons=$(grep -c '^Nur.bundle/Contents/Resources/[^/]*\.icns$' <<<"$listing" || true)
expected=$(find Nur.bundle/Contents/Resources -maxdepth 1 -name '*.keylayout' | wc -l | tr -d ' ')
if [ "$layouts" != "$expected" ] || [ "$icons" != "$expected" ]; then
  echo "package-release: expected $expected .keylayout and .icns files, got $layouts and $icons" >&2; exit 1
fi

size=$(stat -f %z "$out")
sha=$(shasum -a 256 "$out" | cut -d' ' -f1)
echo "dist/Nur.bundle.zip  ($size bytes, $layouts layouts, $icons icons)"
echo "sha256  $sha"
