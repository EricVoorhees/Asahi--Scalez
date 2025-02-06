#!/bin/bash


GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No color

LOGFILE="/var/log/asahi-scalez-install.log"
exec > >(tee -a "$LOGFILE") 2>&1  # Log output for debugging

echo -e "${GREEN}Welcome to Asahi-Scalez: Pop!_OS-Style GNOME for Fedora Asahi Remix 41${NC}"

# Ensure script runs with sudo
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root (use sudo).${NC}"
    exit 1
fi

# Early internet connection check
echo -e "${GREEN}Checking internet connection...${NC}"
if ! ping -q -c 1 -W 1 google.com >/dev/null; then
    echo -e "${RED}No internet connection detected! Please connect and try again.${NC}"
    exit 1
fi

# Ask for confirmation before proceeding
read -p "Do you want to install Asahi-Scalez and configure everything? (y/n): " choice
if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
    echo -e "${YELLOW}Installation aborted.${NC}"
    exit 0
fi

# Update system and install required packages
echo -e "${GREEN}Updating system and installing required packages...${NC}"
dnf update -y || { echo -e "${RED}System update failed!${NC}"; exit 1; }
dnf install -y gnome-shell-extensions gnome-tweaks dconf-cli jq git make npm gnome-shell-extension-pop-shell gnome-shell-extension-dash-to-dock || { echo -e "${RED}Failed to install dependencies!${NC}"; exit 1; }

# Install Pp Shell manually if missing
if ! gnome-extensions list | grep -q "pop-shell@system76.com"; then
    echo -e "${GREEN}Installing Pp Shell manually...${NC}"
    mkdir -p ~/.local/share/gnome-shell/extensions
    git clone https://github.com/pop-os/shell.git ~/pop-shell
    cd ~/pop-shell
    make local-install || { echo -e "${RED}Pp Shell installation failed!${NC}"; exit 1; }
    cd ..
    rm -rf ~/pop-shell
else
    echo -e "${YELLOW}Pp Shell is already installed.${NC}"
fi

# Restore GNOME settings from dconf backup if available
if [ -f "configs/gnome-settings.conf" ]; then
    echo -e "${GREEN}Restoring GNOME settings...${NC}"
    dconf load / < configs/gnome-settings.conf
else
    echo -e "${RED}Warning: gnome-settings.conf not found. Skipping restore.${NC}"
fi

# Enable GNOME Extensions
echo -e "${GREEN}Enabling Pp Shell and Dash to Dock extensions...${NC}"
gnome-extensions enable pop-shell@system76.com || { echo -e "${RED}Failed to enable Pp Shell!${NC}"; }
gnome-extensions enable dash-to-dock@micxgx.gmail.com || { echo -e "${RED}Failed to enable Dash to Dock!${NC}"; }

# Enable trackpad gestures
echo -e "${GREEN}Enabling trackpad gestures...${NC}"
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.peripherals.touchpad natural-scroll true

# Configure Pp Shell shortcuts
echo -e "${GREEN}Configuring Pp Shell keyboard shortcuts...${NC}"
gsettings set org.gnome.shell.extensions.pop-shell activate-launcher "<Super>Space"
gsettings set org.gnome.shell.extensions.pop-shell cycle-tiling "<Super>Enter"

# Final confirmation before reboot
read -p "Installation complete! Press Enter to reboot your system."  
reboot
