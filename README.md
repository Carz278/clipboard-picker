# clipboard-tui

A lightweight clipboard history manager for [Caelestia](https://github.com/caelestia-dots/caelestia) / Hyprland, built on top of `cliphist` and `fuzzel`.

It adds a **pin (favorite)** feature to the default Caelestia clipboard, plus a quick menu for delete / wipe / show-pinned actions, all from a single `Super + V` keybind.

## Features

- Toggle behavior: press `Super + V` to open, press again to close
- Top menu for quick actions: `pin`, `delete`, `unpin`, `wipe`, `pinned`
- Pin (favorite) clipboard entries that survive `cliphist wipe`
- Fuzzy search through clipboard history (powered by `fuzzel`)
- Theme-aware: colors follow the current Caelestia scheme (via `fuzzel.ini`)
- Tiny: single shell script, no Python, no extra daemon

## Why?

Caelestia's built-in clipboard (via `caelestia clipboard`) is simple but lacks:

- A pin feature (like HyDE's favorites)
- A menu for bulk actions

`clipboard-tui` keeps the same lightweight `cliphist` + `fuzzel` stack, but adds those missing pieces in about 60 lines of bash.

## Prerequisites

- `cliphist` - clipboard history manager
- `wl-clipboard` - provides `wl-copy` / `wl-paste`
- `fuzzel` - the launcher used by Caelestia

Install on Arch:

    sudo pacman -S cliphist wl-clipboard fuzzel

## Installation

### Quick install

    git clone https://github.com/Carz278/clipboard-tui.git
    cd clipboard-tui
    ./install.sh

Then follow the printed instructions to update `hypr-vars.lua` and `hypr-user.lua`.

### Manual installation

#### 1. Clone this repository

    git clone https://github.com/Carz278/clipboard-tui.git
    cd clipboard-tui

#### 2. Copy the script to a stable location

    mkdir -p ~/.local/bin
    cp clipboard.sh ~/.local/bin/clipboard.sh
    chmod +x ~/.local/bin/clipboard.sh

#### 3. Ensure cliphist is recording clipboard history

Add to `~/.config/caelestia/hypr-user.lua`:

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

#### 4. Disable Caelestia's built-in clipboard keybind

Caelestia already binds `Super + V` (and `Super + Alt + V`) to its own clipboard implementation. You MUST disable those first, otherwise both will trigger at the same time.

Edit `~/.config/caelestia/hypr-vars.lua` and empty the clipboard-related keybinds:

    return {
      -- Disable Caelestia's built-in clipboard shortcuts
      kbClipboard = "",
      kbClipboardDel = "",

      -- Keep any existing overrides (e.g. kbTodoWs = "")
    }

If you have other variables in `hypr-vars.lua`, keep them. Only empty the clipboard ones.

#### 5. Bind your own Super + V

Edit `~/.config/caelestia/hypr-user.lua` and add:

    hl.bind("SUPER + V", hl.dsp.exec_cmd("/home/YOUR_USER/.local/bin/clipboard.sh"))

Replace `YOUR_USER` with your actual username.

#### 6. Log out and log back in

Because `hypr-vars.lua` and `hypr-user.lua` are only read at Hyprland startup.

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
- Select `pin`: choose a history entry to pin
- Select `delete`: choose a history entry to remove
- Select `unpin`: choose a pinned entry to unpin
- Select `wipe`: confirm to clear all history (pinned entries are kept in the favorites file)
- Select `pinned`: choose a pinned entry to copy

Press `Super + V` again to close the menu.

## Files

- `clipboard.sh` - the main script
- `install.sh` - automated installer
- `~/.local/share/cliphist/favorites` - pinned entries (one per line)

## Configuration

Colors and layout are inherited from `~/.config/fuzzel/fuzzel.ini`. Caelestia automatically updates the `[colors]` section when the scheme changes, so the clipboard colors always match your theme.

## Credits

Inspired by [HyDE-Project/HyDE](https://github.com/HyDE-Project/HyDE)'s clipboard menu. Reimplemented independently for Caelestia.

## License

MIT
