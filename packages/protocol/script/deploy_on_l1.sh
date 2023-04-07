#!/bin/sh

# Please reference Lib1559Math.t.sol for L2 EIP-1559 related variables.
set -e

PRIVATE_KEY=ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
ORACLE_PROVER=0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 \
SOLO_PROPOSER=0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 \
OWNER=0x70997970C51812dc3A010C7d01b50e0d17dc79C8 \
TAIKO_L2_ADDRESS=0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 \
TAIKO_TOKEN_PREMINT_RECIPIENT=0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 \
TAIKO_TOKEN_PREMINT_AMOUNT=0xffff \
TREASURE=0xa0Ee7A142d267C1f36714E4a8F75612F20a79720 \
L2_GENESIS_HASH=0xee1950562d42f0da28bd4550d88886bc90894c77c9c9eaefef775d4c8223f259 \
L2_CHAIN_ID=167001 \
forge script script/DeployOnL1.s.sol:DeployOnL1 \
    --fork-url http://localhost:8545 \
    --broadcast \
    --ffi \
    -vvvv \
    --via-ir \
