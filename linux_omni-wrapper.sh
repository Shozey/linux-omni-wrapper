#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
BASE_DIR="$SCRIPT_DIR"
CURRENT_DIR="$BASE_DIR"

BOLD=$(tput bold)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
CYAN=$(tput setaf 6)
YELLOW=$(tput setaf 3)
MAGENTA=$(tput setaf 5)
RESET=$(tput sgr0)
REV=$(tput rev)

tput civis
trap "tput cnorm; echo -e '\n${RED}Aborted.${RESET}'; exit 0" SIGINT SIGTERM

display_header() {
    clear
    echo -e "${BOLD}${CYAN}================================================${RESET}"
    echo -e "${BOLD}  OMNI-WRAPPER // MAIN MENU                     ${RESET}"
    echo -e "${BOLD}${CYAN}================================================${RESET}"
    local rel_path="${CURRENT_DIR#$BASE_DIR}"
    if [[ -z "$rel_path" ]]; then
        echo -e "${YELLOW}  [Pfad: /]${RESET}\n"
    else
        echo -e "${YELLOW}  [Pfad: $rel_path]${RESET}\n"
    fi
}

scan_directory() {
    ITEM_NAMES=()
    ITEM_PATHS=()
    ITEM_TYPES=()

    shopt -s nullglob

    for d in "$CURRENT_DIR"/*/; do
        if [[ -d "$d" ]]; then
            local basename="${d%/}"
            basename="${basename##*/}"
            ITEM_NAMES+=("$basename")
            ITEM_PATHS+=("$d")
            ITEM_TYPES+=("dir")
        fi
    done

    for f in "$CURRENT_DIR"/*.sh; do
        if [[ -f "$f" ]]; then
            local basename="${f##*/}"
            if [[ "$f" != "$SCRIPT_DIR/$(basename "$0")" ]]; then
                ITEM_NAMES+=("$basename")
                ITEM_PATHS+=("$f")
                ITEM_TYPES+=("script")
            fi
        fi
    done

    shopt -u nullglob

    if [[ "$CURRENT_DIR" != "$BASE_DIR" ]]; then
        ITEM_NAMES+=(".. (Back)")
        ITEM_PATHS+=("back")
        ITEM_TYPES+=("nav")
    else
        ITEM_NAMES+=("Exit")
        ITEM_PATHS+=("exit")
        ITEM_TYPES+=("nav")
    fi
}

draw_menu() {
    display_header

    for i in "${!ITEM_NAMES[@]}"; do
        local prefix="  "
        local suffix="${RESET}"
        local name="${ITEM_NAMES[$i]}"
        local type="${ITEM_TYPES[$i]}"

        if [[ "$type" == "dir" ]]; then
            name="[📁] $name"
            color="${CYAN}"
        elif [[ "$type" == "script" ]]; then
            local display_name="${name%.sh}"
            name="[▶] $display_name"
            color="${GREEN}"
        else
            name="[↵] $name"
            color="${RED}"
        fi

        if [[ $i -eq $selected_index ]]; then
            prefix="${BOLD}${REV} >"
        else
            prefix="  "
        fi

        echo -e "${color}${prefix} ${name} ${suffix}"
    done

    echo -e "\n${CYAN}------------------------------------------------${RESET}"
    echo -e " ${BOLD}↑/↓${RESET} Move | ${BOLD}Enter/Space${RESET} Select | ${BOLD}Backspace${RESET} Back"
}

selected_index=0

while true; do
    scan_directory

    if [[ $selected_index -ge ${#ITEM_NAMES[@]} ]]; then
        selected_index=$((${#ITEM_NAMES[@]} - 1))
    fi
    if [[ $selected_index -lt 0 ]]; then
        selected_index=0
    fi

    draw_menu

    read -rsn1 key

    case "$key" in
        $'\e')
            read -rsn2 key2
            case "$key2" in
                "[A")
                    ((selected_index--))
                    if [[ $selected_index -lt 0 ]]; then selected_index=$((${#ITEM_NAMES[@]} - 1)); fi
                    ;;
                "[B")
                    ((selected_index++))
                    if [[ $selected_index -ge ${#ITEM_NAMES[@]} ]]; then selected_index=0; fi
                    ;;
            esac
            ;;
        "" | " ")
            type="${ITEM_TYPES[$selected_index]}"
            path="${ITEM_PATHS[$selected_index]}"

            if [[ "$type" == "dir" ]]; then
                CURRENT_DIR="$path"
                selected_index=0
            elif [[ "$type" == "script" ]]; then
                tput cnorm
                clear
                echo -e "${YELLOW}[*] Starting $path...${RESET}\n"

                bash "$path"

                echo -e "\n${YELLOW}[*] Module stopped. Press Any key to return..${RESET}"
                read -rsn1
                tput civis
            elif [[ "$type" == "nav" ]]; then
                if [[ "$path" == "back" ]]; then
                    CURRENT_DIR="$(dirname "$CURRENT_DIR")"
                    selected_index=0
                elif [[ "$path" == "exit" ]]; then
                    break
                fi
            fi
            ;;
        $'\x7f' | $'\b')
            if [[ "$CURRENT_DIR" != "$BASE_DIR" ]]; then
                CURRENT_DIR="$(dirname "$CURRENT_DIR")"
                selected_index=0
            fi
            ;;
    esac
done

tput cnorm
clear
