#!/bin/bash
# Check every .keylayout against Apple's DTD and lint the bundle plists.
# xmllint can't read XML 1.1 control-character refs (&#x0008; etc.), which macOS
# layouts need, so a masked copy is validated instead.
set -u
cd "$(dirname "$0")/.."
DTD=/System/Library/DTDs/KeyboardLayout.dtd
fail=0
for f in Nur.bundle/Contents/Resources/*.keylayout; do
  if sed -e '1s/version="1.1"/version="1.0"/' \
         -e 's/&#x00[01][0-9A-Fa-f];/\&#x0020;/g' -e 's/&#x007F;/\&#x0020;/g' "$f" \
     | xmllint --noout --dtdvalid "$DTD" - 2>/dev/null; then
    echo "ok    $f"
  else
    echo "FAIL  $f"; fail=1
  fi
done
for p in Nur.bundle/Contents/*.plist Nur.bundle/Contents/Resources/en.lproj/*.strings; do
  plutil -lint "$p" >/dev/null && echo "ok    $p" || { echo "FAIL  $p"; fail=1; }
done
# every layout must have a KLInfo entry and a unique id
ids=$(grep -ho 'id="-[0-9]*"' Nur.bundle/Contents/Resources/*.keylayout | sort)
[ "$(echo "$ids" | uniq -d)" = "" ] || { echo "FAIL  duplicate layout ids"; fail=1; }
for f in Nur.bundle/Contents/Resources/*.keylayout; do
  n=$(basename "$f" .keylayout)
  plutil -extract "KLInfo_$n" xml1 -o /dev/null Nur.bundle/Contents/Info.plist 2>/dev/null \
    || { echo "FAIL  no KLInfo_$n in Info.plist"; fail=1; }
done
exit $fail
