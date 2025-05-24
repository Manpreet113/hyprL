#!/bin/bash

# HyprL Installation Script for Existing Arch Users
# Author: Manpreet
# Repo: https://github.com/Manpreet113/hyprL

set -Eeuo pipefail
trap 'echo "Error occurred at line $LINENO"; exit 1' ERR

REPO="https://github.com/Manpreet113/hyprL.git"
CONFIG_DIR="$HOME/.config"
DOTFILES_DIR="$HOME/dotfiles"

# Colors
GREEN="\033[1;32m"
RED="\033[1;31m"
BLUE="\033[1;34m"
NC="\033[0m"


# Required packages
REQUIRED_PKGS=(hyprland git rofi wayland wayland-protocols libinput libxkbcommon mesa vulkan-intel
 vulkan-mesa-layers xdg-desktop-portal wlroots waybar kitty dunst nwg-dock-hyprland nautilus networkmanager 
 network-manager-applet wget unzip gum rsync xdg-desktop-portal-hyprland )

# Helper: Print a banner
echo_banner() {
    echo -e "${BLUE}"
    echo " __                                      ________                                "    
    echo "|  \                                    |        \                               "    
    echo "| $$____   __    __   ______    ______  | $$$$$$$$ ______    _______   ______    "    
    echo "| $$    \ |  \  |  \ /      \  /      \ | $$__    |      \  /       \ /      \   "    
    echo "| $$$$$$$\| $$  | $$|  $$$$$$\|  $$$$$$\| $$  \    \$$$$$$\|  $$$$$$$|  $$$$$$\  "    
    echo "| $$  | $$| $$  | $$| $$  | $$| $$   \$$| $$$$$   /      $$ \$$    \ | $$    $$  "    
    echo "| $$  | $$| $$__/ $$| $$__/ $$| $$      | $$_____|  $$$$$$$ _\$$$$$$\| $$$$$$$$  "    
    echo "| $$  | $$ \$$    $$| $$    $$| $$      | $$     \\$$    $$|       $$ \$$     \  "    
    echo " \$$   \$$ _\$$$$$$$| $$$$$$$  \$$       \$$$$$$$$ \$$$$$$$ \$$$$$$$   \$$$$$$$  "    
    echo "          |  \__| $$| $$                                       hyprL setup script"    
    echo "           \$$    $$| $$                                                         "    
    echo "            \$$$$$$  \$$                                                         "   

    echo -e "${NC}"
}

# Ask for sudo access
ask_sudo() {
    # Ask for sudo password upfront
if sudo -v; then
    # Keep sudo alive while the script runs
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
else
    echo -e "${RED}:: Failed to obtain sudo access. Exiting...${NC}"
    exit 1
fi
}

# Run system update
update_system() {
    echo -e "${GREEN}:: Updating system packages...${NC}"
    sudo pacman -Syu --noconfirm
}

# Install AUR helper (yay)
get_yay() {
    if ! command -v yay &> /dev/null; then
    echo ":: yay not found, installing..."
    tmpdir=$(mktemp -d)
    git clone https://aur.archlinux.org/yay.git "$tmpdir"
    pushd "$tmpdir" || exit
    makepkg -si --noconfirm
    popd
    rm -rf "$tmpdir"
fi
}

# Helper: Install missing packages
install_packages() {
    echo -e "${GREEN}:: Checking required packages...${NC}"
    missing=()
    for pkg in "${REQUIRED_PKGS[@]}"; do
        if ! pacman -Qi "$pkg" &>/dev/null; then
            missing+=("$pkg")
        fi
    done

    if [ ${#missing[@]} -eq 0 ]; then
        echo ":: All packages already installed."
    else
        echo ":: Installing missing packages: ${missing[*]}"
        sudo pacman -S --noconfirm "${missing[@]}"
    fi
}

# Backup existing configs
backup_configs() {
    echo -e "${GREEN}:: Backing up existing configs...${NC}"
    if [ -d "$CONFIG_DIR" ]; then
        BACKUP_DIR="$HOME/.config-backup-$(date +%s)"
        mkdir -p "$BACKUP_DIR"

    	for dir in $(ls "$DOTFILES_DIR"); do
		if [ -d "$CONFIG_DIR/$dir" ]; then
            	echo "-- Backing up $dir"
            	mv "$CONFIG_DIR/$dir" "$BACKUP_DIR/"
                echo ":: Backup stored in $BACKUP_DIR"
        	fi
    	done
    else
        echo -e "${RED}:: No existing configs found...${NC}"
        echo -e "${GREEN}:: Creating config directories...${NC}"
	    mkdir "$CONFIG_DIR"

    	
    fi
}

# Clone the dotfiles
clone_dotfiles() {
    echo -e "${GREEN}:: Cloning hyprL dotfiles...${NC}"
    rm -rf "$DOTFILES_DIR"
    git clone "$REPO" "$DOTFILES_DIR"
}

# Symlink configs
symlink_configs() {
    echo -e "${GREEN}:: Creating symlinks...${NC}"
    shopt -s dotglob nullglob

for src in "$DOTFILES_DIR"/* "$DOTFILES_DIR"/.*; do
    base=$(basename "$src")

    # Skip '.' and '..' which show up with dotglob
    [[ "$base" == "." || "$base" == ".." ]] && continue

    dest="$CONFIG_DIR/$base"

    # If destination exists and is not a symlink, skip
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo -e "${RED}:: $dest exists and is not a symlink. Skipping...${NC}"
        continue
    fi

    ln -sf "$src" "$dest"
done

shopt -u dotglob nullglob

}

# Ask for reboot
ask_reboot() {
    echo -e "${GREEN}:: HyprL setup complete.${NC}"
    read -p "Reboot now to apply changes? [y/N]: " choice
    case "$choice" in
        y|Y ) systemctl reboot;;
        * ) echo ":: Reboot cancelled. You can reboot manually later.";;
    esac
}

# === Main Script ===
echo_banner
ask_sudo
update_system
get_yay
install_packages
clone_dotfiles
backup_configs
symlink_configs
ask_reboot
