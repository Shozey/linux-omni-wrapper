#!/bin/bash

BOLD=$(tput bold)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

echo -e "${BOLD}${CYAN}================================================${RESET}"
echo -e "${BOLD}  SYSTEM INFO (btop)                       ${RESET}"
echo -e "${BOLD}${CYAN}================================================${RESET}\n"

if ! command -v btop &> /dev/null; then
    echo -e "${RED}[!] btop is not installed on this system.${RESET}"

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID="${ID,,}"
        OS_LIKE="${ID_LIKE,,}"
    else
        OS_ID="unknown"
    fi

    echo -e "    ${YELLOW}How to install it on your system:${RESET}"

    if grep -qi "bazzite" /etc/os-release 2>/dev/null; then
        echo -e "    Install btop using 'rpm-ostree install btop' via terminal and reboot\n"

    elif [[ "$OS_ID" == "manjaro" ]]; then
        echo -e "    Use: ${BOLD}sudo pacman -S btop${RESET} OR (experimental) ${BOLD}pamac install btop${RESET}\n"

    elif [[ "$OS_ID" == "arch" || "$OS_LIKE" == *"arch"* ]]; then
        echo -e "    Use: ${BOLD}sudo pacman -S btop${RESET} OR (experimental) ${BOLD}pamac install btop${RESET}\n"

    elif [[ "$OS_ID" == *"ubuntu"* || "$OS_ID" == *"debian"* || "$OS_ID" == "linuxmint" || "$OS_LIKE" == *"debian"* || "$OS_LIKE" == *"ubuntu"* ]]; then
        echo -e "    Use: ${BOLD}sudo apt install btop${RESET}\n"

    elif [[ "$OS_ID" == "fedora" || "$OS_LIKE" == *"fedora"* ]]; then
        echo -e "    Install btop using 'rpm-ostree install btop' via terminal and reboot\n"

    elif [[ "$OS_ID" == *"opensuse"* || "$OS_LIKE" == *"suse"* ]]; then
        echo -e "    Use: ${BOLD}sudo zypper install btop${RESET}\n"

    else
        echo -e "    Please install it using your system's package manager.\n"
    fi

    exit 1
fi

echo -e "${YELLOW}[*] Launching btop...${RESET}"
sleep 1

btop


clear

echo -e "${GREEN} btop closed.${RESET}\n"
