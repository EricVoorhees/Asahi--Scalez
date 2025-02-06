#!/bin/bash

# Define colors for output messages
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'  # No Color

# Function to check for internet connection
check_internet() {
    echo -n "Checking for internet connection..."
    if ping -q -c 1 -W 1 google.com >/dev/null; then
        echo -e "${GREEN}Internet connection is active.${NC}"
    else
        echo -e "${RED}No internet connection. Exiting.${NC}"
        exit 1
    fi
}

# Function to install required dependencies
install_dependencies() {
    echo -e "${YELLOW}Installing required dependencies...${NC}"
    sudo apt update
    sudo apt install -y gnome-shell-extensions \
        gnome-tweaks \
        dconf-cli \
        gnome-shell \
        adwaita-icon-theme-full \
        gnome-shell-extension-dash-to-dock \
        gnome-shell-extension-pop-shell
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Dependencies installed successfully.${NC}"
    else
        echo -e "${RED}Failed to install dependencies. Exiting.${NC}"
        exit 1
    fi
}

# Function to install Pp Shell Extensions
install_extensions() {
    echo -e "${YELLOW}Installing Pp Shell extensions...${NC}"
    gnome-extensions enable pp-shell@system76.com
    gnome-extensions enable dash-to-dock@micxgx.gmail.com
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Pp Shell extensions installed successfully.${NC}"
    else
        echo -e "${RED}Failed to install extensions. Exiting.${NC}"
        exit 1
    fi
}

# Function to configure GNOME settings
configure_gnome_settings() {
    echo -e "${YELLOW}Configuring GNOME settings...${NC}"
    dconf load / < configs/gnome-settings.conf
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}GNOME settings configured successfully.${NC}"
    else
        echo -e "${RED}Failed to configure GNOME settings. Exiting.${NC}"
        exit 1
    fi
}

# Function to configure keybindings
configure_keybindings() {
    echo -e "${YELLOW}Configuring keybindings...${NC}"
    dconf load / < configs/pp-shell-shortcuts.conf
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Keybindings configured successfully.${NC}"
    else
        echo -e "${RED}Failed to configure keybindings. Exiting.${NC}"
        exit 1
    fi
}

# Prompt to install the project
echo -e "${YELLOW}This will install and configure the Asahi-Scalez project. Do you want to continue? (y/n)${NC}"
read -r install_confirmation
if [[ ! "$install_confirmation" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Installation aborted.${NC}"
    exit 1
fi

# Check internet connection
check_internet

# Prompt for enabling features
echo -e "${YELLOW}Do you want to enable all features (including Pop Shell)? (y/n)${NC}"
read -r enable_features_confirmation
if [[ ! "$enable_features_confirmation" =~ ^[Yy]$ ]]; then
    echo -e "${RED}Features will not be enabled. Exiting.${NC}"
    exit 1
fi

# Install dependencies
install_dependencies

# Install extensions
install_extensions

# Configure GNOME settings
configure_gnome_settings

# Configure keybindings
configure_keybindings

# Prompt to reboot the system
echo -e "${YELLOW}Installation is complete. Press Enter to reboot the system.${NC}"
read -r reboot_confirmation
if [[ "$reboot_confirmation" =~ ^[Yy]$ || -z "$reboot_confirmation" ]]; then
    sudo reboot
else
    echo -e "${RED}Reboot aborted. Please reboot manually to apply the changes.${NC}"
    exit 1
fi

