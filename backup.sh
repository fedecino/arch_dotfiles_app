#!/bin/bash

# Define paths
BACKUP_DIR="$HOME/my-arch-config"
CONFIG_DIR="$HOME/.config"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR/.config"

echo "Starting backup..."

# 1. Package Lists
echo "Backing up package lists..."
if command -v pacman &> /dev/null; then
    pacman -Qqe > "$BACKUP_DIR/pkglist_pacman.txt"
fi

if command -v pacman &> /dev/null; then
    pacman -Qqem > "$BACKUP_DIR/pkglist_yay.txt"
fi

if command -v flatpak &> /dev/null; then
    flatpak list --app --columns=application > "$BACKUP_DIR/pkglist_flatpak.txt"
fi

# 2. Config Files
echo "Backing up config files..."

# List of .config directories to backup
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
    "autostart"
    "btop"
    "htop"
    "swaync"
    "wlogout"
)

for config in "${CONFIGS[@]}"; do
    if [ -d "$CONFIG_DIR/$config" ]; then
        echo "Backing up $config..."
        # Use rsync to copy directory content (dereferencing symlinks with -L)
        rsync -avL --delete "$CONFIG_DIR/$config" "$BACKUP_DIR/.config/"
    else
        echo "Warning: $CONFIG_DIR/$config not found, skipping."
    fi
done

# Config Files (Individual)
if [ -f "$CONFIG_DIR/mimeapps.list" ]; then
    echo "Backing up mimeapps.list..."
    cp "$CONFIG_DIR/mimeapps.list" "$BACKUP_DIR/.config/"
fi

# Home directory files
HOME_FILES=(
    ".zshrc"
    ".zshrc_custom"
    ".bashrc"
)

for file in "${HOME_FILES[@]}"; do
    if [ -f "$HOME/$file" ]; then
        echo "Backing up $file..."
        cp "$HOME/$file" "$BACKUP_DIR/"
    else
        echo "Warning: $HOME/$file not found, skipping."
    fi
done

# 3. Git Status
if [ -d "$BACKUP_DIR/.git" ]; then
    echo "Checking git status..."
    cd "$BACKUP_DIR"
    git status
else
    echo "Git repository not initialized yet. Run 'git init' in $BACKUP_DIR to start."
fi

echo "Backup complete! Files are in $BACKUP_DIR"
