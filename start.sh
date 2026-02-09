#!/bin/bash
set -euo pipefail 

DEVNET_URL="https://api.devnet.solana.com"
DEFAULT_WALLET="./devnet-wallet-$(date +%Y%m%d-%H%M%S).json"

WALLET_PATH=""
WALLET_PUBKEY=""
TOKEN_MINT=""
TOKEN_ACCOUNT=""
