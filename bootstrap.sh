#! /bin/bash

log() {
  local log_type="INFO"
  local fd=1
  local colored_prefix

  if [[ $# -ge 2 ]]; then
    case "$1" in
      INFO | WARN | ERROR)
        log_type="$1"
        shift
        ;;
    esac
  fi
  case "$log_type" in
    INFO) colored_prefix='\e[32mINFO:\e[0m  ' ;;
    WARN)
      colored_prefix='\e[33mWARN:\e[0m  '
      fd=2
      ;;
    ERROR)
      colored_prefix='\e[31mERROR:\e[0m '
      fd=2
      ;;
  esac
  echo -e "${colored_prefix}$1" >&$fd

  # Extra lines to print indented
  shift
  local line

  for line in "$@"; do
    echo -e "       $line" >&$fd
  done
}

REPO="https://github.com/coderadu/factorio-headless-install.git"
CLONE_PATH="$HOME/factorio-headless-install"

# Install git
log "Installing git"
sudo apt install git -y &> /dev/null

# Clone repo
log "Cloning repo with git to $CLONE_PATH"
git clone "$REPO" "$CLONE_PATH" &> /dev/null

# Run installation script
log "Installing factorio headless"
cd $CLONE_PATH
sudo $CLONE_PATH/install.sh &> /dev/null

# Cleanup
log "Cleaning up"
sudo rm -r $CLONE_PATH 

log "Factorio headless successfully installed to /srv/factorio"
log "You can use factorioctl to manage your server"
