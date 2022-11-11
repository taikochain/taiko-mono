// SPDX-License-Identifier: MIT
//
// ╭━━━━╮╱╱╭╮╱╱╱╱╱╭╮╱╱╱╱╱╭╮
// ┃╭╮╭╮┃╱╱┃┃╱╱╱╱╱┃┃╱╱╱╱╱┃┃
// ╰╯┃┃┣┻━┳┫┃╭┳━━╮┃┃╱╱╭━━┫╰━┳━━╮
// ╱╱┃┃┃╭╮┣┫╰╯┫╭╮┃┃┃╱╭┫╭╮┃╭╮┃━━┫
// ╱╱┃┃┃╭╮┃┃╭╮┫╰╯┃┃╰━╯┃╭╮┃╰╯┣━━┃
// ╱╱╰╯╰╯╰┻┻╯╰┻━━╯╰━━━┻╯╰┻━━┻━━╯
pragma solidity ^0.8.9;

/// @author dantaik <dan@taiko.xyz>
library LibConstants {
    // https://github.com/ethereum-lists/chains/pull/1611
    uint256 public constant K_CHAIN_ID = 167;
    uint256 public constant K_MAX_NUM_BLOCKS = 2049; // up to 2048 pending blocks
    // This number is calculated from K_MAX_NUM_BLOCKS to make
    // the 'the maximum value of the multiplier' close to 20.0
    uint256 public constant K_FEE_PREMIUM_LAMDA = 590;

    uint256 public constant K_MAX_FINALIZATIONS_PER_TX = 20;
    uint256 public constant K_COMMIT_DELAY_CONFIRMS = 4;
    uint256 public constant K_MAX_PROOFS_PER_FORK_CHOICE = 5;
    uint256 public constant K_REWARD_MULTIPLIER = 4;
    uint256 public constant K_BLOCK_MAX_GAS_LIMIT = 5000000; // TODO
    uint256 public constant K_BLOCK_MAX_TXS = 20; // TODO
    uint256 public constant K_TXLIST_MAX_BYTES = 10240; // TODO
    uint256 public constant K_TX_MIN_GAS_LIMIT = 21000; // TODO
    uint256 public constant K_REWARD_BURN_POINTS = 100; // 1%
    uint256 public constant K_ANCHOR_TX_GAS_LIMIT = 250000;

    uint64 public constant K_FEE_MULTIPLIER = 400; // 400%
    uint64 public constant K_FEE_GRACE_PERIOD = 125; // 125%
    uint64 public constant K_FEE_MAX_PERIOD = 375; // 375%
    uint64 public constant K_BLOCK_TIME_CAP = 48 seconds;
    uint64 public constant K_PROOF_TIME_CAP = 60 minutes;
    uint64 public constant K_HALVING = 180 days;

    bytes4 public constant K_ANCHOR_TX_SELECTOR =
        bytes4(keccak256("anchor(uint256,bytes32)"));

    bytes32 public constant K_BLOCK_DEADEND_HASH = bytes32(uint256(1));
    bytes32 public constant K_INVALIDATE_BLOCK_LOG_TOPIC =
        keccak256("BlockInvalidated(bytes32)");
}
