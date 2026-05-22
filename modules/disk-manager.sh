#!/bin/bash

BOLD=$(tput bold)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

echo -e "${BOLD}${CYAN}================================================${RESET}"
echo -e "${BOLD}  DISK MANAGER (GPARTED)                        ${RESET}"
echo -e "${BOLD}${CYAN}================================================${RESET}\n"

if ! command -v gparted &> /dev/null; then
    echo -e "${RED}[!] GParted is not installed on this system.${RESET}"

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID="${ID,,}"
        OS_LIKE="${ID_LIKE,,}"
    else
        OS_ID="unknown"
    fi

    echo -e "    ${YELLOW}How to install it on your system:${RESET}"
    echo -e ""

    if grep -qi "bazzite" /etc/os-release 2>/dev/null; then
        echo -e "    Install GParted using 'rpm-ostree install gparted' via terminal adn reboot\n"

    elif [[ "$OS_ID" == "manjaro" ]]; then
        echo -e "    Use: ${BOLD}sudo pacman -S gparted${RESET} OR (experimental) ${BOLD}pamac install gparted${RESET}\n"

    elif [[ "$OS_ID" == "arch" || "$OS_LIKE" == *"arch"* ]]; then
        echo -e "    Use: ${BOLD}sudo pacman -S gparted${RESET}\n"

    elif [[ "$OS_ID" == *"ubuntu"* || "$OS_ID" == *"debian"* || "$OS_ID" == "linuxmint" || "$OS_LIKE" == *"debian"* || "$OS_LIKE" == *"ubuntu"* ]]; then
        echo -e "    Use: ${BOLD}sudo apt install gparted${RESET}\n"

    elif [[ "$OS_ID" == "fedora" || "$OS_LIKE" == *"fedora"* ]]; then
        echo -e "    Install GParted using 'rpm-ostree install gparted' via  and reboot\n"

    elif [[ "$OS_ID" == *"opensuse"* || "$OS_LIKE" == *"suse"* ]]; then
        echo -e "    Use: ${BOLD}sudo zypper install gparted${RESET}\n"

    else
        echo -e "    Please install it using your system's package manager.\n"
    fi

    exit 1
fi

echo -e "${YELLOW}[*] Launching GParted...${RESET}"
echo -e "${YELLOW}[!] Note: GParted requires root privileges. You may be asked for your password.${RESET}\n"

sudo gparted > /dev/null 2>&1

echo -e "\n${GREEN} GParted closed.${RESET}\n"
