# 🌀 HyprL - My Hyprland Dotfiles

Welcome to **HyprL**, a clean, minimal, and sharp Hyprland rice made with ❤️ by [Manpreet113](https://github.com/Manpreet113).

This setup is designed for **Arch Linux** users who want a fully configured Wayland desktop with all the bells and whistles — ready to go.

> ⚠️ Built for people who know what they're doing. Or at least pretending to. 😉

---
## 🛠️ Features

- 🔹 Tiled Wayland WM: **Hyprland**
- 📂 File Manager: **Nautilus**
- 🚀 Launcher: **Rofi**
- 🐧 Terminal: **Kitty**
- 🔋 Bar: **Waybar**
- 🔔 Notifications: **Dunst**
- 🔒 Lock screen: **Hyprlock**
- 📁 Dock: **nwg-dock-hyprland**
- 🔌 Network manager: **NM-Applet**
- 🧼 Clean config structure, easily hackable
- ✅ Uses `yay` for installing AUR packages
- ⚙️ Automatically backs up old configs
- 🔗 Symlinks your new dotfiles into `~/.config`

---
## ⚡ Quick Install (for existing Arch users)

You don’t even have to clone the repo manually. Just run this bad boy:

```bash
bash <(curl -sL https://raw.githubusercontent.com/Manpreet113/hyprL/main/setup.sh)
```
### This will:

1. Update your system
2. Install all required packages (via yay)
3. Clone this repo into `~/dotfiles` (or use the current repo if inside one)
4. Backup existing config folders in `~/.config`
5. Symlink new configs from the repo.
6. Ask if you wanna reboot.

---
## 📦 Requirements

* 🧠 Arch Linux (btw)
* Internet connection
* Sudo access
* Some patience during install

---
## 🧩 Optional

* You can clone the repo manually if you want to inspect or customize:

```bash
git clone https://github.com/Manpreet113/hyprL.git
cd hyprL
bash setup.sh
```
