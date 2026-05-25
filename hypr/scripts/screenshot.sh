#!/usr/bin/env bash
set -euo pipefail

app="SLAADE"
mode="${1:-area}"

notify() {
  local urgency="${3:-low}"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send \
      -a "$app" \
      -u "$urgency" \
      -h string:x-dunst-stack-tag:slaade-screenshot \
      "$1" "$2"
  fi
}

need() {
  if ! command -v "$1" >/dev/null 2>&1; then
    notify "Screenshot unavailable" "$1 is not installed." normal
    exit 1
  fi
}

need grim
need wl-copy

pictures_dir="$HOME/Pictures"
if command -v xdg-user-dir >/dev/null 2>&1; then
  pictures_dir="$(xdg-user-dir PICTURES 2>/dev/null || printf '%s/Pictures' "$HOME")"
fi

screenshot_dir="${XDG_SCREENSHOTS_DIR:-$pictures_dir/Screenshots}"
mkdir -p "$screenshot_dir"

file="$screenshot_dir/Screenshot_$(date '+%Y-%m-%d_%H-%M-%S').png"

grim_args=()
case "$mode" in
  area)
    need slurp
    geometry="$(slurp 2>/dev/null || true)"
    if [[ -z "$geometry" ]]; then
      notify "Screenshot cancelled" "No region was selected."
      exit 1
    fi
    grim_args=(-g "$geometry")
    ;;
  full)
    ;;
  *)
    printf 'usage: %s {area|full}\n' "$0" >&2
    exit 2
    ;;
esac

grim "${grim_args[@]}" "$file"
wl-copy --type image/png < "$file"

notify "Screenshot saved" "Copied to clipboard: ${file/#$HOME/~}"
