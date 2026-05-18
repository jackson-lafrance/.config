#!/usr/bin/env bash
set -euo pipefail

terminal="${TERMINAL:-alacritty}"
browser="${BROWSER:-zen-browser}"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "JARVIS" "$1"
  fi
}

run_if_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Hyprland starts this script at login. If hyprlock is active, wait until you
# unlock so the cockpit sequence is visible instead of happening behind the lock.
while pgrep -x hyprlock >/dev/null 2>&1; do
  sleep 0.25
done

sleep 0.7
notify "Initializing Rosé Pine development cockpit..."

# Put the dashboard workspace on-screen first, then reveal each piece in order.
hyprctl dispatch workspace name:jarvis >/dev/null 2>&1 || true

sleep 0.6

if run_if_exists fastfetch; then
  hyprctl dispatch exec "[workspace name:jarvis silent] $terminal --class fastfetch-cockpit -e bash -lc 'fastfetch; echo; echo \"system ready.\"; sleep 12'"
fi

sleep 0.5

if run_if_exists btop; then
  hyprctl dispatch exec "[workspace name:jarvis silent] $terminal --class btop-cockpit -e btop"
fi

sleep 0.6
hyprctl dispatch exec "[workspace name:term silent] $terminal"

sleep 0.8
hyprctl dispatch exec "[workspace name:search silent] $browser"

sleep 1.2
notify "Cockpit online."

# Land on the main development terminal after the reveal finishes.
hyprctl dispatch workspace name:term >/dev/null 2>&1 || true
