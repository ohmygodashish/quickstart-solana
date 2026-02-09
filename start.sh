#!/bin/bash
set -euo pipefail 

DEVNET_URL="https://api.devnet.solana.com"
DEFAULT_WALLET="./devnet-wallet-$(date +%Y%m%d-%H%M%S).json"

WALLET_PATH=""
WALLET_PUBKEY=""
TOKEN_MINT=""
TOKEN_ACCOUNT=""

ask_yes_no() {
  local prompt="$1"
  local default="${2:-N}"
  local input

  if [[ "$default" == "Y" ]]; then
    read -r -p "$prompt [Y/n]: " input
    input="${input:-Y}"
  else
    read -r -p "$prompt [y/N]: " input
    input="${input:-N}"
  fi

  [[ "$input" =~ ^[Yy]$ ]]
}
