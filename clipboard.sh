#!/bin/bash
# clipboard.sh - Clipboard manager with menu and toggle
# Keybind: Super + V

# ========== Toggle ==========
LOCK_FILE="/tmp/clipboard-toggle.lock"

# Check if ANY fuzzel process is running
if pgrep -x fuzzel > /dev/null 2>&1; then
    pkill -x fuzzel
    rm -f "$LOCK_FILE"
    exit 0
fi

# ========== Main ==========
touch "$LOCK_FILE"

FAV_FILE="$HOME/.local/share/cliphist/favorites"
mkdir -p "$(dirname "$FAV_FILE")"
touch "$FAV_FILE"

build_menu() {
    {
        echo "pin"
        echo "delete"
        echo "unpin"
        echo "wipe"
        echo "pinned"
        echo "────"
        cliphist list
    }
}

chosen=$(build_menu | fuzzel --dmenu --prompt "Clipboard " --width 60)
rm -f "$LOCK_FILE"

[ -z "$chosen" ] && exit 0

case "$chosen" in
    "pin")
        target=$(cliphist list | fuzzel --dmenu --prompt "pin > " --width 60)
        [ -z "$target" ] && exit 0
        grep -Fxq "$target" "$FAV_FILE" || echo "$target" >> "$FAV_FILE"
        exit 0
        ;;
    "delete")
        target=$(cliphist list | fuzzel --dmenu --prompt "delete > " --width 60)
        [ -z "$target" ] && exit 0
        echo "$target" | cliphist delete
        exit 0
        ;;
    "unpin")
        target=$(cat "$FAV_FILE" | fuzzel --dmenu --prompt "unpin > " --width 60)
        [ -z "$target" ] && exit 0
        grep -Fxv "$target" "$FAV_FILE" > "$FAV_FILE.tmp" && mv "$FAV_FILE.tmp" "$FAV_FILE"
        exit 0
        ;;
    "wipe")
        confirm=$(echo -e "no\nyes" | fuzzel --dmenu --prompt "clear all history? " --width 40)
        [ "$confirm" = "yes" ] && cliphist wipe
        exit 0
        ;;
    "pinned")
        target=$(cat "$FAV_FILE" | fuzzel --dmenu --prompt "pinned > " --width 60)
        [ -z "$target" ] && exit 0
        decoded=$(cliphist list | grep -F "$target" | head -1 | cliphist decode)
        [ -n "$decoded" ] && echo "$decoded" | wl-copy
        exit 0
        ;;
    "────")
        exit 0
        ;;
esac

echo "$chosen" | cliphist decode | wl-copy
