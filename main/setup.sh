#!/bin/bash

# HyprL Installation Script for Existing Arch Users
# Author: Manpreet
# Repo: https://github.com/Manpreet113/hyprL

set -Eeuo pipefail
trap 'echo -e "\033[1;31mError occurred at line $LINENO. Exiting...\033[0m"; exit 1' ERR

REPO="https://github.com/Manpreet113/hyprL.git"
CONFIG_DIR="$HOME/.config"
DOTFILES_DIR="$HOME/dotfiles"

# Colors for output formatting
GREEN="\033[1;32m"
RED="\033[1;31m"
BLUE="\033[1;34m"
NC="\033[0m"

# List of required packages to install
REQUIRED_PKGS=(hyprland git rofi wayland wayland-protocols libinput libxkbcommon mesa vulkan-intel
vulkan-mesa-layers xdg-desktop-portal wlroots waybar kitty dunst nwg-dock-hyprland nautilus networkmanager
network-manager-applet wget unzip gum rsync xdg-desktop-portal-hyprland hyprlock hypridle swaync hyprshade swww fastfetch matugen nvim waypaper wlogout zsh
grim slurp swappy cliphist hyprpaper pipewire)

# === Functions ===

# Prints a banner for the script
echo_banner() {
    echo -e "${BLUE}"
    echo " __                                      ________                                "    
    echo "|  \                                    |        \                               "    
    echo "| \$\$____   __    __   ______    ______  | \$\$\$\$\$\$\$\$ ______    _______   ______    "    
    echo "| \$\$    \ |  \  |  \ /      \  /      \ | \$\$__    |      \  /       \ /      \   "    
    echo "| \$\$\$\$\$\$\$\| \$\$  | \$\$|  \$\$\$\$\$\$\|  \$\$\$\$\$\$\| \$\$  \    \\$\$\$\$\$\$\|  \$\$\$\$\$\$\$|  \$\$\$\$\$\$\  "    
    echo "| \$\$  | \$\$| \$\$  | \$\$| \$\$  | \$\$| \$\$   \\$\$| \$\$\$\$\$   /      \$\$ \\$\$    \ | \$\$    \$\$  "    
    echo "| \$\$  | \$\$| \$\$__/ \$\$| \$\$__/ \$\$| \$\$      | \$\$_____|  \$\$\$\$\$\$\$ _\\$\$\$\$\$\$\| \$\$\$\$\$\$\$\$  "    
    echo "| \$\$  | \$\$ \\$\$    \$\$| \$\$    \$\$| \$\$      | \$\$     \\\$\$    \$\$|       \$\$ \\$\$     \  "    
    echo " \\$\$   \\$\$ _\\$\$\$\$\$\$\$| \$\$\$\$\$\$\$  \\$\$       \\$\$\$\$\$\$\$\$ \\$\$\$\$\$\$\$ \\$\$\$\$\$\$\$   \\$\$\$\$\$\$\$  "    
    echo "          |  \__| \$\$| \$\$                                       hyprL setup script"    
    echo "           \\$\$    \$\$| \$\$                                                         "    
    echo "            \\$\$\$\$\$\$  \\$\$                                                         "   
    echo -e "${NC}"
}

# Prevent running the script as root
check_root() {
    if [ "$EUID" -eq 0 ]; then
        echo -e "${RED}:: Don't run this script as root!${NC}"
        exit 1
    fi
}

# Check for an active internet connection
check_internet() {
    echo -e "${GREEN}:: Checking internet connection...${NC}"
    if ! ping -q -c 1 archlinux.org &>/dev/null; then
        echo -e "${RED}:: No internet detected. Connect first.${NC}"
        exit 1
    fi
}

# Ask for sudo access and keep it alive
ask_sudo() {
    if sudo -v; then
        while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    else
        echo -e "${RED}:: Failed to obtain sudo access. Exiting...${NC}"
        exit 1
    fi
}

# Update all system packages
update_system() {
    echo -e "${GREEN}:: Updating system packages...${NC}"
    sudo pacman -Syu --noconfirm 
    sudo pacman -S --noconfirm --needed base-devel git
}

