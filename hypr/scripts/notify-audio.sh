#!/usr/bin/env bash
set -euo pipefail

app="SLAADE"
kind="${1:-}"

declare -a target
case "$kind" in
  raise)
    target=("@DEFAULT_AUDIO_SINK@")
    action_label="Volume"
    stack_tag="slaade-volume"
    wpctl set-volume -l 1 "${target[0]}" 5%+
    ;;
  lower)
    target=("@DEFAULT_AUDIO_SINK@")
    action_label="Volume"
    stack_tag="slaade-volume"
    wpctl set-volume "${target[0]}" 5%-
    ;;
  mute)
    target=("@DEFAULT_AUDIO_SINK@")
    action_label="Volume"
    stack_tag="slaade-volume"
    wpctl set-mute "${target[0]}" toggle
    ;;
  mic-mute)
    target=("@DEFAULT_AUDIO_SOURCE@")
    action_label="Microphone"
    stack_tag="slaade-microphone"
    wpctl set-mute "${target[0]}" toggle
    ;;
  *)
    printf 'usage: %s {raise|lower|mute|mic-mute}\n' "$0" >&2
    exit 2
    ;;
esac

if ! command -v notify-send >/dev/null 2>&1; then
  exit 0
fi

status="$(wpctl get-volume "${target[0]}" 2>/dev/null || true)"
volume="$(awk '{print $2}' <<<"$status")"
if [[ -z "$volume" ]]; then
  notify-send -a "$app" -u normal -h string:x-dunst-stack-tag:"$stack_tag" "$action_label" "Updated"
  exit 0
fi

percent="$(awk -v volume="$volume" 'BEGIN { printf "%d", (volume * 100) + 0.5 }')"
if [[ "$status" == *"[MUTED]"* ]]; then
  body="Muted · ${percent}%"
else
  body="${percent}%"
fi

notify-send \
  -a "$app" \
  -u low \
  -h string:x-dunst-stack-tag:"$stack_tag" \
  -h int:value:"$percent" \
  "$action_label" "$body"
