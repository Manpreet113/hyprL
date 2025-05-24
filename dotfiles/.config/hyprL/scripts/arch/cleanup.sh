#!/bin/bash
clear
aur_helper="$(cat ~/.config/hyprL/settings/aur.sh)"
figlet -f smslant "Cleanup"
echo
$aur_helper -Scc
