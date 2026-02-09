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

require_cmd() {
    local cmd="$1"
    
    if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: '$cmd' is not installed or not in PATH."
    exit 1
    fi
}

parse_value() {
  # Usage: parse_value "Creating token" "$output"
  local label="$1"
  local output="$2"
  echo "$output" | awk -v lbl="$label" '$0 ~ lbl {print $3; exit}'
}
