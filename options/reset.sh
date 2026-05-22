#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$ROOT_DIR/backup"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
REPO_URL="https://github.com/Shozey/linux-omni-wrapper.git"

BOLD=$(tput bold)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
RESET=$(tput sgr0)

echo -e "${BOLD}${CYAN}================================================${RESET}"
echo -e "${BOLD}  RESET // OMNI-WRAPPER                 ${RESET}"
echo -e "${BOLD}${CYAN}================================================${RESET}\n"

echo -e "${RED}[!] WARNING: This will delete all custom files and reset to defaults.${RESET}"
read -p "    Are you sure you want to continue? [y/N]: " confirm

if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}[○] Reset aborted.${RESET}"
    exit 0
fi

echo -e "\n${YELLOW}[*] Creating final backup of current state...${RESET}"
mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/full_backup_$TIMESTAMP.tar.gz" -C "$ROOT_DIR" . --exclude=backup 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}[✓] Backup saved to: backup/full_backup_$TIMESTAMP.tar.gz${RESET}"
else
    echo -e "${RED}[!] Backup failed! Reset aborted for safety.${RESET}"
    exit 1
fi

echo -e "${YELLOW}[*] Cleaning up directory...${RESET}"
find "$ROOT_DIR" -maxdepth 1 ! -name 'backup' ! -name '.' -exec rm -rf {} +

echo -e "${YELLOW}[*] Cloning fresh repository...${RESET}"
if command -v git &> /dev/null; then
    git clone "$REPO_URL" "$ROOT_DIR"
else
    echo -e "${RED}[!] Error: git is not installed. Cannot perform reset.${RESET}"
    exit 1
fi

echo -e "\n${GREEN}[✓] Reset complete.${RESET}"
echo -e "${YELLOW}[*] Use CTRL + C to restart.${RESET}"
exit 0
