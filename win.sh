#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Define color variables
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
NC='\e[0m' # No Color

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}This script must be run as root. Use 'sudo' to execute it.${NC}"
    exit 1
fi

# Function to prompt for OS selection
select_os() {
    while true; do
        echo -e "${BLUE}Select OS version:${NC}"
        echo -e "${YELLOW}1) Windows 10 GS DigitalOcean${NC}"
        echo -e "${YELLOW}2) Windows 2016${NC}"
        echo -e "${YELLOW}3) Windows 2012${NC}"
        read -p "Enter choice : " os_choice
        if [[ "$os_choice" =~ ^[1-3]$ ]]; then
            break
        else
            echo -e "${RED}Invalid selection. Please enter 1 or 2.${NC}"
        fi
    done

    if [ "$os_choice" == "1" ]; then
        img_url='http://64.23.255.180/win10.gz'
    elif [ "$os_choice" == "2" ]; then
        img_url='http://139.162.52.181:112/win2016.gz'
    elif [ "$os_choice" == "3" ]; then
        img_url='http://64.23.255.180/win2012.gz'
    fi
}

# Function to prompt for password
prompt_password() {
    default_password="Lolipop123#a"
    while true; do
        echo -e "${GREEN}Enter RDP password (press enter for default: ${default_password}):${NC}"
        read -p "" user_password
        password=${user_password:-$default_password}
        break
        
        # Password strength check
#         if [[ "$password" =~ ^(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9]).{8,}$ ]]; then
#             break
#         else
#             echo -e "${RED}Password must be at least 8 characters long and include uppercase, lowercase, and numbers.${NC}"
#         fi
    done
}

# Download reinstall.sh
download_reinstall_script() {
    echo -e "${BLUE}Downloading reinstall.sh...${NC}"
    if ! curl -# -O https://raw.githubusercontent.com/kripul/reinstall/main/reinstall.sh && ! wget --progress=bar:force -O reinstall.sh https://raw.githubusercontent.com/kripul/reinstall/main/reinstall.sh; then
        echo -e "${RED}Failed to download reinstall.sh. Exiting.${NC}"
        exit 1
    fi
}

# Execute the reinstall script
execute_reinstall_script() {
    echo -e "${GREEN}Executing reinstall script...${NC}"
    bash reinstall.sh dd \
         --rdp-port 112 \
         --password "$password" \
         --img "$img_url"
}

# Confirm reboot
confirm_reboot() {
    read -p "Are you sure you want to reboot now? (y/n): " confirm_reboot
    if [[ "$confirm_reboot" == "y" || "$confirm_reboot" == "Y" ]]; then
        echo -e "${YELLOW}Rebooting in 5 seconds...${NC}"
        sleep 5
        reboot
    else
        echo -e "${GREEN}Reboot canceled. Exiting.${NC}"
        exit 0
    fi
}

# Main script logic
select_os
prompt_password
download_reinstall_script
execute_reinstall_script
confirm_reboot
