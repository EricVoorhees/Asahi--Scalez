#!/bin/bash

# Function to check internet connectivity
check_internet() {
    echo "Checking internet connection..."
    if ! ping -c 1 google.com &>/dev/null; then
        echo -e "\033[31mNo internet connection detected! Exiting...\033[0m"
        exit 1
    fi
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

# Update the system and install dependencies
echo "Installing necessary dependencies..."
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
