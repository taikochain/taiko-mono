// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {AddressResolver} from "../../common/AddressResolver.sol";
import {LibAddress} from "../../libs/LibAddress.sol";
import {LibTokenomics} from "./LibTokenomics.sol";
import {Lib1559} from "./Lib1559.sol";
import {LibUtils} from "./LibUtils.sol";
import {
    SafeCastUpgradeable
} from "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import {TaikoData} from "../TaikoData.sol";

library LibProposing {
    using SafeCastUpgradeable for uint256;
    using LibUtils for TaikoData.State;
    using LibAddress for address;

    event BlockProposed(
        uint256 indexed id,
        TaikoData.BlockMetadata meta,
        bool txListCached
    );

    error L1_BLOCK_ID();
    error L1_INSUFFICIENT_BLOCKSPACE();
    error L1_INSUFFICIENT_ETHER_BURN();
    error L1_INSUFFICIENT_TOKEN();
    error L1_INVALID_METADATA();
    error L1_NOT_SOLO_PROPOSER();
    error L1_TOO_MANY_BLOCKS();
    error L1_TX_LIST_NOT_EXIST();
    error L1_TX_LIST_HASH();
    error L1_TX_LIST_RANGE();
    error L1_TX_LIST();

    function proposeBlock(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        AddressResolver resolver,
        TaikoData.BlockMetadataInput memory input,
        bytes calldata txList
    ) internal {
        bool txListCached = _validateBlock({
            state: state,
            config: config,
            resolver: resolver,
            input: input,
            txList: txList
        });

        TaikoData.BlockMetadata memory meta = TaikoData.BlockMetadata({
            id: state.numBlocks,
            timestamp: uint64(block.timestamp),
            l1Height: uint64(block.number - 1),
            gasLimit: input.gasLimit,
            l1Hash: blockhash(block.number - 1),
            mixHash: 0, // will be set later
            txListHash: input.txListHash,
            txListByteStart: input.txListByteStart,
            txListByteEnd: input.txListByteEnd,
            beneficiary: input.beneficiary,
            basefeePerGas: 0 // will be set later
        });

        // After The Merge, L1 mixHash contains the prevrandao
        // from the beacon chain. Since multiple Taiko blocks
        // can be proposed in one Ethereum block, we need to
        // add salt to this random number as L2 mixHash
        unchecked {
            meta.mixHash = bytes32(block.prevrandao * state.numBlocks);
        }

        // L2 1559 fee calculation
        {
            uint256 gasPurchaseCost;
            (meta.basefeePerGas, gasPurchaseCost, state.gasExcess) = Lib1559
                .purchaseGas(config, state.gasExcess, input.gasLimit);

            if (msg.value < gasPurchaseCost)
                revert L1_INSUFFICIENT_ETHER_BURN();

            unchecked {
                if (state.lastProposedHeight == block.number) {
                    state.gasSoldThisBlock += meta.gasLimit;
                } else {
                    state.lastProposedHeight = uint64(block.number);
                    state.gasSoldThisBlock = meta.gasLimit;
                }
                msg.sender.sendEther(msg.value - gasPurchaseCost);
            }
        }

        TaikoData.Block storage blk = state.blocks[
            state.numBlocks % config.ringBufferSize
        ];

        blk.blockId = state.numBlocks;
        blk.proposedAt = meta.timestamp;
        blk.deposit = 0; // will be set later
        blk.nextForkChoiceId = 1;
        blk.verifiedForkChoiceId = 0;
        blk.metaHash = LibUtils.hashMetadata(meta);
        blk.proposer = msg.sender;

        // L1 proposing fee and proving reward calculation
        if (config.enableTokenomics) {
            (uint256 newFeeBase, uint256 fee, uint256 deposit) = LibTokenomics
                .getBlockFee(state, config);

            uint256 burnAmount = fee + deposit;
            if (state.balances[msg.sender] <= burnAmount)
                revert L1_INSUFFICIENT_TOKEN();

            state.balances[msg.sender] -= burnAmount;

            blk.deposit = uint64(deposit);

            // Update feeBase and avgBlockTime
            state.feeBase = LibUtils
                .movingAverage({
                    maValue: state.feeBase,
                    newValue: newFeeBase,
                    maf: config.feeBaseMAF
                })
                .toUint64();
        }

        unchecked {
            state.avgBlockTime = LibUtils
                .movingAverage({
                    maValue: state.avgBlockTime,
                    newValue: (meta.timestamp - state.lastProposedAt) * 1000,
                    maf: config.proposingConfig.avgTimeMAF
                })
                .toUint64();
        }

        state.lastProposedAt = meta.timestamp;

        emit BlockProposed(state.numBlocks, meta, txListCached);
        unchecked {
            ++state.numBlocks;
        }
    }

    function getBlock(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        uint256 blockId
    ) internal view returns (TaikoData.Block storage blk) {
        blk = state.blocks[blockId % config.ringBufferSize];
        if (blk.blockId != blockId) revert L1_BLOCK_ID();
    }

    function _validateBlock(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        AddressResolver resolver,
        TaikoData.BlockMetadataInput memory input,
        bytes calldata txList
    ) private returns (bool txListCached) {
        // For alpha-2 testnet, the network only allows an special address
        // to propose but anyone to prove. This is the first step of testing
        // the tokenomics.
        if (
            config.enableSoloProposer &&
            msg.sender != resolver.resolve("solo_proposer", false)
        ) revert L1_NOT_SOLO_PROPOSER();

        if (
            input.beneficiary == address(0) ||
            input.gasLimit > config.blockGasTarget * 2
        ) revert L1_INVALID_METADATA();

        if (input.gasLimit > Lib1559.getMaxGasPurchaseAmount(state, config))
            revert L1_INSUFFICIENT_BLOCKSPACE();

        if (
            state.numBlocks >=
            state.lastVerifiedBlockId + config.maxNumProposedBlocks + 1
        ) revert L1_TOO_MANY_BLOCKS();

        // verify txList
        uint24 size = uint24(txList.length);
        if (size > config.maxBytesPerTxList) revert L1_TX_LIST();

        if (input.txListByteStart > input.txListByteEnd)
            revert L1_TX_LIST_RANGE();

        if (config.txListCacheExpiry == 0) {
            // caching is disabled
            if (input.txListByteStart != 0 || input.txListByteEnd != size)
                revert L1_TX_LIST_RANGE();
        } else {
            // caching is enabled
            if (size == 0) {
                // This blob shall have been submitted earlier
                TaikoData.TxListInfo memory info = state.txListInfo[
                    input.txListHash
                ];

                if (input.txListByteEnd > info.size) revert L1_TX_LIST_RANGE();

                if (
                    info.size == 0 ||
                    info.validSince + config.txListCacheExpiry < block.timestamp
                ) revert L1_TX_LIST_NOT_EXIST();
            } else {
                if (input.txListByteEnd > size) revert L1_TX_LIST_RANGE();
                if (input.txListHash != keccak256(txList))
                    revert L1_TX_LIST_HASH();

                if (input.cacheTxListInfo != 0) {
                    state.txListInfo[input.txListHash] = TaikoData.TxListInfo({
                        validSince: uint64(block.timestamp),
                        size: size
                    });
                    txListCached = true;
                }
            }
        }
    }
}
