#!/usr/bin/env bash
set -euo pipefail

terminal="${TERMINAL:-alacritty}"
main_dir="${COCKPIT_MAIN_DIR:-$HOME}"

if [[ ! -d "$main_dir" ]]; then
  main_dir="$HOME"
fi

export COCKPIT_MAIN_DIR="$main_dir"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "JARVIS" -u low -h string:x-dunst-stack-tag:jarvis-cockpit "JARVIS" "$1"
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
hyprctl dispatch exec "[workspace name:term silent] $terminal --class main-cockpit -e $HOME/.config/hypr/scripts/cockpit-main-terminal.sh"

sleep 0.6

if run_if_exists nvim; then
  hyprctl dispatch exec "[workspace name:search silent] $terminal --class nvim-cockpit -e $HOME/.config/hypr/scripts/cockpit-oil.sh"
fi

sleep 0.5
hyprctl dispatch exec "[workspace name:search silent] $terminal --class right-shell-cockpit -e $HOME/.config/hypr/scripts/cockpit-right-shell.sh"

sleep 1.2
notify "Cockpit online."

# Land on the main development terminal after the reveal finishes.
hyprctl dispatch workspace name:term >/dev/null 2>&1 || true
