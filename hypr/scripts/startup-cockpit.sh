#!/usr/bin/env bash
set -euo pipefail

terminal="${TERMINAL:-alacritty}"
browser="${BROWSER:-zen-browser}"

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -a "SLAADE" -u low -h string:x-dunst-stack-tag:slaade-cockpit "SLAADE" "$1"
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
hyprctl dispatch workspace name:SLAADE >/dev/null 2>&1 || true

sleep 0.6

if run_if_exists fastfetch; then
  hyprctl dispatch exec "[workspace name:SLAADE silent] $terminal --class fastfetch-cockpit -e bash -lc 'fastfetch; echo; echo \"system ready.\"; exec \"${SHELL:-/bin/bash}\" -l'"
else
  notify "fastfetch not found; skipping system overview."
fi

sleep 0.5

if run_if_exists btop; then
  hyprctl dispatch exec "[workspace name:SLAADE silent] $terminal --class btop-cockpit -e btop"
else
  notify "btop not found; skipping resource monitor."
fi

sleep 0.6

if run_if_exists tmux; then
  hyprctl dispatch exec "[workspace name:term silent] $terminal --class tmux-cockpit -e zsh -lc 'tmux new-session -A -s dev -c \"$HOME\"; exec zsh -l'"
else
  notify "tmux not found; opening a plain terminal."
  hyprctl dispatch exec "[workspace name:term silent] $terminal"
fi

sleep 0.6
if run_if_exists "$browser"; then
  hyprctl dispatch exec "[workspace name:search silent] $browser --new-window https://login.tailscale.com/admin/machines"
else
  notify "$browser not found; skipping Tailscale admin window."
fi

sleep 0.5

if run_if_exists watch; then
  status_command="date +%T"

  if run_if_exists tailscale; then
    status_command="tailscale status"
  else
    notify "tailscale not found; status monitor will show the clock only."
  fi

  if run_if_exists sensors; then
    status_command="$status_command; echo; sensors"
  else
    notify "sensors not found; skipping temperature readout."
  fi

  hyprctl dispatch exec "[workspace name:search silent] $terminal --class tailscale-status-cockpit -e watch -c -n 2 '$status_command'"
else
  notify "watch not found; skipping status monitor."
fi

sleep 1.2
notify "Cockpit online."

# Land on the main development terminal after the reveal finishes.
hyprctl dispatch workspace name:term >/dev/null 2>&1 || true
