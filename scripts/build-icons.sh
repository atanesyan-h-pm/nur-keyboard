#!/bin/bash
# Build the menu-bar .icns for every layout from branding/icon.svg.
set -euo pipefail
cd "$(dirname "$0")/.."
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
set=$tmp/nur.iconset; mkdir "$set"
for s in 16 32 128 256 512; do
  swift scripts/svg2png.swift branding/icon.svg "$set/icon_${s}x${s}.png" $s
  swift scripts/svg2png.swift branding/icon.svg "$set/icon_${s}x${s}@2x.png" $((s*2))
done
iconutil -c icns "$set" -o "$tmp/nur.icns"
for f in Nur.bundle/Contents/Resources/*.keylayout; do
  cp "$tmp/nur.icns" "${f%.keylayout}.icns"
done
echo "icons written for $(ls Nur.bundle/Contents/Resources/*.icns | wc -l | tr -d ' ') layouts"
