#!/bin/bash
# Build the menu-bar .icns for every layout from branding/icon.svg.
set -euo pipefail
cd "$(dirname "$0")/.."
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT

# Compile the rasteriser once instead of interpreting it with `swift` for each of the 10 sizes.
swiftc -O scripts/svg2png.swift -o "$tmp/svg2png"

set=$tmp/nur.iconset; mkdir "$set"
for s in 16 32 128 256 512; do
  "$tmp/svg2png" branding/icon.svg "$set/icon_${s}x${s}.png" "$s"
  "$tmp/svg2png" branding/icon.svg "$set/icon_${s}x${s}@2x.png" $((s * 2))
done
iconutil -c icns "$set" -o "$tmp/nur.icns"

count=0
for f in Nur.bundle/Contents/Resources/*.keylayout; do
  cp "$tmp/nur.icns" "${f%.keylayout}.icns"
  count=$((count + 1))
done
echo "icons written for $count layouts"
