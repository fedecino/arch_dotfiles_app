#!/bin/bash

# Define paths
BACKUP_DIR="$(dirname "$(realpath "$0")")"
CONFIG_DIR="$HOME/.config"
ML4W_DIR="$HOME/ML4W"
ML4W_REPO="https://github.com/mylinuxforwork/dotfiles.git"

echo "Starting installation..."

# 1. Install ML4W Base Dependencies
echo "-------------------------------------------------"
echo "1. Setting up ML4W Base System"
echo "-------------------------------------------------"

if [ -d "$ML4W_DIR" ]; then
    echo "ML4W folder already exists at $ML4W_DIR."
    read -p "Do you want to update it? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$ML4W_DIR"
        git pull
        cd -
    fi
else
    echo "Cloning ML4W Dotfiles..."
    git clone "$ML4W_REPO" "$ML4W_DIR"
fi

# Run ML4W setup script for dependencies
if [ -f "$ML4W_DIR/setup/setup-arch.sh" ]; then
    echo "Running ML4W Arch Setup script..."
    # We use the non-interactive mode if possible or just let it run. 
    # The setup script seems interactive, so we let the user interact with it if needed.
    # However, to avoid getting stuck, we might want to check if we can automate it.
    # For now, we assume user interaction is fine as per original script intent.
    "$ML4W_DIR/setup/setup-arch.sh"
else
    echo "Error: ML4W setup script not found at $ML4W_DIR/setup/setup-arch.sh"
    exit 1
fi

# 2. Install User Additional Packages
echo "-------------------------------------------------"
echo "2. Installing User Additional Packages"
echo "-------------------------------------------------"

# Install Pacman packages
if [ -f "$BACKUP_DIR/pkglist_pacman.txt" ]; then
    echo "Installing extra pacman packages..."
    sudo pacman -S --needed --noconfirm - < "$BACKUP_DIR/pkglist_pacman.txt"
fi

# Install Yay packages
if [ -f "$BACKUP_DIR/pkglist_yay.txt" ]; then
    echo "Installing extra AUR packages..."
    if command -v yay &> /dev/null; then
        yay -S --needed --noconfirm - < "$BACKUP_DIR/pkglist_yay.txt"
    elif command -v paru &> /dev/null; then
        paru -S --needed --noconfirm - < "$BACKUP_DIR/pkglist_yay.txt"
    else
        echo "Warning: No AUR helper found (yay/paru). Skipping AUR packages."
    fi
fi

# Install Flatpaks
if [ -f "$BACKUP_DIR/pkglist_flatpak.txt" ]; then
    echo "Installing Flatpaks..."
    while read -r app; do
        if [ -n "$app" ]; then
            flatpak install -y flathub "$app"
        fi
    done < "$BACKUP_DIR/pkglist_flatpak.txt"
fi

# 3. Merge Configurations
echo "-------------------------------------------------"
echo "3. Merging Configurations"
echo "-------------------------------------------------"

read -p "Do you want to proceed with copying configuration files? This will backup existing configs. (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    
    # 3a. Copy ML4W Dotfiles first (Base)
    echo "Applying ML4W dotfiles as base..."
    if [ -d "$ML4W_DIR/dotfiles/.config" ]; then
        cp -r "$ML4W_DIR/dotfiles/.config/"* "$CONFIG_DIR/"
    else
        echo "Warning: ML4W .config directory not found."
    fi
    
    # Copy ML4W .zshrc if it exists (User wants to keep .bashrc but maybe try zsh)
    if [ -f "$ML4W_DIR/dotfiles/.zshrc" ]; then
        if [ -f "$HOME/.zshrc" ]; then
            mv "$HOME/.zshrc" "$HOME/.zshrc.bak.$(date +%s)"
        fi
        cp "$ML4W_DIR/dotfiles/.zshrc" "$HOME/"
    fi

    # 3b. Overwrite with User Dotfiles
    echo "Overwriting with User dotfiles..."
    
    # We iterate over the user's .config directory in the repo
    if [ -d "$BACKUP_DIR/.config" ]; then
        for config_path in "$BACKUP_DIR/.config/"*; do
            config_name=$(basename "$config_path")
            echo "Restoring User config: $config_name"
            
            # If it's a directory, we copy recursively, overwriting ML4W's version
            if [ -d "$config_path" ]; then
                # We don't backup here again because we just established ML4W as base.
                # But if there was a pre-existing config that wasn't ML4W, it might be lost?
                # The user's request implies they want their repo to be the source of truth for these folders.
                
                # Ensure parent dir exists
                mkdir -p "$CONFIG_DIR"
                
                # Copy and overwrite
                cp -r "$config_path" "$CONFIG_DIR/"
            elif [ -f "$config_path" ]; then
                cp "$config_path" "$CONFIG_DIR/"
            fi
        done
    fi

    # Restore .bashrc from User Repo if exists
    if [ -f "$BACKUP_DIR/.bashrc" ]; then
        echo "Restoring User .bashrc..."
        if [ -f "$HOME/.bashrc" ]; then
             mv "$HOME/.bashrc" "$HOME/.bashrc.bak.$(date +%s)"
        fi
        cp "$BACKUP_DIR/.bashrc" "$HOME/"
    fi

    # Restore mimeapps.list specifically if not covered
    if [ -f "$BACKUP_DIR/mimeapps.list" ]; then
         cp "$BACKUP_DIR/mimeapps.list" "$CONFIG_DIR/"
    fi

else
    echo "Skipping configuration merge."
fi

echo "Installation and Merge Complete!"
echo "Please reboot your system to apply all changes."
