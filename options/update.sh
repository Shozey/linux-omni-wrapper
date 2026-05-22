#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backup"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

BOLD=$(tput bold)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

echo -e "${BOLD}${CYAN}================================================${RESET}"
echo -e "${BOLD}  OMNI-WRAPPER // Update                 ${RESET}"
echo -e "${BOLD}${CYAN}================================================${RESET}\n"

echo -e "${YELLOW}[*] Backing up current version to 'backup/'...${RESET}"
mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/backup_$TIMESTAMP.tar.gz" -C "$SCRIPT_DIR" . --exclude=backup 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[✓] Backup successful: backup_$TIMESTAMP.tar.gz${RESET}"
else
    echo -e "${RED}[!] Backup failed! Aborting update to prevent data loss.${RESET}"
    exit 1
fi

echo -e "\n${YELLOW}[*] Starting download from repository...${RESET}"

TMP_UPDATE_DIR="/tmp/omni_update_$RANDOM"
mkdir -p "$TMP_UPDATE_DIR"

if command -v git &> /dev/null; then
    echo -e "${CYAN}Using GIT for update...${RESET}"
    git clone --depth 1 https://github.com/Shozey/linux-omni-wrapper.git "$TMP_UPDATE_DIR"
else
    echo -e "${CYAN}Git not found, using WGET...${RESET}"
    if command -v wget &> /dev/null; then
        wget -qO- https://github.com/Shozey/linux-omni-wrapper.git | tar -xz -C "$TMP_UPDATE_DIR" --strip-components=1
    else
        echo -e "${RED}[!] Error: Neither git nor wget found. Cannot download update.${RESET}"
        rm -rf "$TMP_UPDATE_DIR"
        exit 1
    fi
fi

if [ -d "$TMP_UPDATE_DIR" ]; then
    echo -e "${YELLOW}[*] Replacing files...${RESET}"
    rsync -av --exclude='backup' --exclude='settings.cfg' --exclude='.git' "$TMP_UPDATE_DIR/" "$SCRIPT_DIR/" > /dev/null
    
    echo -e "${GREEN}[✓] Update completed successfully!${RESET}"
    rm -rf "$TMP_UPDATE_DIR"
else
    echo -e "${RED}[!] Update download failed.${RESET}"
    exit 1
fi
