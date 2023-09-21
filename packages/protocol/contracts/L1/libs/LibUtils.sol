// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.20;

import { LibDepositing } from "./LibDepositing.sol";
import { LibMath } from "../../libs/LibMath.sol";
import { TaikoData } from "../TaikoData.sol";

/// @title LibUtils
/// @notice A library that offers helper functions.
library LibUtils {
    using LibMath for uint256;

    // Warning: Any errors defined here must also be defined in TaikoErrors.sol.
    error L1_BLOCK_MISMATCH();
    error L1_INVALID_BLOCK_ID();
    error L1_TRANSITION_NOT_FOUND();
    error L1_UNEXPECTED_TRANSITION_ID();

    /// @dev Retrieves a block based on its ID.
    function getBlock(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        uint64 blockId
    )
        internal
        view
        returns (TaikoData.Block storage blk)
    {
        blk = state.blocks[blockId % config.blockRingBufferSize];
        if (blk.blockId != blockId) {
            revert L1_INVALID_BLOCK_ID();
        }
    }

    /// @dev Retrieves the ID of the transition with a given parentHash.
    /// This function will return 0 if the transtion is not found.
    function getTransitionId(
        TaikoData.State storage state,
        TaikoData.Block storage blk,
        uint64 slot,
        bytes32 parentHash
    )
        internal
        view
        returns (uint32 tid)
    {
        if (state.transitions[slot][1].key == parentHash) {
            tid = 1;
        } else {
            tid = state.transitionIds[blk.blockId][parentHash];
        }

        if (tid >= blk.nextTransitionId) revert L1_UNEXPECTED_TRANSITION_ID();
    }

    /// @dev Retrieves the transition with a given parentHash.
    /// This function will revert if the transition is not found.
    function getTransition(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        uint64 blockId,
        bytes32 parentHash
    )
        internal
        view
        returns (TaikoData.Transition storage tran)
    {
        TaikoData.SlotB memory b = state.slotB;
        if (blockId < b.lastVerifiedBlockId || blockId >= b.numBlocks) {
            revert L1_INVALID_BLOCK_ID();
        }

        uint64 slot = blockId % config.blockRingBufferSize;
        TaikoData.Block storage blk = state.blocks[slot];
        if (blk.blockId != blockId) revert L1_BLOCK_MISMATCH();

        uint32 tid = getTransitionId(state, blk, slot, parentHash);
        if (tid == 0) revert L1_TRANSITION_NOT_FOUND();

        tran = state.transitions[slot][tid];
    }

    /// @dev Retrieves the transition that is used to verify the given block.
    /// This function will revert if the block is not verified.
    function getVerifyingTransition(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        uint64 blockId
    )
        internal
        view
        returns (TaikoData.Transition memory)
    {
        uint64 _blockId =
            blockId == 0 ? state.slotB.lastVerifiedBlockId : blockId;
        uint64 slot = _blockId % config.blockRingBufferSize;

        TaikoData.Block storage blk = state.blocks[slot];

        if (blk.blockId != _blockId) revert L1_BLOCK_MISMATCH();
        if (blk.verifiedTransitionId == 0) revert L1_TRANSITION_NOT_FOUND();

        return state.transitions[slot][blk.verifiedTransitionId];
    }

    function getStateVariables(TaikoData.State storage state)
        internal
        view
        returns (TaikoData.StateVariables memory)
    {
        TaikoData.SlotA memory a = state.slotA;
        TaikoData.SlotB memory b = state.slotB;

        return TaikoData.StateVariables({
            genesisHeight: a.genesisHeight,
            genesisTimestamp: a.genesisTimestamp,
            nextEthDepositToProcess: a.nextEthDepositToProcess,
            numEthDeposits: a.numEthDeposits - a.nextEthDepositToProcess,
            numBlocks: b.numBlocks,
            lastVerifiedBlockId: b.lastVerifiedBlockId
        });
    }
}
