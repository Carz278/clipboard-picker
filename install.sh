#!/bin/bash
# install.sh - Deploy clipboard-picker to a Caelestia environment
# Usage: ./install.sh

set -e

# ==================== Colors ====================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()   { echo -e "${GREEN}[ OK ]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()  { echo -e "${RED}[FAIL]${NC} $1"; }

# ==================== Distro detection ====================
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

install_system_deps() {
    local distro
    distro=$(detect_distro)
    case "$distro" in
        arch|manjaro|endeavouros)
            info "Detected Arch-based distro, using pacman..."
            sudo pacman -S --needed cliphist wl-clipboard fuzzel
            ;;
        debian|ubuntu|linuxmint|pop)
            info "Detected Debian-based distro, using apt..."
            sudo apt update
            sudo apt install -y cliphist wl-clipboard fuzzel
            ;;
        fedora|rhel|centos)
            info "Detected Fedora-based distro, using dnf..."
            sudo dnf install -y cliphist wl-clipboard fuzzel
            ;;
        *)
            warn "Unknown distro: $distro"
            warn "Please install manually:"
            warn "  - cliphist"
            warn "  - wl-clipboard"
            warn "  - fuzzel"
            return 1
            ;;
    esac
    return 0
}

# ==================== Basic checks ====================
info "Checking basic environment..."
if ! command -v bash &> /dev/null; then
    err "bash not found."
    exit 1
fi
ok "bash is installed"

# ==================== System dependencies ====================
info "Checking system dependencies..."
MISSING=()
for cmd in cliphist wl-copy fuzzel; do
    if ! command -v "$cmd" &> /dev/null; then
        MISSING+=("$cmd")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    warn "Missing commands: ${MISSING[*]}"
    read -p "Install them now? [Y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        install_system_deps
    else
        warn "Skipping system dependencies. The script may not work."
    fi
else
    ok "All system dependencies satisfied"
fi

# ==================== Project path ====================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
info "Project directory: $SCRIPT_DIR"

# ==================== Copy script ====================
info "Copying clipboard.sh to ~/.local/bin/..."
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/clipboard.sh" "$HOME/.local/bin/clipboard.sh"
chmod +x "$HOME/.local/bin/clipboard.sh"
ok "clipboard.sh installed at ~/.local/bin/clipboard.sh"

# ==================== Check Caelestia ====================
info "Checking Caelestia configuration..."
CAELESTIA_DIR="$HOME/.config/caelestia"
if [ ! -d "$CAELESTIA_DIR" ]; then
    err "Directory ~/.config/caelestia/ not found. Please install Caelestia first."
    exit 1
fi
ok "Caelestia config directory exists"

# ==================== Conflict check ====================
echo
echo "============================================"
echo "  Conflict check (important)"
echo "============================================"
echo

CONFLICT_FOUND=0

HYPR_VARS="$CAELESTIA_DIR/hypr-vars.lua"
if [ -f "$HYPR_VARS" ]; then
    if ! grep -q 'kbClipboard *= *""' "$HYPR_VARS"; then
        warn "hypr-vars.lua still has kbClipboard bound (Caelestia's default)."
        warn "This will conflict with our Super+V binding."
        echo
        echo "  Please edit $HYPR_VARS and empty the clipboard keybinds:"
        echo
        echo '    return {'
        echo '      kbClipboard = "",'
        echo '      kbClipboardDel = "",'
        echo '    }'
        echo
        CONFLICT_FOUND=1
    else
        ok "hypr-vars.lua already empties kbClipboard"
    fi
fi

if [ "$CONFLICT_FOUND" = "1" ]; then
    echo
    warn "Please resolve the conflict above before using Super+V."
fi

# ==================== Print guide ====================
echo
echo "============================================"
echo "  Installation complete"
echo "============================================"
echo
echo "Add this line to ~/.config/caelestia/hypr-user.lua:"
echo
echo "    hl.bind(\"SUPER + V\", hl.dsp.exec_cmd(\"$HOME/.local/bin/clipboard.sh\"))"
echo
echo "Then make sure cliphist is recording:"
echo
echo "    hl.exec_once(\"wl-paste --watch cliphist store\")"
echo
echo "============================================"
echo "  Log out and log back in to apply changes."
echo "============================================"
echo