# Install yay AUR helper if not present
get_yay() {
    if ! command -v yay &>/dev/null; then
        echo -e "${GREEN}:: yay not found. Installing...${NC}"
        tmpdir=$(mktemp -d)
        git clone https://aur.archlinux.org/yay.git "$tmpdir"
        pushd "$tmpdir" >/dev/null
        makepkg -si || {
            echo -e "${RED}:: Failed to install yay. Check AUR or build deps.${NC}"
            exit 1
        }
        popd >/dev/null
        rm -rf "$tmpdir"
    fi
}

# Install all required packages using yay
install_packages() {
    echo -e "${GREEN}:: Checking required packages...${NC}"
    missing=()
    for pkg in "${REQUIRED_PKGS[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            missing+=("$pkg")
        fi
    done

    if [ ${#missing[@]} -eq 0 ]; then
        echo ":: All required packages are already installed."
    else
        echo ":: Installing: ${missing[*]}"
        yay -S --needed --noconfirm "${missing[@]}"
    fi
}

# Clone dotfiles repo or use current directory if already inside a git repo
clone_dotfiles() {
    echo -e "${GREEN}:: Setting up dotfiles...${NC}"

    if git rev-parse --is-inside-work-tree &>/dev/null; then
        echo ":: Already inside a git repo. Using current directory."
        DOTFILES_DIR="$(pwd)"
    else
        echo ":: Cloning repo to $DOTFILES_DIR"
        rm -rf "$DOTFILES_DIR"
        git clone --filter=blob:none --no-checkout "$REPO"
        cd hyprL
        git sparse-checkout init --cone
        git sparse-checkout set dotfiles
        git checkout master
    fi
}

# Backup existing configs in .config before symlinking new ones
backup_configs() {
    echo -e "${GREEN}:: Backing up existing configs...${NC}"
    if [ -d "$CONFIG_DIR" ]; then
        BACKUP_DIR="$HOME/.config-backup-$(date +%s)"
        mkdir -p "$BACKUP_DIR"
        for dir in "$DOTFILES_DIR"/* "$DOTFILES_DIR"/.*; do
            base=$(basename "$dir")
            [[ "$base" =~ ^(\.|\.\.|\.git|\.gitignore|\.gitattributes)$ ]] && continue
            if [ -e "$CONFIG_DIR/$base" ]; then
                echo "-- Backing up $base"
                mv "$CONFIG_DIR/$base" "$BACKUP_DIR/"
            fi
        done
        echo ":: Backup stored at $BACKUP_DIR"
    else
        mkdir -p "$CONFIG_DIR"
    fi
}

# Symlink dotfiles from repo to .config directory
symlink_configs() {
    echo -e "${GREEN}:: Creating symlinks...${NC}"
    shopt -s dotglob nullglob
    for src in "$DOTFILES_DIR"/* "$DOTFILES_DIR"/.*; do
        base=$(basename "$src")
        [[ "$base" =~ ^(\.|\.\.|\.git|\.gitignore|\.gitattributes)$ ]] && continue

        dest="$CONFIG_DIR/$base"

        if [ -e "$dest" ] && [ ! -L "$dest" ]; then
            echo -e "${RED}:: $dest exists and is not a symlink. Skipping...${NC}"
            continue
        fi

        ln -sf "$src" "$dest"
    done
    shopt -u dotglob nullglob
}

# Ask user to reboot after setup
ask_reboot() {
    echo -e "${GREEN}:: HyprL setup complete.${NC}"
    read -p "Reboot now to apply changes? [y/N]: " choice
    case "$choice" in
        y|Y ) systemctl reboot;;
        * ) echo ":: Reboot skipped. Restart manually later.";;
    esac
}

# === Main ===
echo_banner           # Print banner
check_root            # Ensure not running as root
check_internet        # Check for internet connection
ask_sudo              # Ask for sudo and keep alive
update_system         # Update system packages
get_yay               # Install yay if missing
install_packages      # Install required packages
backup_configs        # Backup existing configs
clone_dotfiles        # Clone or use dotfiles repo
symlink_configs       # Symlink new configs
ask_reboot            # Prompt for reboot