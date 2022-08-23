#!/bin/bash

set -eou pipefail

DIR=$(cd $(dirname ${BASH_SOURCE[0]}); pwd)
TEST_NODE_CONTAINER_NAME="test-ethereum-node"
TEST_IMPORT_TEST_ACCOUNT_ETH_JOB_NAME="import-test-account-eth"
TEST_ACCOUNT_ADDRESS="0xdf08f82de32b8d460adbe8d72043e3a7e25a3b39"
TEST_ACCOUNT_PRIV_KEY="2bdd21761a483f71054e14f5b827213567971c676928d9a1808cbfa4b7501200"

if ! command -v docker &> /dev/null 2>&1; then
    echo "ERROR: `docker` command not found"
    exit 1
fi

if ! docker info > /dev/null 2>&1; then
    echo "ERROR: docker daemon isn't running"
    exit 1
fi

# Start a test ethereum node
docker run -d \
  --name $TEST_NODE_CONTAINER_NAME \
  -p 18545:8545 \
  ethereum/client-go:latest \
  --dev --http --http.addr 0.0.0.0 --http.vhosts "*"

sleep 5

# Import ETHs from the pre-allocated developer account to a test account
docker run -d \
  --name $TEST_IMPORT_TEST_ACCOUNT_ETH_JOB_NAME \
  ethereum/client-go:latest \
  --exec 'eth.sendTransaction({from: eth.coinbase, to: "'0xdf08f82de32b8d460adbe8d72043e3a7e25a3b39'", value: web3.toWei(1024, "'ether'")})' attach http://host.docker.internal:18545

trap "docker rm --force $TEST_NODE_CONTAINER_NAME && docker rm --force $TEST_IMPORT_TEST_ACCOUNT_ETH_JOB_NAME" EXIT INT KILL ERR

TEST_LIB_MERKLE_PROOF=true \
PRIVATE_KEY=$TEST_ACCOUNT_PRIV_KEY \
  npx hardhat test --network l1_test --grep "LibMerkleProof"
