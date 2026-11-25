#!/bin/bash
# Check every .keylayout against Apple's DTD and lint the bundle plists.
# xmllint can't read XML 1.1 control-character refs (&#x0008; etc.), which macOS
# layouts need, so a masked copy is validated instead.
#
# Not `set -e`: every check runs and reports, and the exit code says whether any failed.
# pipefail makes the `sed | xmllint` pipeline fail when either side fails.
set -uo pipefail
cd "$(dirname "$0")/.."
DTD=/System/Library/DTDs/KeyboardLayout.dtd
INFO=Nur.bundle/Contents/Info.plist
fail=0

# Replace XML 1.1 control-character references with a space reference so xmllint (XML 1.0) accepts them:
#   hex:     &#x1; … &#x1F; and &#x7F;, any case, any number of leading zeros (&#x8;, &#x0008;, &#x007f;)
#   decimal: &#1; … &#31; and &#127;, any number of leading zeros (&#8;, &#0127;)
# Printable references (e.g. &#x0022;) are left alone. NUL is rejected separately, before masking.
mask_control_refs() {
  sed -E \
    -e '1s/version="1\.1"/version="1.0"/' \
    -e 's/&#[xX]0*([1-9a-fA-F]|1[0-9a-fA-F]|7[fF]);/\&#x0020;/g' \
    -e 's/&#0*([1-9]|[12][0-9]|3[01]|127);/\&#x0020;/g' \
    "$1"
}

for f in Nur.bundle/Contents/Resources/*.keylayout; do
  n=$(basename "$f" .keylayout)

  # U+0000 is illegal in every XML version; macOS silently drops the whole layout.
  if grep -Eq '&#[xX]0+;|&#0+;' "$f"; then
    echo "FAIL  $f contains a NUL character reference"; fail=1; continue
  fi

  if mask_control_refs "$f" | xmllint --noout --dtdvalid "$DTD" - 2>/dev/null; then
    echo "ok    $f"
  else
    echo "FAIL  $f (DTD validation)"; fail=1
  fi

  # Every layout needs a KLInfo entry whose TISInputSourceID contains "keyboardlayout";
  # otherwise macOS ignores it.
  if ! plutil -extract "KLInfo_$n" xml1 -o /dev/null "$INFO" 2>/dev/null; then
    echo "FAIL  no KLInfo_$n in Info.plist"; fail=1; continue
  fi
  sid=$(plutil -extract "KLInfo_$n.TISInputSourceID" raw -o - "$INFO" 2>/dev/null || true)
  case "$sid" in
    *keyboardlayout*) echo "ok    KLInfo_$n.TISInputSourceID = $sid" ;;
    "") echo "FAIL  KLInfo_$n has no TISInputSourceID"; fail=1 ;;
    *)  echo "FAIL  KLInfo_$n.TISInputSourceID '$sid' must contain 'keyboardlayout'"; fail=1 ;;
  esac

  # Each layout has its own icon: an SVG source named after the TISInputSourceID suffix
  # (built by scripts/build-icons.sh) and the .icns macOS shows next to the .keylayout.
  if [ -n "$sid" ] && [ ! -f "branding/icons/${sid##*.}.svg" ]; then
    echo "FAIL  no branding/icons/${sid##*.}.svg for $n"; fail=1
  fi
  if [ ! -f "${f%.keylayout}.icns" ]; then
    echo "FAIL  no ${f%.keylayout}.icns (run scripts/build-icons.sh)"; fail=1
  fi
done

for p in Nur.bundle/Contents/*.plist Nur.bundle/Contents/Resources/*.lproj/*.strings; do
  if plutil -lint "$p" >/dev/null; then echo "ok    $p"; else echo "FAIL  $p"; fail=1; fi
done

# Layout ids must be unique.
dups=$(grep -ho 'id="-[0-9]*"' Nur.bundle/Contents/Resources/*.keylayout | sort | uniq -d)
if [ -n "$dups" ]; then echo "FAIL  duplicate layout ids: $dups"; fail=1; fi

bid=$(plutil -extract CFBundleIdentifier raw -o - "$INFO" 2>/dev/null || true)
case "$bid" in
  *keyboardlayout*) echo "ok    CFBundleIdentifier = $bid" ;;
  *) echo "FAIL  CFBundleIdentifier '$bid' must contain 'keyboardlayout'"; fail=1 ;;
esac

exit $fail
