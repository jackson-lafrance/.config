#!/usr/bin/env bash
set -euo pipefail

main_dir="${COCKPIT_MAIN_DIR:-$HOME}"

if [[ ! -d "$main_dir" ]]; then
  main_dir="$HOME"
fi

cd "$main_dir"
exec nvim "$main_dir" -c "Oil"
