#!/usr/bin/env bash
set -euo pipefail

app="SLAADE"
action="${1:-}"

notify_missing() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send \
      -a "$app" \
      -u normal \
      -h string:x-dunst-stack-tag:slaade-brightness \
      "Brightness unavailable" \
      "brightnessctl is not installed or no backlight device is available."
  fi
}

if ! command -v brightnessctl >/dev/null 2>&1; then
  notify_missing
  exit 1
fi

case "$action" in
  up)
    brightnessctl -e4 -n2 set 5%+ >/dev/null
    ;;
  down)
    brightnessctl -e4 -n2 set 5%- >/dev/null
    ;;
  *)
    printf 'usage: %s {up|down}\n' "$0" >&2
    exit 2
    ;;
esac

if ! command -v notify-send >/dev/null 2>&1; then
  exit 0
fi

current="$(brightnessctl get 2>/dev/null || true)"
maximum="$(brightnessctl max 2>/dev/null || true)"

if [[ -z "$current" || -z "$maximum" || "$maximum" -eq 0 ]]; then
  notify_missing
  exit 1
fi

percent=$(( (current * 100 + maximum / 2) / maximum ))

notify-send \
  -a "$app" \
  -u low \
  -h string:x-dunst-stack-tag:slaade-brightness \
  -h int:value:"$percent" \
  "Brightness" "${percent}%"
