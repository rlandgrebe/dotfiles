#!/usr/bin/env bash
# Bootstrap a fresh macOS (Apple Silicon) machine with these dotfiles.
#
# Usage:
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rlandgrebe/dotfiles/main/bootstrap.sh)"

set -euo pipefail

if [[ "$(uname -s)" != "Darwin" || "$(uname -m)" != "arm64" ]]; then
  echo "bootstrap.sh currently supports macOS on Apple Silicon only." >&2
  echo "On other platforms, install chezmoi manually and run:" >&2
  echo "  chezmoi init --apply rlandgrebe/dotfiles" >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Make brew available on PATH for the rest of this script.
eval "$(/opt/homebrew/bin/brew shellenv)"

if ! command -v chezmoi >/dev/null 2>&1; then
  echo "==> Installing chezmoi"
  brew install chezmoi
fi

echo "==> Applying dotfiles"
chezmoi init --apply rlandgrebe/dotfiles
