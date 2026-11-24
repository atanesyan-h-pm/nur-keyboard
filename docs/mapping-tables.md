# Mapping tables

Transcription worksheet from `upstream/symbols-am` to the macOS `.keylayout` files.
Each cell is `base / Shift`. `*(US)*` means the key is not defined by the xkb variant; on macOS it falls back to US QWERTY.

## Notes

- Upstream defines only 2 levels (base, Shift). There are no AltGr levels and no dead keys.
- macOS-only additions: **Caps Lock** gives the Shift letter for Armenian letters (other keys stay base);
  **Option** / **Shift+Option** type the same as base / Shift (like AltGr on Linux, which has no level 3 here),
  so macOS files the layouts under Armenian only; **Command** uses US QWERTY so shortcuts work;
  **Control** produces standard control characters.
- `LatQ/LatW/LatY/LatA/LatZ` in upstream are aliases of `AD01/AD02/AD06/AC01/AB01`.
- `KP_n` (Eastern/Western Shift row) are typed as plain digits.
- Upstream `olpc` and `olpc-phonetic` only add a Linux group-switch option (`group(olpc)`); on macOS they are
  identical to Standard and Phonetic Alt, so they are not shipped as separate layouts.
- Key codes are ANSI positions. On ISO Mac keyboards macOS may swap codes 10 and 50 (`TLDE`/`LSGT`).

## Key codes

