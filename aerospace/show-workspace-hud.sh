#!/usr/bin/env bash

set -euo pipefail

workspace="${1:-}"
if [[ -z "$workspace" ]]; then
  exit 0
fi

script_directory="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_file="$script_directory/workspace-hud.swift"
cache_directory="${XDG_CACHE_HOME:-$HOME/.cache}/aerospace"
binary="$cache_directory/workspace-hud"

mkdir -p "$cache_directory"

if [[ ! -x "$binary" || "$source_file" -nt "$binary" ]]; then
  temporary_binary="$binary.$$"
  trap 'rm -f "$temporary_binary"' EXIT
  /usr/bin/xcrun swiftc -O -framework AppKit "$source_file" -o "$temporary_binary"
  /bin/mv -f "$temporary_binary" "$binary"
  trap - EXIT
fi

pid_file="${TMPDIR:-/tmp}/aerospace-workspace-hud-${UID}.pid"
if [[ -r "$pid_file" ]]; then
  previous_pid="$(<"$pid_file")"
  if [[ "$previous_pid" =~ ^[0-9]+$ ]] && /bin/kill -0 "$previous_pid" 2>/dev/null; then
    previous_command="$(/bin/ps -p "$previous_pid" -o command= 2>/dev/null || true)"
    if [[ "$previous_command" == "$binary"* ]]; then
      /bin/kill "$previous_pid" 2>/dev/null || true
    fi
  fi
fi

appkit_screen_id=""
if aerospace_binary="$(command -v aerospace 2>/dev/null)"; then
  appkit_screen_id="$($aerospace_binary list-monitors --focused \
    --format '%{monitor-appkit-nsscreen-screens-id}' 2>/dev/null || true)"
fi

printf '%s\n' "$$" > "$pid_file"
exec "$binary" "$workspace" "$appkit_screen_id"
