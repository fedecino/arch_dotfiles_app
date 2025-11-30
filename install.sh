#!/bin/bash

# Define paths
BACKUP_DIR="$(dirname "$(realpath "$0")")"
CONFIG_DIR="$HOME/.config"

echo "Starting installation..."

# 1. Install Packages
echo "Installing packages..."

# Update system first
# sudo pacman -Syu --noconfirm

# Install Pacman packages
if [ -f "$BACKUP_DIR/pkglist_pacman.txt" ]; then
    echo "Installing pacman packages..."
    # Filter out packages that might cause issues or are already installed base groups
    # sudo pacman -S --needed --noconfirm - < "$BACKUP_DIR/pkglist_pacman.txt"
    echo "Skipping actual package installation in this script for safety. Uncomment lines to enable."
    echo "Command would be: sudo pacman -S --needed - < $BACKUP_DIR/pkglist_pacman.txt"
fi

# Install Yay (if not installed)
if ! command -v yay &> /dev/null; then
    echo "Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
fi

# Install AUR packages
if [ -f "$BACKUP_DIR/pkglist_yay.txt" ]; then
    echo "Installing AUR packages..."
    # yay -S --needed --noconfirm - < "$BACKUP_DIR/pkglist_yay.txt"
    echo "Skipping actual AUR package installation. Uncomment lines to enable."
fi

# Install Flatpaks
if [ -f "$BACKUP_DIR/pkglist_flatpak.txt" ]; then
    echo "Installing Flatpaks..."
    # Read line by line to install
    while read -r app; do
        # flatpak install -y flathub "$app"
        echo "Would install flatpak: $app"
    done < "$BACKUP_DIR/pkglist_flatpak.txt"
fi

# 2. Restore Configs
echo "Restoring config files..."

# List of .config directories to restore
CONFIGS=(
    "hypr"
    "kitty"
    "waybar"
    "rofi"
    "zshrc"
    "fastfetch"
    "nvim"
    "gtk-3.0"
    "gtk-4.0"
    "dconf"
)

for config in "${CONFIGS[@]}"; do
    if [ -d "$BACKUP_DIR/.config/$config" ]; then
        echo "Restoring $config..."
        # Backup existing config if it exists
        if [ -d "$CONFIG_DIR/$config" ]; then
            echo "Backing up existing $config to $CONFIG_DIR/${config}.bak.$(date +%s)"
            mv "$CONFIG_DIR/$config" "$CONFIG_DIR/${config}.bak.$(date +%s)"
        fi
        cp -r "$BACKUP_DIR/.config/$config" "$CONFIG_DIR/"
    else
        echo "Warning: Config for $config not found in backup, skipping."
    fi
done

# Restore Home directory files
HOME_FILES=(
    ".zshrc"
    ".zshrc_custom"
    ".bashrc"
)

for file in "${HOME_FILES[@]}"; do
    if [ -f "$BACKUP_DIR/$file" ]; then
        echo "Restoring $file..."
        if [ -f "$HOME/$file" ]; then
             echo "Backing up existing $file to $HOME/${file}.bak.$(date +%s)"
             mv "$HOME/$file" "$HOME/${file}.bak.$(date +%s)"
        fi
        cp "$BACKUP_DIR/$file" "$HOME/"
    fi
done

echo "Installation complete! Please restart your shell or reboot."
