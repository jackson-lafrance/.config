#!/usr/bin/env bash
set -euo pipefail

app="SLAADE"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send \
      -a "$app" \
      -u normal \
      -h string:x-dunst-stack-tag:slaade-shutdown \
      "$1" "$2"
  fi
}

if command -v hyprshutdown >/dev/null 2>&1; then
  exec hyprshutdown
fi

notify "Shutdown menu unavailable" "hyprshutdown was not found; exiting Hyprland instead."
sleep 0.4
hyprctl dispatch exit
