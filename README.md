# quickstart-solana

Interactive Bash script to quickly set up a Solana SPL token workflow on **devnet**:
- generate or reuse a wallet
- create a token mint
- create a token account
- mint tokens

## Prerequisites

Make sure these are installed and available in your `PATH`:

- `bash` (Linux/macOS terminal)
- [Solana CLI](https://solana.com/docs/intro/installation) (`solana`, `solana-keygen`)
- [SPL Token CLI](https://spl.solana.com/token) (`spl-token`)

You can verify with:

```bash
solana --version && solana-keygen --version && spl-token --version
```

## Installation

```bash
git clone <your-repo-url>
cd quickstart-solana
chmod +x run.sh
```

## Usage

Run the setup script:

```bash
./run.sh
```

The script is interactive and will ask whether you want to:

1. Generate a new wallet
2. Create a new token on devnet
3. Create a token account on devnet
4. Mint token(s)

If you skip wallet generation, it defaults to:

```bash
~/.config/solana/id.json
```

### A note on the Devnet airdrop

The script can request a 2 SOL devnet airdrop for fees and devnet airdrops can fail sometimes (RPC congestion, faucet rate limits, or temporary outages).  
If that happens, wait and retry, or use another devnet RPC endpoint/faucet.

## License

This project is licensed under the MIT License. See [LICENSE](./LICENSE) for details.
