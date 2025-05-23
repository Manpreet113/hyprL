#!/bin/bash

# HyprL Installation Script for Existing Arch Users
# Author: Manpreet
# Repo: https://github.com/Manpreet113/hyprL

set -e

REPO="https://github.com/Manpreet113/hyprL.git"
CONFIG_DIR="$HOME/.config"
DOTFILES_DIR="$HOME/.hyprL"

# Colors
GREEN="\033[1;32m"
RED="\033[1;31m"
NC="\033[0m"

# Required packages
REQUIRED_PKGS=(hyprland git rofi waybar kitty dunst nwg-dock-hyprland nautilus gtk-3 gtk-4 wget unzip gum rsync git xdg-desktop-portal-hyprland)

# Helper: Print a banner
echo_banner() {
    echo -e "${GREEN}"
    echo "   _                      _     "
    echo "  | |__   ___  _ __ ___ | |__  "
    echo "  | '_ \ / _ \| '_ \` _ \| '_ \ "
    echo "  | | | | (_) | | | | | | |_) |"
    echo "  |_| |_|\___/|_| |_| |_|_.__/  HyprL Setup"
    echo -e "${NC}"
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
        	fi
    	done
    else
	    mkdir "$CONFIG_DIR"

    	echo ":: Backup stored in $BACKUP_DIR"
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
    for dir in $(ls "$DOTFILES_DIR"); do
        ln -sf "$DOTFILES_DIR/$dir" "$CONFIG_DIR/$dir"
    done
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
install_packages
clone_dotfiles
backup_configs
symlink_configs
ask_reboot
