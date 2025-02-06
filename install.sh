#!/bin/bash

# Enable debug mode for troubleshooting (optional)
set -x  # Uncomment this line if you want to see command execution details

# Ensure the script is executable
chmod +x $0

# Function to check internet connectivity
check_internet() {
    echo "Checking internet connection..."
    if ! ping -c 1 google.com &>/dev/null; then
        echo -e "\033[31mNo internet connection detected! Exiting...\033[0m"
        exit 1
    fi
}

# Function to check if a command exists (e.g., for dependencies)
check_command() {
    command -v "$1" &>/dev/null || { echo -e "\033[31m$1 is not installed. Installing...\033[0m"; return 1; }
    return 0
}

# Function to ask for user confirmation before proceeding
ask_for_confirmation() {
    read -p "$1 (y/n): " answer
    if [[ "$answer" != "y" ]]; then
        echo "Installation aborted!"
        exit 0
    fi
}

# Confirm installation
ask_for_confirmation "Do you want to install Asahi-Scalez and proceed with the setup?"

# Start the installation process
echo "Starting Asahi-Scalez installation..."

# Check for internet connectivity before proceeding
check_internet

# Ask user for confirmation to install dependencies
ask_for_confirmation "Do you want to install necessary dependencies and extensions?"

# Check and install required dependencies
echo "Checking for required dependencies..."

# Check if 'apt' package manager exists (for Debian-based systems)
check_command "apt" || exit 1

# Check if 'gnome-extensions' command is available
check_command "gnome-extensions" || { sudo apt install -y gnome-shell-extensions; }

# Update the system and install dependencies
echo "Updating system and installing required packages..."
sudo apt update -y
sudo apt install -y gnome-shell-extensions tilix gnome-shell python3-pip curl

# Install the Pop Shell extension (Pp Shell)
echo "Installing Pop Shell extension..."
gnome-extensions install https://extensions.gnome.org/extension/2899/pop-shell/

# Install the Auto-Tiling extension
echo "Installing Auto-Tiling extension..."
gnome-extensions install https://extensions.gnome.org/extension/38/auto-tiling/

# Enable the installed extensions
echo "Enabling Pop Shell and Auto-Tiling extensions..."
gnome-extensions enable pop-shell@system76.com
gnome-extensions enable auto-tiling@gnome-shell-extensions.gcampax.github.com

# Download the keybindings.json from the URL
echo "Downloading keybindings.json..."
curl -o ~/.config/gnome-shell/keybindings.json https://bit.ly/Scalez-Keybindings || { echo -e "\033[31mFailed to download keybindings.json. Aborting...\033[0m"; exit 1; }

# Apply keybindings configuration
echo "Applying keybinding configuration..."
mkdir -p ~/.config/gnome-shell/
cp keybindings.json ~/.config/gnome-shell/keybindings.json

# Reload GNOME Shell to apply changes
echo "Reloading GNOME Shell..."
gnome-shell --replace &

# Finalize installation and prompt user to reboot
echo -e "\033[32mInstallation complete! Press Enter to reboot your system.\033[0m"
read -p "Press Enter to reboot..."
reboot
