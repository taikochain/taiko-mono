#!/bin/sh

# This script is only used by `pnpm test:deploy`.
set -e

export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
PROPOSER=0x0000000000000000000000000000000000000000 \
TAIKO_TOKEN=0x0000000000000000000000000000000000000000 \
PROPOSER_ONE=0x0000000000000000000000000000000000000000 \
GUARDIAN_PROVERS="0x1000777700000000000000000000000000000001,0x1000777700000000000000000000000000000002,0x1000777700000000000000000000000000000003,0x1000777700000000000000000000000000000004,0x1000777700000000000000000000000000000005,0x1000777700000000000000000000000000000006,0x1000777700000000000000000000000000000007" \
TAIKO_L2_ADDRESS=0x1000777700000000000000000000000000000001 \
L2_SIGNAL_SERVICE=0x1000777700000000000000000000000000000007 \
CONTRACT_OWNER=0x60997970C51812dc3A010C7d01b50e0d17dc79C8 \
TAIKO_TOKEN_PREMINT_RECIPIENT=0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 \
TAIKO_TOKEN_NAME="Taiko Token Katla" \
TAIKO_TOKEN_SYMBOL=TTKOk \
SHARED_ADDRESS_MANAGER=0x0000000000000000000000000000000000000000 \
L2_GENESIS_HASH=0xee1950562d42f0da28bd4550d88886bc90894c77c9c9eaefef775d4c8223f259 \
PAUSE_TAIKO_L1=true \
PAUSE_BRIDGE=true \
NUM_MIN_MAJORITY_GUARDIANS=7 \
NUM_MIN_MINORITY_GUARDIANS=2 \
TIER_PROVIDER="devnet" \
forge script script/DeployOnL1.s.sol:DeployOnL1 \
    --fork-url http://localhost:8545 \
    --broadcast \
    --ffi \
    -vvvv \
    --private-key $PRIVATE_KEY \
    --block-gas-limit 100000000

export PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
SECURITY_COUNCIL=0x60997970C51812dc3A010C7d01b50e0d17dc79C8 \
TAIKO_TOKEN_PREMINT_RECIPIENT=0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 \
TAIKO_TOKEN_NAME="Taiko Token" \
TAIKO_TOKEN_SYMBOL=TTKO \
forge script script/DeployTaikoToken.s.sol:DeployTaikoToken \
    --fork-url http://localhost:8545 \
    --broadcast \
    --ffi \
    -vvvv \
    --private-key $PRIVATE_KEY \
    --block-gas-limit 100000000
