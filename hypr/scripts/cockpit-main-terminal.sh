#!/usr/bin/env bash
set -euo pipefail

shell="${SHELL:-/bin/bash}"
main_dir="${COCKPIT_MAIN_DIR:-$HOME}"

if [[ ! -d "$main_dir" ]]; then
  main_dir="$HOME"
fi

cd "$main_dir"
clear

base='\033[38;2;25;23;36m'
surface='\033[38;2;31;29;46m'
text='\033[38;2;224;222;244m'
muted='\033[38;2;110;106;134m'
rose='\033[38;2;235;188;186m'
pine='\033[38;2;49;116;143m'
foam='\033[38;2;156;207;216m'
iris='\033[38;2;196;167;231m'
gold='\033[38;2;246;193;119m'
reset='\033[0m'

printf "${rose}╭────────────────────────────────────────────╮${reset}\n"
printf "${rose}│${reset} ${iris}JARVIS DEV CORE${reset} ${muted}//${reset} ${foam}Rosé Pine online${reset}      ${rose}│${reset}\n"
printf "${rose}╰────────────────────────────────────────────╯${reset}\n\n"

if command -v fastfetch >/dev/null 2>&1; then
  fastfetch
  printf "\n"
fi

printf "${gold}workspace${reset} ${muted}→${reset} ${text}%s${reset}\n" "$PWD"
printf "${pine}shell${reset}     ${muted}→${reset} ${text}%s${reset}\n" "$shell"
printf "${foam}status${reset}    ${muted}→${reset} ${text}ready for build, debug, commit, ship${reset}\n\n"

if find . -mindepth 1 -maxdepth 1 -type d -print -quit 2>/dev/null | grep -q .; then
  printf "${iris}project index${reset}\n"
  find . -mindepth 1 -maxdepth 1 -type d -printf "  ${muted}󰉋${reset} ${text}%f${reset}\n" 2>/dev/null | sort | head -8
  printf "\n"
fi

printf "${muted}tip:${reset} ${text}nvim opens Oil on the right workspace; SUPER+B still opens browser manually.${reset}\n\n"

exec "$shell" -l
