# clipboard-picker

> **Note**: This project was written with the help of AI. Please review the code before using it in production.


A lightweight clipboard history manager for [Caelestia](https://github.com/caelestia-dots/caelestia) / Hyprland, built on top of `cliphist` and `fuzzel`.

It adds a pin (favorite) feature to the default Caelestia clipboard, plus a quick menu for delete / wipe / show-pinned actions, all from a single `Super + V` keybind.

## Features

- Toggle behavior: press `Super + V` to open, press again to close (works on the main menu and on submenus)
- Top menu for quick actions: `pin`, `delete`, `unpin`, `wipe`, `pinned`
- Pin (favorite) clipboard entries that survive `cliphist wipe`
- Fuzzy search through clipboard history (powered by `fuzzel`)
- Theme-aware: colors follow the current Caelestia scheme
- Tiny: single shell script, no Python, no extra daemon

## Why

Caelestia's built-in clipboard (via `caelestia clipboard`) is simple but lacks:

- A pin feature (like HyDE's favorites)
- A menu for bulk actions

`clipboard-picker` keeps the same lightweight `cliphist` + `fuzzel` stack, but adds those missing pieces in about 60 lines of bash.

## Prerequisites

- `cliphist` - clipboard history manager
- `wl-clipboard` - provides `wl-copy` / `wl-paste`
- `fuzzel` - the launcher used by Caelestia

Install on Arch:

    sudo pacman -S cliphist wl-clipboard fuzzel

## Installation

### Quick install

    git clone git@github.com:Carz278/clipboard-picker.git
    cd clipboard-picker
    ./install.sh

Then follow the printed instructions to update `hypr-vars.lua` and `hypr-user.lua`.

### Manual install

1. Copy the script:

       mkdir -p ~/.local/bin
       cp clipboard.sh ~/.local/bin/clipboard.sh
       chmod +x ~/.local/bin/clipboard.sh

2. Ensure cliphist is recording. Add to `~/.config/caelestia/hypr-user.lua`:

       hl.exec_once("wl-paste --watch cliphist store")

   Or create a systemd user service:

       mkdir -p ~/.config/systemd/user
       cat > ~/.config/systemd/user/cliphist.service <<'SYSEOF'
       [Unit]
       Description=Clipboard history watcher
       After=graphical-session.target

       [Service]
       ExecStart=/usr/bin/wl-paste --watch /usr/bin/cliphist store
       Restart=on-failure

       [Install]
       WantedBy=default.target
       SYSEOF
       systemctl --user daemon-reload
       systemctl --user enable --now cliphist

3. Disable Caelestia's built-in clipboard keybind. Edit `~/.config/caelestia/hypr-vars.lua`:

       return {
         kbClipboard = "",
         kbClipboardDel = "",
       }

4. Bind your own `Super + V`. Edit `~/.config/caelestia/hypr-user.lua`:

       hl.bind("SUPER + V", hl.dsp.exec_cmd("~/.local/bin/clipboard.sh"))

5. Log out and log back in.

## Usage

Press `Super + V` to open the clipboard menu:

    pin
    delete
    unpin
    wipe
    pinned
    ----
    <your clipboard history...>

- Select a history entry: copy it back to clipboard
- `pin`: choose a history entry to pin
- `delete`: choose a history entry to remove
- `unpin`: choose a pinned entry to unpin
- `wipe`: clear all history (pinned entries are kept in the favorites file)
- `pinned`: choose a pinned entry to copy

Press `Super + V` again to close the menu.

## Toggle behavior

`Super + V` toggles the clipboard menu:

- Press once: the menu opens.
- Press again: the menu closes.
- Works on the main menu and on submenus (`pin`, `delete`, etc.).

`Super + Alt + V` toggles the clipboard in delete mode.

## Files

- `clipboard.sh` - main script
- `install.sh` - automated installer
- `~/.local/share/cliphist/favorites` - pinned entries (one per line)

## Configuration

Colors and layout are inherited from `~/.config/fuzzel/fuzzel.ini`. Caelestia automatically updates the `[colors]` section when the scheme changes, so the clipboard colors always match your theme.

## Credits

Inspired by [HyDE-Project/HyDE](https://github.com/HyDE-Project/HyDE)'s clipboard menu. Reimplemented independently for Caelestia.

## License

MIT
