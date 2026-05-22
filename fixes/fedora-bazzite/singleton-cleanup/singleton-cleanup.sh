#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
CFG_FILE="$SCRIPT_DIR/settings.cfg"

BOLD=$(tput bold); GREEN=$(tput setaf 2); RED=$(tput setaf 1)
CYAN=$(tput setaf 6); YELLOW=$(tput setaf 3); RESET=$(tput sgr0)

delay() {
    if [[ "$FAST_MODE" != "true" ]]; then
        sleep 0.5
    fi
}

display_header() {
    echo -e "${BOLD}${CYAN}================================================${RESET}"
    echo -e "${BOLD}  OMNI-WRAPPER // SINGLETON CLEANER    ${RESET}"
    echo -e "${BOLD}${CYAN}================================================${RESET}"
}

if [[ ! -f "$CFG_FILE" ]]; then
    display_header
    echo -e "${YELLOW}[!] No settings.cfg found. Starting setup...${RESET}"
    echo ""

    read -p "  > Safe Mode (ask before deleting) [Y/n]: " ans_safe
    [[ -z "$ans_safe" || "$ans_safe" =~ ^[Yy] ]] && SAFE_MODE=true || SAFE_MODE=false

    read -p "  > Verbose Mode (show found file paths) [Y/n]: " ans_verb
    [[ -z "$ans_verb" || "$ans_verb" =~ ^[Yy] ]] && VERBOSE_MODE=true || VERBOSE_MODE=false

    read -p "  > Fast Mode (disable artificial delays) [y/N]: " ans_fast
    [[ "$ans_fast" =~ ^[Yy] ]] && FAST_MODE=true || FAST_MODE=false

    echo "SAFE_MODE=$SAFE_MODE" > "$CFG_FILE"
    echo "VERBOSE_MODE=$VERBOSE_MODE" >> "$CFG_FILE"
    echo "FAST_MODE=$FAST_MODE" >> "$CFG_FILE"

    echo -e "\n${GREEN}[✓] Settings saved to: $CFG_FILE${RESET}"
    sleep 1
    clear
fi

source "$CFG_FILE"

display_header
delay

SCAN_PATHS=("$HOME/.var/app" "$HOME/.config")

echo -e "${YELLOW}[*] Starting Full Scan...${RESET}"
echo -e "${CYAN}------------------------------------------------${RESET}"
delay

found_files=()
for dir in "${SCAN_PATHS[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "  [*] Scanning: $dir..."
        delay
        while IFS= read -r line; do
            found_files+=("$line")
        done < <(find "$dir" -name "*Singleton*" 2>/dev/null)
    fi
done

echo ""
delay

if [ ${#found_files[@]} -gt 0 ]; then
    echo -e "${RED}  [!] Found ${#found_files[@]} lock files.${RESET}"
    delay

    if [[ "$VERBOSE_MODE" == "true" ]]; then
        echo -e "${CYAN}  --- Found Files ---${RESET}"
        for f in "${found_files[@]}"; do
            echo -e "      $f"
            if [[ "$FAST_MODE" != "true" ]]; then sleep 0.05; fi
        done
        echo -e "${CYAN}  -------------------${RESET}"
        echo ""
        delay
    fi

    if [[ "$SAFE_MODE" == "true" ]]; then
        read -p "  > Delete them now? (y/N): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            do_delete=true
        else
            do_delete=false
        fi
    else
        echo -e "${YELLOW}  [!] Safe Mode is DISABLED. Deleting files automatically...${RESET}"
        delay
        do_delete=true
    fi

    if [[ "$do_delete" == "true" ]]; then
        for f in "${found_files[@]}"; do
            rm -f "$f"
        done
        echo -e "${GREEN}  [✓] Cleanup successful.${RESET}"
    else
        echo -e "  [○] Cleanup aborted."
    fi
else
    echo -e "${GREEN}  [✓] No blocking singleton files found.${RESET}"
fi

delay
echo -e "${BOLD}${CYAN}================================================${RESET}"
