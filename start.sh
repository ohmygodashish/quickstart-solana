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

if ! $DO_WALLET; then
  read -r -p "Enter wallet keypair path (default: ~/.config/solana/id.json): " WALLET_PATH
  WALLET_PATH="${WALLET_PATH:-$HOME/.config/solana/id.json}"

  if [[ ! -f "$WALLET_PATH" ]]; then
    echo "Error: Wallet file not found at '$WALLET_PATH'"
    exit 1
  fi
fi

if $DO_WALLET; then
  read -r -p "Enter wallet output path (default: $DEFAULT_WALLET): " WALLET_PATH
  WALLET_PATH="${WALLET_PATH:-$DEFAULT_WALLET}"

  echo ""
  echo "Generating wallet..."
  solana-keygen new \
    --outfile "$WALLET_PATH" \
    --force \
    --no-bip39-passphrase
fi

WALLET_PUBKEY="$(solana-keygen pubkey "$WALLET_PATH")"
echo "Using wallet: $WALLET_PATH"
echo "Wallet pubkey: $WALLET_PUBKEY"

if ask_yes_no "Request 2 SOL airdrop to this wallet on devnet (recommended for fees)?" "Y"; then
  solana airdrop 2 "$WALLET_PUBKEY" --url "$DEVNET_URL" || true
  solana balance "$WALLET_PUBKEY" --url "$DEVNET_URL" || true
fi

if $DO_TOKEN; then
  echo ""
  echo "Creating token on devnet..."

  TOKEN_OUTPUT="$(
    spl-token \
      --url "$DEVNET_URL" \
      --owner "$WALLET_PATH" \
      --fee-payer "$WALLET_PATH" \
      create-token
  )"

  echo "$TOKEN_OUTPUT"

  TOKEN_MINT="$(parse_value "Creating token" "$TOKEN_OUTPUT")"
  if [[ -z "$TOKEN_MINT" ]]; then
    echo "Error: Could not parse token mint address from output."
    exit 1
  fi

  echo "Token mint address: $TOKEN_MINT"
fi

if ! $DO_TOKEN && { $DO_ACCOUNT || $DO_MINT; }; then
  read -r -p "Enter existing token mint address: " TOKEN_MINT
  if [[ -z "$TOKEN_MINT" ]]; then
    echo "Error: Token mint address is required."
    exit 1
  fi
fi

if $DO_ACCOUNT; then
  echo ""
  echo "Creating token account for mint: $TOKEN_MINT"

  ACCOUNT_OUTPUT="$(
    spl-token \
      --url "$DEVNET_URL" \
      --owner "$WALLET_PATH" \
      --fee-payer "$WALLET_PATH" \
      create-account "$TOKEN_MINT"
  )"

  echo "$ACCOUNT_OUTPUT"

  TOKEN_ACCOUNT="$(parse_value "Creating account" "$ACCOUNT_OUTPUT")"
  if [[ -z "$TOKEN_ACCOUNT" ]]; then
    echo "Error: Could not parse token account address from output."
    exit 1
  fi

  echo "Token account address: $TOKEN_ACCOUNT"
fi

if $DO_MINT; then
  echo ""

  if [[ -z "$TOKEN_ACCOUNT" ]]; then
    read -r -p "Enter destination token account address: " TOKEN_ACCOUNT
    if [[ -z "$TOKEN_ACCOUNT" ]]; then
      echo "Error: Destination token account is required to mint."
      exit 1
    fi
  fi

  read -r -p "Enter mint quantity: " MINT_QTY
  if [[ ! "$MINT_QTY" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    echo "Error: Invalid quantity '$MINT_QTY'"
    exit 1
  fi

  echo "Minting $MINT_QTY token(s)..."

  spl-token \
    --url "$DEVNET_URL" \
    --owner "$WALLET_PATH" \
    --fee-payer "$WALLET_PATH" \
    mint "$TOKEN_MINT" "$MINT_QTY" "$TOKEN_ACCOUNT"
fi

echo ""
echo "Done."
echo "Wallet keypair: $WALLET_PATH"

[[ -n "$TOKEN_MINT" ]] && echo "Token mint: $TOKEN_MINT"
[[ -n "$TOKEN_ACCOUNT" ]] && echo "Token account: $TOKEN_ACCOUNT"
