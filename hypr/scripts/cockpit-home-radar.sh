#!/usr/bin/env bash
set -euo pipefail

main_dir="${HOME}"
cd "$main_dir"

text='\033[38;2;224;222;244m'
muted='\033[38;2;110;106;134m'
rose='\033[38;2;235;188;186m'
pine='\033[38;2;49;116;143m'
foam='\033[38;2;156;207;216m'
iris='\033[38;2;196;167;231m'
gold='\033[38;2;246;193;119m'
reset='\033[0m'

watch_roots=()
for dir in Projects Work Personal School slaade .config; do
  if [[ -d "$HOME/$dir" ]]; then
    watch_roots+=("$HOME/$dir")
  fi
done

while true; do
  clear

  printf "${iris}╭─${rose} HOME RADAR ${iris}──────────────────────────────╮${reset}\n"
  printf "${iris}│${reset} ${text}/home/jacksonlafrance live workspace overview${reset} ${iris}│${reset}\n"
  printf "${iris}╰──────────────────────────────────────────────╯${reset}\n\n"

  printf "${gold}time${reset} ${muted}→${reset} ${text}%s${reset}\n" "$(date '+%A, %B %d  %H:%M:%S')"
  printf "${foam}home${reset} ${muted}→${reset} ${text}%s${reset}\n\n" "$PWD"

  printf "${rose}top-level dirs${reset}\n"
  find "$HOME" -mindepth 1 -maxdepth 1 -type d \
    ! -name '.*' \
    -printf "  ${muted}󰉋${reset} ${text}%f${reset}\n" 2>/dev/null \
    | sort \
    | head -10
  printf "\n"

  printf "${pine}workspace git changes${reset}\n"
  repo_count=0
  if [[ "${#watch_roots[@]}" -gt 0 ]]; then
    while IFS= read -r git_dir; do
      repo="${git_dir%/.git}"
      status="$(git -C "$repo" status --short 2>/dev/null | head -5 || true)"
      if [[ -n "$status" ]]; then
        repo_count=$((repo_count + 1))
        printf "  ${gold}󰊢${reset} ${text}%s${reset}\n" "${repo#$HOME/}"
        printf "%s\n" "$status" | sed "s/^/    /"
      fi
    done < <(find "${watch_roots[@]}" -mindepth 1 -maxdepth 4 -type d -name .git 2>/dev/null | sort | head -20)
  fi

  if [[ "$repo_count" -eq 0 ]]; then
    printf "  ${muted}all scanned workspace repos clean${reset}\n"
  fi
  printf "\n"

  printf "${foam}quick commands${reset}\n"
  printf "  ${text}nvim .${reset}       ${muted}open home in editor${reset}\n"
  printf "  ${text}cd ~/.config${reset}  ${muted}rice configs${reset}\n"
  printf "  ${text}git status${reset}    ${muted}check current repo${reset}\n\n"

  printf "${muted}refreshes every 10s · Ctrl+C closes this pane${reset}\n"
  sleep 10
done
