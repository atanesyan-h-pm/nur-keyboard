<picture>
  <source media="(prefers-color-scheme: dark)" srcset="branding/banner-dark.svg">
  <img alt="Nur — Armenian keyboard layouts for macOS" src="branding/banner-light.svg" width="100%">
</picture>

# Nur — Armenian keyboards for your Mac

**Nur** (Նուռ) means pomegranate, a motif woven into Armenian rugs. Nur adds six Armenian keyboard
layouts to macOS, so you can type Armenian in any app: Mail, Messages, Pages, Word, your web browser and more.

The layouts are copied key for key from the Armenian layouts used on Linux
([xkeyboard-config](https://gitlab.freedesktop.org/xkeyboard-config/xkeyboard-config)), so if you already know
one of them, your fingers will feel at home.

## The six layouts

After installing, you will find these in your Mac's keyboard settings. If your Mac's language is set to
Armenian, they show their Armenian names instead.

| Name in English | Name in Armenian | Linux name (xkeyboard-config) |
|---|---|---|
| AM Nur Standard | հյ Նուռ Ստանդարտ | Armenian |
| AM Nur Phonetic | հյ Նուռ Հնչյունային | Armenian (phonetic) |
| AM Nur Phonetic Alt | հյ Նուռ Հնչյունային 2 | Armenian (alt. phonetic) |
| AM Nur Eastern | հյ Նուռ Արևելյան | Armenian (eastern) |
| AM Nur Western | հյ Նուռ Արևմտյան | Armenian (western) |
| AM Nur Eastern Alt | հյ Նուռ Արևելյան 2 | Armenian (alt. eastern) |

Not sure which one you want? Add a few and try them. You can [see every key](docs/mapping-tables.md) of every layout.

In the menu bar, each layout shows a small pixel pomegranate: red with a golden crown and seeds. It is easy
to see in both light and dark mode.

## Install

You need a Mac with macOS. Both Apple Silicon (M1, M2, …) and Intel Macs work. You don't need an
administrator password.

### 1. Run the installer

Open the **Terminal** app (in Applications › Utilities), paste this line and press Return:

```bash
curl -fsSL https://raw.githubusercontent.com/atanesyan-h-pm/nur-keyboard/main/install.sh | sh
```

It downloads Nur from GitHub and copies the layouts into the `Keyboard Layouts` folder inside your own
Library folder. It only affects your user account. Want to see what it does first? Read
[install.sh](install.sh).

### 2. Log out and log back in

macOS only notices new keyboard layouts when you log in. Choose  Apple menu › **Log Out**, then log back in.
Restarting the Mac works too.

### 3. Add the layouts you want

1. Open **System Settings** ( Apple menu › System Settings).
2. Click **Keyboard** in the sidebar.
3. Under **Text Input**, next to **Input Sources**, click **Edit…**.
4. Click the **+** button at the bottom left.
5. Choose **Armenian** in the language list.
6. Select the **AM Nur …** layouts you want (hold Command to select more than one) and click **Add**.

A layout you have already added won't appear in the **+** list again.

## Switching between keyboards

Once you have more than one input source, you can switch in any of these ways:

- **The input menu** in the menu bar (the flag or pomegranate icon near the clock): click it and pick a layout.
- **The 🌐 / fn key**: press it to switch. If it does something else, open System Settings › Keyboard and set
  **Press 🌐 key to** to **Change Input Source**.
- **Control + Space**: switches to the previous input source.

## Special keys

| You hold | You get |
|---|---|
| nothing | the layout's normal characters (lowercase Armenian letters) |
| Shift | the layout's Shift characters (capital Armenian letters and symbols) |
| Caps Lock | capital Armenian letters (number and punctuation keys don't change) |
| Option, or Shift + Option | the same as without Option, or with Shift |
| Command | normal Mac shortcuts: ⌘C copy, ⌘V paste, ⌘Z undo, ⌘Q quit and so on, all in the usual places |
| Control | standard control keys, as on any Mac layout |

## Troubleshooting

**The layouts don't appear in the list after I log in.**
Log out and log back in once more. If they are still missing, macOS may be using an old cache:

1. In Terminal, run `getconf DARWIN_USER_CACHE_DIR`. It prints a folder like `/var/folders/xx/xxxx/C/`.
2. Delete the cache files in that folder:

   ```bash
   rm -f "$(getconf DARWIN_USER_CACHE_DIR)"com.apple.IntlDataCache.le*
   ```

3. Log out and log back in.

**Caps Lock switches the keyboard instead of typing capitals.**
In System Settings › Keyboard › Text Input › Input Sources › Edit…, turn off
**Use the Caps Lock key to switch to and from …**.

**One or two keys near the left edge are swapped.**
On keyboards sold outside the US (with a tall Return key), macOS sometimes swaps the key left of **1**
and the key left of **Z**. This comes from macOS, not from Nur.

## Uninstall

1. Open System Settings › Keyboard › Text Input › Input Sources › **Edit…**.
2. Select each **AM Nur …** layout and click the **−** button.
3. In Terminal, run:

   ```bash
   curl -fsSL https://raw.githubusercontent.com/atanesyan-h-pm/nur-keyboard/main/install.sh | sh -s -- --uninstall
   ```

4. Log out and log back in.

## Compatibility

Nur's layouts are plain data files with no program code inside. That means:

- They work on Apple Silicon and Intel Macs (tested on an Apple M4 with macOS 26.7).
- No Rosetta, code signing or administrator password is needed.

## For developers

Building, testing and changing the layouts is described in [DEVELOPMENT.md](DEVELOPMENT.md).

## Credits and license

The key mappings come from [xkeyboard-config](https://gitlab.freedesktop.org/xkeyboard-config/xkeyboard-config)
(`symbols/am`). Thank you to its authors.

Nur is released under the license in [LICENSE](LICENSE). The mappings taken from xkeyboard-config are also
covered by [upstream/COPYING](upstream/COPYING).

<img alt="Nur logo" src="branding/logo.svg" width="96">
