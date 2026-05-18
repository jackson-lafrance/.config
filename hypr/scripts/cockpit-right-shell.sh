#!/usr/bin/env bash
set -euo pipefail

shell="${SHELL:-/bin/bash}"
main_dir="${COCKPIT_MAIN_DIR:-$HOME}"

if [[ ! -d "$main_dir" ]]; then
  main_dir="$HOME"
fi

cd "$main_dir"
clear

text='\033[38;2;224;222;244m'
muted='\033[38;2;110;106;134m'
rose='\033[38;2;235;188;186m'
pine='\033[38;2;49;116;143m'
foam='\033[38;2;156;207;216m'
iris='\033[38;2;196;167;231m'
gold='\033[38;2;246;193;119m'
reset='\033[0m'

printf "${pine}╭─${rose} JARVIS AUX SHELL ${pine}────────────────────────╮${reset}\n"
printf "${pine}│${reset} ${text}right monitor command console${reset}                    ${pine}│${reset}\n"
printf "${pine}╰──────────────────────────────────────────────╯${reset}\n\n"

printf "${gold}time${reset}      ${muted}→${reset} ${text}%s${reset}\n" "$(date '+%a %b %d  %H:%M')"
printf "${foam}uptime${reset}    ${muted}→${reset} ${text}%s${reset}\n" "$(uptime -p 2>/dev/null | sed 's/^up //')"
printf "${iris}kernel${reset}    ${muted}→${reset} ${text}%s${reset}\n" "$(uname -r)"
printf "${rose}cwd${reset}       ${muted}→${reset} ${text}%s${reset}\n\n" "$PWD"

if command -v free >/dev/null 2>&1; then
  read -r mem_used mem_total < <(free -h | awk 'NR==2 {print $3, $2}')
  printf "${pine}memory${reset}    ${muted}→${reset} ${text}%s used / %s total${reset}\n" "$mem_used" "$mem_total"
fi

if command -v df >/dev/null 2>&1; then
  read -r disk_used disk_total disk_mount < <(df -h "$PWD" | awk 'NR==2 {print $3, $2, $6}')
  printf "${foam}disk${reset}      ${muted}→${reset} ${text}%s used / %s total at %s${reset}\n" "$disk_used" "$disk_total" "$disk_mount"
fi

printf "\n${muted}quick paths:${reset}\n"
printf "  ${text}cd ~/Projects${reset}\n"
printf "  ${text}cd ~/.config${reset}\n"
printf "  ${text}nvim .${reset}\n\n"

exec "$shell" -l
