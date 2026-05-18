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

printf "${rose}╭─${iris} DEV TERMINAL ${rose}────────────────────────────╮${reset}\n"
printf "${rose}│${reset} ${text}ready in /home/jacksonlafrance${reset}                  ${rose}│${reset}\n"
printf "${rose}╰──────────────────────────────────────────────╯${reset}\n\n"

printf "${gold}cwd${reset}       ${muted}→${reset} ${text}%s${reset}\n" "$PWD"
printf "${pine}shell${reset}     ${muted}→${reset} ${text}%s${reset}\n" "$shell"
printf "${foam}editor${reset}    ${muted}→${reset} ${text}nvim + Oil opens on the right${reset}\n\n"

printf "${iris}home shortcuts${reset}\n"
for dir in Projects Work Personal School obsidian .config Downloads; do
  if [[ -d "$HOME/$dir" ]]; then
    printf "  ${muted}󰉋${reset} ${text}%-12s${reset} ${muted}%s${reset}\n" "$dir" "cd ~/$dir"
  fi
done
printf "\n"

printf "${rose}recent workspace files${reset}\n"
search_roots=()
for dir in Projects Work Personal School obsidian Downloads; do
  if [[ -d "$HOME/$dir" ]]; then
    search_roots+=("$HOME/$dir")
  fi
done

if [[ "${#search_roots[@]}" -gt 0 ]]; then
  find "${search_roots[@]}" -maxdepth 3 -type f \
    ! -name '.*' \
    ! -name '*.tmp' \
    ! -path '*/.git/*' \
    ! -path '*/.obsidian/*' \
    ! -path '*/.stfolder/*' \
    -printf '%T@ %p\n' 2>/dev/null \
    | sort -nr \
    | head -8 \
    | cut -d' ' -f2- \
    | sed "s#^$HOME/#  #"
else
  printf "  ${muted}no workspace folders found${reset}\n"
fi
printf "\n"

printf "${gold}git hint${reset} ${muted}→${reset} ${text}right pane watches dirty repos; this pane is your prompt.${reset}\n\n"

exec "$shell" -l
