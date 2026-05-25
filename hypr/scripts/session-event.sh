#!/usr/bin/env bash
set -euo pipefail

app="SLAADE"
event="${1:-}"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send \
      -a "$app" \
      -u low \
      -h string:x-dunst-stack-tag:slaade-session \
      "$1" "$2"
  fi
}

lock_session() {
  notify "Session locking" "Securing the cockpit."
  pidof hyprlock >/dev/null 2>&1 || hyprlock
}

case "$event" in
  lock)
    lock_session
    ;;
  sleep)
    notify "Displays sleeping" "DPMS is powering the monitors down."
    hyprctl dispatch dpms off
    ;;
  wake)
    hyprctl dispatch dpms on
    notify "Welcome back" "Displays restored."
    ;;
  before-sleep)
    notify "System suspending" "Locking before sleep."
    pidof hyprlock >/dev/null 2>&1 || hyprlock
    ;;
  after-sleep)
    hyprctl dispatch dpms on
    notify "System resumed" "Displays restored after sleep."
    ;;
  *)
    printf 'usage: %s {lock|sleep|wake|before-sleep|after-sleep}\n' "$0" >&2
    exit 2
    ;;
esac
