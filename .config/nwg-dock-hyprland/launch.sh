#    ___           __
#   / _ \___  ____/ /__
#  / // / _ \/ __/  '_/
# /____/\___/\__/_/\_\
#


config="$HOME/.config/gtk-3.0/settings.ini"
if [ ! -f $HOME/.config/hyprL/settings/dock-disabled ]; then
    killall nwg-dock-hyprland
    prefer_dark_theme="$(grep 'gtk-application-prefer-dark-theme' "$config" | sed 's/.*\s*=\s*//')"
    if [ $prefer_dark_theme == 0 ]; then
        style="style-light.css"
    else
        style="style-dark.css"
    fi
    nwg-dock-hyprland -i 43 -w 5 -mb 10 -ml 10 -mr 10 -x -s $style -nolauncher
else
    echo ":: Dock disabled"
fi