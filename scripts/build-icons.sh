#!/bin/bash
# Build each layout's menu-bar .icns from its own SVG in branding/icons/.
#
# The SVG is picked by the layout's TISInputSourceID suffix in Info.plist:
#   KLInfo_AM Nur Phonetic Alt.TISInputSourceID = am.nur.keyboardlayout.nur.phonetic-alt
#   -> branding/icons/phonetic-alt.svg -> Nur.bundle/Contents/Resources/AM Nur Phonetic Alt.icns
set -euo pipefail
cd "$(dirname "$0")/.."
INFO=Nur.bundle/Contents/Info.plist
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

# Compile the rasteriser once instead of interpreting it with `swift` for every size of every icon.
swiftc -O scripts/svg2png.swift -o "$tmp/svg2png"

count=0
for f in Nur.bundle/Contents/Resources/*.keylayout; do
  n=$(basename "$f" .keylayout)
  sid=$(plutil -extract "KLInfo_$n.TISInputSourceID" raw -o - "$INFO" 2>/dev/null) \
    || { echo "build-icons: no KLInfo_$n.TISInputSourceID in $INFO" >&2; exit 1; }
  variant=${sid##*.}
  svg=branding/icons/$variant.svg
  [ -f "$svg" ] || { echo "build-icons: missing $svg for '$n' (TISInputSourceID $sid)" >&2; exit 1; }

  set=$tmp/$variant.iconset; mkdir "$set"
  for s in 16 32 128 256 512; do
    "$tmp/svg2png" "$svg" "$set/icon_${s}x${s}.png" "$s"
    "$tmp/svg2png" "$svg" "$set/icon_${s}x${s}@2x.png" $((s * 2))
  done
  iconutil -c icns "$set" -o "${f%.keylayout}.icns"
  count=$((count + 1))
done
echo "icons written for $count layouts"