| xkb | mac keycode | US QWERTY |
|---|---|---|
| `TLDE` | 50 | ``` |
| `AE01` | 18 | `1` |
| `AE02` | 19 | `2` |
| `AE03` | 20 | `3` |
| `AE04` | 21 | `4` |
| `AE05` | 23 | `5` |
| `AE06` | 22 | `6` |
| `AE07` | 26 | `7` |
| `AE08` | 28 | `8` |
| `AE09` | 25 | `9` |
| `AE10` | 29 | `0` |
| `AE11` | 27 | `-` |
| `AE12` | 24 | `=` |
| `AD01` | 12 | `q` |
| `AD02` | 13 | `w` |
| `AD03` | 14 | `e` |
| `AD04` | 15 | `r` |
| `AD05` | 17 | `t` |
| `AD06` | 16 | `y` |
| `AD07` | 32 | `u` |
| `AD08` | 34 | `i` |
| `AD09` | 31 | `o` |
| `AD10` | 35 | `p` |
| `AD11` | 33 | `[` |
| `AD12` | 30 | `]` |
| `AC01` | 0 | `a` |
| `AC02` | 1 | `s` |
| `AC03` | 2 | `d` |
| `AC04` | 3 | `f` |
| `AC05` | 5 | `g` |
| `AC06` | 4 | `h` |
| `AC07` | 38 | `j` |
| `AC08` | 40 | `k` |
| `AC09` | 37 | `l` |
| `AC10` | 41 | `;` |
| `AC11` | 39 | `'` |
| `BKSL` | 42 | `\` |
| `LSGT` | 10 | `§` |
| `AB01` | 6 | `z` |
| `AB02` | 7 | `x` |
| `AB03` | 8 | `c` |
| `AB04` | 9 | `v` |
| `AB05` | 11 | `b` |
| `AB06` | 45 | `n` |
| `AB07` | 46 | `m` |
| `AB08` | 43 | `,` |
| `AB09` | 47 | `.` |
| `AB10` | 44 | `/` |

## Layouts

| xkb | Standard (basic) | Phonetic (phonetic) | Phonetic Alt (phonetic-alt) | Eastern (eastern) | Western (western) | Eastern Alt (eastern-alt) |
|---|---|---|---|---|---|---|
| `TLDE` | ՝ / ՜ | ՝ / ՜ | ՝ / ՜ | ՝ / ՜ | ՝ / ՜ | ՝ / ՜ |
| `AE01` | ֆ / Ֆ | է / Է | է / Է | ։ / 1 | ։ / 1 | ։ / 1 |
| `AE02` | ձ / Ձ | թ / Թ | թ / Թ | ձ / Ձ | ձ / Ձ | ձ / Ձ |
| `AE03` | ֊ / — | փ / Փ | փ / Փ | յ / Յ | յ / Յ | յ / Յ |
| `AE04` | , / $ | ձ / Ձ | ձ / Ձ | ՛ / 3 | ՛ / 3 | ՛ / 3 |
| `AE05` | ։ / … | ջ / Ջ | ջ / Ջ | , / 4 | , / 4 | , / 4 |
| `AE06` | ՞ / % | ւ / Ւ | ւ / Ւ | - / 9 | - / 9 | - / 9 |
| `AE07` | ․ / և | և / ֏ | և / ֏ | . / և | . / և | . / և |
| `AE08` | ՛ / ՚ | ռ / Ռ | ր / Ր | « / ( | « / ( | « / ( |
| `AE09` | ) / ( | չ / Չ | չ / Չ | » / ) | » / ) | » / ) |
| `AE10` | օ / Օ | ճ / Ճ | ճ / Ճ | օ / Օ | օ / Օ | օ / Օ |
| `AE11` | է / Է | ֊ / ― | ֊ / ― | ռ / Ռ | ռ / Ռ | ռ / Ռ |
| `AE12` | ղ / Ղ | ժ / Ժ | ժ / Ժ | ժ / Ժ | ժ / Ժ | ժ / Ժ |
| `AD01` | ճ / Ճ | ք / Ք | ք / Ք | խ / Խ | խ / Խ | խ / Խ |
| `AD02` | փ / Փ | ո / Ո | ո / Ո | ւ / Ւ | վ / Վ | ւ / Ւ |
| `AD03` | բ / Բ | ե / Ե | ե / Ե | է / Է | է / Է | է / Է |
| `AD04` | ս / Ս | ր / Ր | ռ / Ռ | ր / Ր | ր / Ր | ր / Ր |
| `AD05` | մ / Մ | տ / Տ | տ / Տ | տ / Տ | դ / Դ | տ / Տ |
| `AD06` | ո / Ո | ը / Ը | ը / Ը | ե / Ե | ե / Ե | ե / Ե |
| `AD07` | ւ / Ւ | ւ / Ւ | ւ / Ւ | ը / Ը | ը / Ը | ը / Ը |
| `AD08` | կ / Կ | ի / Ի | ի / Ի | ի / Ի | ի / Ի | ի / Ի |
| `AD09` | ը / Ը | օ / Օ | օ / Օ | ո / Ո | ո / Ո | ո / Ո |
| `AD10` | թ / Թ | պ / Պ | պ / Պ | պ / Պ | բ / Բ | պ / Պ |
| `AD11` | ծ / Ծ | խ / Խ | խ / Խ | չ / Չ | չ / Չ | չ / Չ |
| `AD12` | ց / Ց | ծ / Ծ | ծ / Ծ | ջ / Ջ | ջ / Ջ | ջ / Ջ |
| `AC01` | ջ / Ջ | ա / Ա | ա / Ա | ա / Ա | ա / Ա | ա / Ա |
| `AC02` | վ / Վ | ս / Ս | ս / Ս | ս / Ս | ս / Ս | ս / Ս |
| `AC03` | գ / Գ | դ / Դ | դ / Դ | դ / Դ | տ / Տ | դ / Դ |
| `AC04` | ե / Ե | ֆ / Ֆ | ֆ / Ֆ | ֆ / Ֆ | ֆ / Ֆ | ֆ / Ֆ |
| `AC05` | ա / Ա | գ / Գ | գ / Գ | գ / Գ | կ / Կ | ք / Ք |
| `AC06` | ն / Ն | հ / Հ | հ / Հ | հ / Հ | հ / Հ | հ / Հ |
| `AC07` | ի / Ի | յ / Յ | յ / Յ | ճ / Ճ | ճ / Ճ | ճ / Ճ |
| `AC08` | տ / Տ | կ / Կ | կ / Կ | կ / Կ | ք / Ք | կ / Կ |
| `AC09` | հ / Հ | լ / Լ | լ / Լ | լ / Լ | լ / Լ | լ / Լ |
| `AC10` | պ / Պ | ; / ։ | ; / ։ | թ / Թ | թ / Թ | թ / Թ |
| `AC11` | ր / Ր | ՛ / " | ՛ / " | փ / Փ | փ / Փ | փ / Փ |
| `BKSL` | » / « | շ / Շ | շ / Շ | ' / ՞ | ' / ՞ | ' / ՞ |
| `LSGT` | ? / ֊ | ? / ֊ | ? / ֊ | *(US)* | *(US)* | *(US)* |
| `AB01` | ժ / Ժ | զ / Զ | զ / Զ | զ / Զ | զ / Զ | զ / Զ |
| `AB02` | դ / Դ | ղ / Ղ | ղ / Ղ | ց / Ց | ց / Ց | ց / Ց |
| `AB03` | չ / Չ | ց / Ց | ց / Ց | ք / Ք | գ / Գ | գ / Գ |
| `AB04` | յ / Յ | վ / Վ | վ / Վ | վ / Վ | ւ / Ւ | վ / Վ |
| `AB05` | զ / Զ | բ / Բ | բ / Բ | բ / Բ | պ / Պ | բ / Բ |
| `AB06` | լ / Լ | ն / Ն | ն / Ն | ն / Ն | ն / Ն | ն / Ն |
| `AB07` | ք / Ք | մ / Մ | մ / Մ | մ / Մ | մ / Մ | մ / Մ |
| `AB08` | խ / Խ | , / « | , / « | շ / Շ | շ / Շ | շ / Շ |
| `AB09` | շ / Շ | ․ / » | ․ / » | ղ / Ղ | ղ / Ղ | ղ / Ղ |
| `AB10` | ռ / Ռ | / / ՞ | / / ՞ | ծ / Ծ | ծ / Ծ | ծ / Ծ |
