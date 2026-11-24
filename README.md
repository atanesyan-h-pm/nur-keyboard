# Armenian Keyboard Layouts for macOS

Six Armenian keyboard layouts for macOS, ported key for key from the xkeyboard-config `am` layouts.

| Layout | Based on (xkeyboard-config `symbols/am`) |
|---|---|
| Armenian Standard | `basic` (default) |
| Armenian Phonetic | `phonetic` |
| Armenian Phonetic Alt | `phonetic-alt` |
| Armenian Eastern | `eastern` |
| Armenian Western | `western` |
| Armenian Eastern Alt | `eastern-alt` |

The upstream `olpc` and `olpc-phonetic` variants only add a group-switch key that macOS doesn't use. On a Mac
they are identical to Armenian Standard and Armenian Phonetic Alt, so they aren't shipped separately.

Full key tables: [docs/mapping-tables.md](docs/mapping-tables.md).

## Modifiers

| Keys | Output |
|---|---|
| none / Shift | the Armenian layout, as upstream |
| Caps Lock | capital Armenian letters (punctuation keys unchanged) |
| Option, Shift+Option | US QWERTY Latin characters (macOS addition) |
| Command | US QWERTY, so Cmd+C / Cmd+V / Cmd+Z etc. work |
| Control | standard control characters |

## Install

```bash
scripts/install.sh
```

Then **log out and back in**, open System Settings › Keyboard › Input Sources › Edit… › **+** › Armenian,
and add the layouts you want.

If a layout doesn't appear after logging back in, macOS may be using a stale cache. Delete it and log in again:

```bash
sudo rm -f /private/var/folders/*/*/-Caches-/com.apple.IntlDataCache*
```

If "Use Caps Lock to switch to and from …" is on in Input Sources, Caps Lock switches input sources instead of
typing capitals.

Uninstall: remove the layouts from Input Sources, run `scripts/uninstall.sh`, then log out and back in.

## Compatibility

Keyboard layouts are XML data with no compiled code, so the same files work on Apple Silicon and Intel.
No Rosetta, code signing or admin rights are needed. Tested on macOS 26.7 / Apple M4.

Key codes follow ANSI positions. On ISO keyboards macOS may swap the key left of `1` and the key left of `Z`.

## Repository layout

- `Armenian.bundle/` — the installable bundle. The `.keylayout` files are maintained by hand.
- `upstream/` — vendored xkeyboard-config source and license (see `upstream/SOURCE.md`). Don't edit.
- `docs/mapping-tables.md` — the transcription worksheet: xkb key → mac keycode → characters, per layout.
- `scripts/validate.sh` — checks the layouts against Apple's DTD, lints the plists, checks ids and `KLInfo` entries.

After editing a `.keylayout`, run `scripts/validate.sh`, reinstall, and log out and back in. Ukelele (free) can
open these files if you'd rather edit them in a GUI.

## Credits

Key mappings come from [xkeyboard-config](https://gitlab.freedesktop.org/xkeyboard-config/xkeyboard-config).
See `LICENSE` and `upstream/COPYING`.
