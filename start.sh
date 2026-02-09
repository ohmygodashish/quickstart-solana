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

echo ""
echo "=============================================="
echo " Solana Token Setup (Devnet) "
echo "=============================================="

require_cmd solana-keygen
require_cmd solana
require_cmd spl-token

echo ""
echo "What would you like to do?"

DO_WALLET=false
DO_TOKEN=false
DO_ACCOUNT=false
DO_MINT=false

if ask_yes_no "1) Generate a new wallet with solana-keygen?" "Y"; then
  DO_WALLET=true
fi

if ask_yes_no "2) Create a new token on devnet?" "Y"; then
  DO_TOKEN=true
fi

if ask_yes_no "3) Create a token account on devnet?" "Y"; then
  DO_ACCOUNT=true
fi

if ask_yes_no "4) Mint token(s)?" "N"; then
  DO_MINT=true
fi
