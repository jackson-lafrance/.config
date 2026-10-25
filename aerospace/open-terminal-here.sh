#!/usr/bin/env bash

set -u

read -r bundle_id app_pid <<< "$(
  aerospace list-windows --focused --format '%{app-bundle-id} %{app-pid}'
)"

if [[ "$bundle_id" != "org.alacritty" || -z "$app_pid" ]]; then
  exit 0
fi

terminal_pid="$(pgrep -P "$app_pid" | head -n 1)"
if [[ -z "$terminal_pid" ]]; then
  exit 0
fi

foreground_pgid="$(ps -o tpgid= -p "$terminal_pid" | tr -d '[:space:]')"
if [[ -z "$foreground_pgid" || "$foreground_pgid" == "-1" ]]; then
  exit 0
fi

foreground_pid="$(
  ps -axo pid=,pgid= |
    awk -v pgid="$foreground_pgid" '$2 == pgid { print $1; exit }'
)"
if [[ -z "$foreground_pid" ]]; then
  exit 0
fi

working_directory="$(
  lsof -a -p "$foreground_pid" -d cwd -Fn 2>/dev/null |
    sed -n 's/^n//p' |
    head -n 1
)"

if [[ ! -d "$working_directory" ]]; then
  working_directory="$HOME"
fi

open -na "Alacritty" --args --working-directory "$working_directory"
