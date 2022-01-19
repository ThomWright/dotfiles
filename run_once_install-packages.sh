#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

# Set up a machine from scratch.
# Intended to be idempotent.

function log {
  echo -e "${1:-}" >&2
}
function logT {
  echo -e "$(date --utc +'%Y-%m-%dT%H:%M:%SZ') $1" >&2
}
function log_heading {
  local string=$1
  local string_length=${#string}

  local underline=""
  for ((i = 1; i <= string_length; i++)); do
    underline=${underline}-
  done

  log "\n$string"
  log $underline
}

function cmd_exists {
  command -v "$1" &>/dev/null
}

function already_installed {
  local cmd=$1
  if cmd_exists "$cmd"; then
    log "Already installed"
    return 0
  else
    return 1
  fi
}

function install_fonts {
  log_heading "Installing fonts"

  local fonts_dir="$HOME/.local/share/fonts"
  if compgen -G "$fonts_dir/Fira*" >/dev/null; then
    log "Fonts already exist"
    return
  fi

  local tmp_dir
  tmp_dir=$(mktemp -d -t nerd-fonts-XXX)

  wget -qP "$tmp_dir" https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip
  unzip -qo "${tmp_dir:?"Missing tmp dir"}"/FiraCode.zip -d "$tmp_dir"

  rm -f "${tmp_dir:?"Missing tmp dir"}"/*Windows*

  mkdir -p "$fonts_dir"
  cp -f "${tmp_dir:?"Missing tmp dir"}"/*.ttf "$fonts_dir"/

  if ! cmd_exists fc-cache; then
    sudo apt-get -qy install fontconfig
  fi
  fc-cache -fv
}

function install_starship {
  local cmd="starship"
  log_heading "Installing $cmd"
  if already_installed $cmd; then return; fi

  sh -c "$(curl -fsSL https://starship.rs/install.sh)" -- --yes
}

function install_fish {
  local cmd="fish"
  log_heading "Installing $cmd"
  if already_installed $cmd; then return; fi

  sudo apt-add-repository -y ppa:fish-shell/release-3
  sudo apt-get -qy install fish

  # Append to /etc/shells
  local fish_bin
  fish_bin=$(which fish)
  grep -qxF "$fish_bin" /etc/shells || echo "$fish_bin" >>/etc/shells

  # Make default shell
  sudo chsh -s "$fish_bin"
}

function install_terminator {
  local cmd="terminator"
  log_heading "Installing $cmd"
  if already_installed $cmd; then return; fi

  sudo add-apt-repository -y ppa:mattrose/terminator
  sudo apt-get -qy install terminator

  # if exists x-terminal-emulator; then
  #   log "Setting default terminal emulator"

  #   local terminator_bin
  #   terminator_bin="$(whereis terminator | awk '{print $2}')"
  #   local terminator_man
  #   terminator_man="$(whereis terminator | awk '{print $3}')"

  #   local xterm_emu_bin
  #   xterm_emu_bin="$(whereis x-terminal-emulator | awk '{print $2}')"
  #   local xterm_emu_man
  #   xterm_emu_man="$(whereis x-terminal-emulator | awk '{print $3}')"

  #   sudo update-alternatives \
  #     --install \
  #     "$xterm_emu_bin" \
  #     x-terminal-emulator \
  #     "$terminator_bin" \
  #     60 \
  #     \
  #     --slave \
  #     "$xterm_emu_man" \
  #     x-terminal-emulator.1.gz \
  #     "$terminator_man"
  # else
  #   log "Skipping setting default terminal emulator"
  # fi
}

function install_shellcheck {
  local cmd="shellcheck"
  log_heading "Installing $cmd"
  if already_installed $cmd; then return; fi
  sudo apt-get -qy install shellcheck
}

function install_docker {
  local cmd="docker"
  log_heading "Installing $cmd"
  if already_installed $cmd; then return; fi

  # Set up repository
  sudo apt-get -qy install \
    ca-certificates \
    gnupg \
    lsb-release

  if [ ! -f /usr/share/keyrings/docker-archive-keyring.gpg ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
      sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  fi
  if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" |
      sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  fi

  sudo apt-get update -qq

  # Install
  sudo apt-get -qy install docker-ce docker-ce-cli containerd.io

  # Set up
  sudo groupadd docker
  sudo usermod --append --groups docker "$USER"
  sudo systemctl enable docker.service
}

function install_docker_compose {
  local cmd="docker-compose"
  log_heading "Installing $cmd"
  if already_installed $cmd; then return; fi

  local version
  version=$(wget --quiet --output-document=- https://api.github.com/repos/docker/compose/releases/latest |
    grep --perl-regexp --only-matching '"tag_name": "\K.*?(?=")')

  log "Installing version: $version"

  sudo curl -sSL "https://github.com/docker/compose/releases/download/${version}/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose

  sudo chmod +x /usr/local/bin/docker-compose
}

function install_vs_code_insiders {
  local cmd="code-insiders"
  log_heading "Installing $cmd"
  if already_installed $cmd; then return; fi

  sudo snap install code-insiders --classic
}

function install_vs_code_extensions {
  xargs -L 1 code-insiders --log error --install-extension <vs-code-extensions.list
}

export DEBIAN_FRONTEND=noninteractive

{
  log_heading "Installing basic utils"
  sudo apt-get update -qq
  sudo apt-get -qy install curl unzip
} >/dev/null

install_fonts
install_starship
install_fish
install_terminator
install_shellcheck
install_docker
install_docker_compose
install_vs_code_insiders
install_vs_code_extensions
