// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {AddressResolver} from "../../common/AddressResolver.sol";
import {LibTokenomics} from "./LibTokenomics.sol";
import {LibUtils} from "./LibUtils.sol";
import {
    SafeCastUpgradeable
} from "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import {TaikoData} from "../TaikoData.sol";

library LibProposing {
    using SafeCastUpgradeable for uint256;
    using LibUtils for TaikoData.State;

    uint public constant BLOB_CACHE_EXPIRY = 24 * 60 minutes; // 1 day

    event TxListInfoCached(bytes32 txListHash, uint64 validSince);
    event BlockProposed(uint256 indexed id, TaikoData.BlockMetadata meta);

    error L1_ID();
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
        // For alpha-2 testnet, the network only allows an special address
        // to propose but anyone to prove. This is the first step of testing
        // the tokenomics.
        if (
            config.enableSoloProposer &&
            msg.sender != resolver.resolve("solo_proposer", false)
        ) revert L1_NOT_SOLO_PROPOSER();

        if (input.txListEnd <= input.txListStart) revert L1_TX_LIST_RANGE();

        if (
            input.beneficiary == address(0) ||
            input.gasLimit > config.blockMaxGasLimit
        ) revert L1_INVALID_METADATA();

        uint64 _now = uint64(block.timestamp);
        uint32 _size = uint32(txList.length);

        if (_size == 0) {
            // This blob shall have been submitted earlier
            TaikoData.TxListInfo memory info = state.txListInfo[
                input.txListHash
            ];

            if (info.size == 0 || info.validSince + BLOB_CACHE_EXPIRY < _now)
                revert L1_TX_LIST_NOT_EXIST();

            if (input.txListEnd > info.size) revert L1_TX_LIST_RANGE();
        } else {
            if (_size > config.maxBytesPerTxList) revert L1_TX_LIST();
            if (input.txListEnd > _size) revert L1_TX_LIST_RANGE();
            if (input.txListHash != keccak256(txList)) revert L1_TX_LIST_HASH();

            if (input.cacheTxListInfo != 0) {
                state.txListInfo[input.txListHash] = TaikoData.TxListInfo({
                    validSince: _now,
                    size: _size
                });
                emit TxListInfoCached(input.txListHash, _now);
            }
        }

        if (state.nextBlockId >= state.lastBlockId + config.maxNumBlocks)
            revert L1_TOO_MANY_BLOCKS();

        // After The Merge, L1 mixHash contains the prevrandao
        // from the beacon chain. Since multiple Taiko blocks
        // can be proposed in one Ethereum block, we need to
        // add salt to this random number as L2 mixHash
        uint256 mixHash;
        unchecked {
            mixHash = block.prevrandao * state.nextBlockId;
        }

        TaikoData.BlockMetadata memory meta = TaikoData.BlockMetadata({
            id: state.nextBlockId,
            gasLimit: input.gasLimit,
            timestamp: _now,
            l1Height: uint64(block.number - 1),
            l1Hash: blockhash(block.number - 1),
            mixHash: bytes32(mixHash),
            txListHash: input.txListHash,
            txListStart: input.txListStart,
            txListEnd: input.txListEnd,
            beneficiary: input.beneficiary
        });

        uint256 deposit;
        if (config.enableTokenomics) {
            uint256 newFeeBase;
            {
                uint256 fee;
                (newFeeBase, fee, deposit) = LibTokenomics.getBlockFee(
                    state,
                    config
                );

                uint256 burnAmount = fee + deposit;
                if (state.balances[msg.sender] <= burnAmount)
                    revert L1_INSUFFICIENT_TOKEN();

                state.balances[msg.sender] -= burnAmount;
            }
            // Update feeBase and avgBlockTime
            state.feeBaseTwei = LibUtils
                .movingAverage({
                    maValue: state.feeBaseTwei,
                    newValue: LibTokenomics.toTwei(newFeeBase),
                    maf: config.feeBaseMAF
                })
                .toUint64();
        }

        state.proposedBlocks[
            state.nextBlockId % config.maxNumBlocks
        ] = TaikoData.ProposedBlock({
            metaHash: LibUtils.hashMetadata(meta),
            deposit: deposit,
            proposer: msg.sender,
            proposedAt: meta.timestamp,
            nextForkChoiceId: 1
        });

        if (state.lastProposedAt > 0) {
            uint256 blockTime;
            unchecked {
                blockTime = (meta.timestamp - state.lastProposedAt) * 1000;
            }
            state.avgBlockTime = LibUtils
                .movingAverage({
                    maValue: state.avgBlockTime,
                    newValue: blockTime,
                    maf: config.proposingConfig.avgTimeMAF
                })
                .toUint64();
        }

        state.lastProposedAt = meta.timestamp;

        emit BlockProposed(state.nextBlockId, meta);
        unchecked {
            ++state.nextBlockId;
        }
    }

    function getProposedBlock(
        TaikoData.State storage state,
        uint256 maxNumBlocks,
        uint256 id
    ) internal view returns (TaikoData.ProposedBlock storage) {
        if (id <= state.lastBlockId || id >= state.nextBlockId) {
            revert L1_ID();
        }

        return state.proposedBlocks[id % maxNumBlocks];
    }
}
