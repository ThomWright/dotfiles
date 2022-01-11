#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# TODO: fish, terminator, starship, shellcheck...

log() {
  echo -e "${1:-}" >&2
}
logT() {
  echo -e "$(date --utc +'%Y-%m-%dT%H:%M:%SZ') $1" >&2
}

function install_fonts {
  log "Installing fonts"
  local fonts_dir="$HOME/.local/share/fonts"
  local tmp_dir
  tmp_dir=$(mktemp -d -t nerd-fonts-XXX)

  wget -P "$tmp_dir" https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
  unzip FiraCode.zip

  rm "${tmp_dir:?"Missing tmp dir"}"/*Windows*

  mkdir -p "$fonts_dir"
  cp "${tmp_dir:?"Missing tmp dir"}"/ "$fonts_dir"/

  fc-cache -fv
}

function install_starship {
  log "Installing starship"
  sh -c "$(curl -fsSL https://starship.rs/install.sh)"
}

function install_fish {
  log "Installing fish"
  sudo apt-add-repository ppa:fish-shell/release-3
  sudo apt update
  sudo apt install fish
}

function install_terminator {
  log "Installing Terminator"
  sudo add-apt-repository ppa:mattrose/terminator
  sudo apt-get update
  sudo apt install terminator
}

function install_shellcheck {
  sudo apt install shellcheck
}

install_fonts
install_starship
install_fish
install_terminator
install_shellcheck
