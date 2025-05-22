#!/bin/bash
# ------------------------------------------------------
# Compare installed version with used version
# ------------------------------------------------------

source ~/.config/hyprL/version/library.sh

if [ -f /usr/share/hyprL-hyprland/dotfiles/.config/hyprL/version/name ]; then
    installed_version=$(cat /usr/share/hyprL-hyprland/dotfiles/.config/hyprL/version/name)
    used_version=$(cat ~/.config/hyprL/version/name)
    if [[ $(testvercomp $used_version $installed_version "<") == "0" ]]; then
        notify-send "Please run hyprL-hyprland-setup" "Installed version is newer then the version you're currently using."
    fi
fi
