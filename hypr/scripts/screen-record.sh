#!/usr/bin/env bash
set -euo pipefail

app="SLAADE"
mode="${1:-toggle-area}"
runtime_dir="${XDG_RUNTIME_DIR:-/tmp}"
pid_file="$runtime_dir/slaade-screen-recording.pid"
path_file="$runtime_dir/slaade-screen-recording.path"

notify() {
  local urgency="${3:-low}"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send \
      -a "$app" \
      -u "$urgency" \
      -h string:x-dunst-stack-tag:slaade-screen-recording \
      "$1" "$2"
  fi
}

is_recording() {
  [[ -f "$pid_file" ]] || return 1
  local pid
  pid="$(<"$pid_file")"
  [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}

recordings_dir() {
  local videos_dir="$HOME/Videos"
  if command -v xdg-user-dir >/dev/null 2>&1; then
    videos_dir="$(xdg-user-dir VIDEOS 2>/dev/null || printf '%s/Videos' "$HOME")"
  fi
  printf '%s/Recordings' "$videos_dir"
}

stop_recording() {
  if ! is_recording; then
    rm -f "$pid_file" "$path_file"
    notify "No recording active" "Nothing to stop."
    return 1
  fi

  local pid file
  pid="$(<"$pid_file")"
  file="$(<"$path_file" 2>/dev/null || true)"

  kill -INT "$pid" 2>/dev/null || true

  for _ in {1..30}; do
    kill -0 "$pid" 2>/dev/null || break
    sleep 0.1
  done

  rm -f "$pid_file" "$path_file"
  notify "Recording saved" "${file/#$HOME/~}"
}

start_recording() {
  local capture_mode="$1"

  if is_recording; then
    notify "Recording already active" "Press SUPER+SHIFT+R to stop it first."
    exit 1
  fi

  if ! command -v wf-recorder >/dev/null 2>&1; then
    notify "Screen recording unavailable" "Install wf-recorder to enable this binding." normal
    exit 1
  fi

  local dir file geometry
  dir="$(recordings_dir)"
  mkdir -p "$dir"
  file="$dir/Recording_$(date '+%Y-%m-%d_%H-%M-%S').mp4"

  declare -a args=(-f "$file")
  case "$capture_mode" in
    area)
      if ! command -v slurp >/dev/null 2>&1; then
        notify "Area recording unavailable" "slurp is not installed." normal
        exit 1
      fi
      geometry="$(slurp 2>/dev/null || true)"
      if [[ -z "$geometry" ]]; then
        notify "Recording cancelled" "No region was selected."
        exit 1
      fi
      args=(-g "$geometry" -f "$file")
      ;;
    full)
      ;;
    *)
      printf 'internal error: unknown capture mode %s\n' "$capture_mode" >&2
      exit 2
      ;;
  esac

  local log_file="$runtime_dir/slaade-wf-recorder.log"
  wf-recorder "${args[@]}" >"$log_file" 2>&1 &
  local pid=$!

  sleep 0.2
  if ! kill -0 "$pid" 2>/dev/null; then
    rm -f "$pid_file" "$path_file"
    local error
    error="$(tail -n 1 "$log_file" 2>/dev/null || true)"
    notify "Recording failed" "${error:-wf-recorder exited before recording started.}" normal
    exit 1
  fi

  printf '%s' "$pid" > "$pid_file"
  printf '%s' "$file" > "$path_file"

  notify "Recording started" "SUPER+SHIFT+R stops and saves it."
}

case "$mode" in
  area|start-area|toggle-area)
    start_recording area
    ;;
  full|start-full|toggle-full)
    start_recording full
    ;;
  stop)
    stop_recording
    ;;
  toggle)
    if is_recording; then
      stop_recording
    else
      start_recording area
    fi
    ;;
  *)
    printf 'usage: %s {area|full|stop|toggle|toggle-area|toggle-full}\n' "$0" >&2
    exit 2
    ;;
esac
