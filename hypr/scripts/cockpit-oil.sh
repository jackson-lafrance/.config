#!/usr/bin/env bash
set -euo pipefail

# Keep Oil anchored to your home directory, regardless of any future cockpit
# directory changes.
oil_dir="$HOME"

cd "$oil_dir"
exec nvim "$oil_dir" -c "Oil"
