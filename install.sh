#!/bin/bash

# Define colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'  # No Color

# Check internet connection
check_internet_connection() {
    echo -e "${YELLOW}Checking internet connection...${NC}"
    if ! ping -c 1 google.com &>/dev/null; then
        echo -e "${RED}No internet connection detected. Exiting.${NC}"
        exit 1
    else
        echo -e "${GREEN}Internet connection detected.${NC}"
    fi
}

# Ask if user wants to install Asahi-Scalez
confirm_installation() {
    read -p "Do you want to install Asahi-Scalez? (y/n): " install_choice
    if [[ "$install_choice" != "y" ]]; then
        echo -e "${RED}Installation aborted.${NC}"
        exit 1
    else
        echo -e "${GREEN}Proceeding with installation...${NC}"
    fi
}

# Install Auto Tiling extension for GNOME
install_tiling_extensions() {
    echo -e "${YELLOW}Installing Auto Tiling extension...${NC}"
    gnome-extensions install auto-tiling@github.com
    gnome-extensions enable auto-tiling@github.com
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Auto Tiling extension installed and enabled.${NC}"
    else
        echo -e "${RED}Failed to install Auto Tiling extension. Exiting.${NC}"
        exit 1
    fi
}

# Install Pop Shell extensions and dependencies
install_pop_shell() {
    echo -e "${YELLOW}Installing Pop Shell...${NC}"
    sudo apt install -y gnome-shell-extension-pop-shell
    gnome-extensions enable pop-shell@system76.com
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Pop Shell installed and enabled.${NC}"
    else
        echo -e "${RED}Failed to install Pop Shell extension. Exiting.${NC}"
        exit 1
    fi
}

# Setup GNOME settings (including keybindings and workspace behavior)
configure_gnome_settings() {
    echo -e "${YELLOW}Configuring GNOME settings...${NC}"

    # Enable smooth tiling and set theme and workspace options
    gnome-extensions enable auto-tiling@github.com
    gnome-shell-extension-tool -e 'pop-shell@system76.com'

    # Set smooth window dragging (snap-to-edge) and workspace creation
    gsettings set org.gnome.desktop.wm.preferences theme 'Adwaita-dark'
    gsettings set org.gnome.desktop.wm.preferences action-middle-click-titlebar 'minimize'
    gsettings set org.gnome.desktop.wm.preferences snapping-enabled true
    gsettings set org.gnome.desktop.wm.preferences workspace-creation true

    echo -e "${GREEN}GNOME settings configured.${NC}"
}

# Configure keybindings for window tiling and snapping (PopOS-like)
configure_keybindings() {
    echo -e "${YELLOW}Configuring keybindings for window tiling...${NC}"

    # PopOS-like keybindings for tiling and window navigation
    gsettings set org.gnome.desktop.wm.keybindings tile-left "['<Super>Left']"
    gsettings set org.gnome.desktop.wm.keybindings tile-right "['<Super>Right']"
    gsettings set org.gnome.desktop.wm.keybindings tile-up "['<Super>Up']"
    gsettings set org.gnome.desktop.wm.keybindings tile-down "['<Super>Down']"
    gsettings set org.gnome.desktop.wm.keybindings toggle-tiling "['<Super>y']"

    # Add keybindings for additional functionality (like window focus and workspace switching)
    gsettings set org.gnome.desktop.wm.keybindings switch-to-next-window "['<Super>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-to-previous-window "['<Super><Shift>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings focus-previous "['<Super>Shift>Left']"
    gsettings set org.gnome.desktop.wm.keybindings focus-next "['<Super>Shift>Right']"

    echo -e "${GREEN}Keybindings configured.${NC}"
}

# Main script execution
main() {
    check_internet_connection
    confirm_installation
    install_tiling_extensions
    install_pop_shell
    configure_gnome_settings
    configure_keybindings

    echo -e "${GREEN}All components installed and configured. Press Enter to reboot...${NC}"
    read
    echo -e "${YELLOW}Rebooting system now...${NC}"
    sudo reboot
}

# Run the main function
main

