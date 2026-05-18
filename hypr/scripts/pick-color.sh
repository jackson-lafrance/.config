#!/usr/bin/env bash
set -euo pipefail

app="SLAADE"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send \
      -a "$app" \
      -u low \
      -h string:x-dunst-stack-tag:slaade-color-picker \
      "$1" "$2"
  fi
}

if ! command -v hyprpicker >/dev/null 2>&1; then
  notify "Color picker unavailable" "hyprpicker is not installed."
  exit 1
fi

color="$(hyprpicker -a 2>/dev/null || true)"

if [[ -z "$color" ]]; then
  notify "Color picker cancelled" "No color was copied."
  exit 1
fi

notify "Color copied" "$color"
