# My Arch Linux Configuration

This repository contains my personal Arch Linux configuration (dotfiles) and package lists.
It is designed to replicate my setup on a new installation.

## Structure

- `backup.sh`: Script to backup current configuration and package lists to this folder.
- `install.sh`: Script to restore configuration and install packages from this folder.
- `pkglist_*.txt`: Package lists for pacman, yay (AUR), and flatpak.
- `.config/`: Backup of `~/.config` directories.
- `.zshrc`, `.bashrc`: Backup of home directory dotfiles.

## Usage

### Backup

Run the backup script to update the repository with your current system state:

```bash
./backup.sh
```

Then commit and push changes:

```bash
git add .
git commit -m "Update config"
git push
```

### Restore / Install

To restore this configuration on a new system:

1. Clone this repository:

   ```bash
   git clone <your-repo-url> ~/my-arch-config
   cd ~/my-arch-config
   ```

2. Run the install script:
   ```bash
   ./install.sh
   ```

**Note:** The `install.sh` script has package installation commands commented out by default for safety. Open the script and uncomment the lines in the "Install Packages" section to enable them.
