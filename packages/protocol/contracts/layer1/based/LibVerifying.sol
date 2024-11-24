// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "src/shared/signal/ISignalService.sol";
import "./LibBonds.sol";
import "./LibUtils.sol";

/// @title LibVerifying
/// @notice A library that offers helper functions for verifying blocks.
/// @custom:security-contact security@taiko.xyz
library LibVerifying {
    using LibMath for uint256;

    struct Local {
        TaikoData.SlotB b;
        uint64 blockId;
        uint64 slot;
        uint64 numBlocksVerified;
        uint24 tid;
        uint24 lastVerifiedTransitionId;
        bytes32 blockHash;
        bytes32 syncStateRoot;
        uint64 syncBlockId;
        uint24 syncTransitionId;
        address prover;
    }

    error L1_BLOCK_MISMATCH();
    error L1_TRANSITION_ID_ZERO();

    /// @dev Verifies up to N blocks.
    /// @param _state Pointer to the protocol's storage.
    /// @param _config The protocol's configuration.
    /// @param _resolver The address resolver.
    /// @param _maxBlocksToVerify The maximum number of blocks to verify.
    function verifyBlocks(
        TaikoData.State storage _state,
        TaikoData.ConfigV3 memory _config,
        IResolver _resolver,
        uint64 _maxBlocksToVerify
    )
        internal
    {
        if (_maxBlocksToVerify == 0) {
            return;
        }

        Local memory local;
        local.b = _state.slotB;
        local.blockId = local.b.lastVerifiedBlockId;
        local.slot = local.blockId % _config.blockRingBufferSize;

        TaikoData.BlockV3 storage blk = _state.blocks[local.slot];
        require(blk.blockId == local.blockId, L1_BLOCK_MISMATCH());

        local.lastVerifiedTransitionId = blk.verifiedTransitionId;
        local.tid = local.lastVerifiedTransitionId;

        // The `blockHash` variable represents the most recently verified blockHash on L2.
        local.blockHash = _state.transitions[local.slot][local.tid].blockHash;

        // Unchecked is safe: - assignment is within ranges - blockId and numBlocksVerified values
        // incremented will still be OK in the next 584K years if we verify one block per every
        // second
        unchecked {
            ++local.blockId;
        }

        while (local.blockId < local.b.numBlocks && local.numBlocksVerified < _maxBlocksToVerify) {
            local.slot = local.blockId % _config.blockRingBufferSize;

            blk = _state.blocks[local.slot];

            local.tid = LibUtils.getTransitionId(_state, blk, local.slot, local.blockHash);
            // When `tid` is 0, it indicates that there is no proven transition with its
            // parentHash equal to the blockHash of the most recently verified block.
            if (local.tid == 0) break;

            // A transition with the correct `parentHash` has been located.
            TaikoData.TransitionStateV3 storage ts = _state.transitions[local.slot][local.tid];

            // Update variables
            local.lastVerifiedTransitionId = local.tid;
            local.blockHash = ts.blockHash;
            local.prover = ts.prover;

            LibBonds.creditBond(_state, local.prover, local.blockId, ts.validityBond);

            // Note: We exclusively address the bonds linked to the transition used for
            // verification. While there may exist other transitions for this block, we
            // disregard them entirely. The bonds for these other transitions are burned (more
            // precisely held in custody) either when the transitions are generated or proven. In
            // such cases, both the provers and contesters of those transitions forfeit their
            // bonds.

            emit TaikoEvents.BlockVerifiedV3({
                blockId: local.blockId,
                prover: local.prover,
                blockHash: local.blockHash
            });

            if (LibUtils.isSyncBlock(_config.stateRootSyncInternal, local.blockId)) {
                bytes32 stateRoot = ts.stateRoot;
                if (stateRoot != 0) {
                    local.syncStateRoot = stateRoot;
                    local.syncBlockId = local.blockId;
                    local.syncTransitionId = local.tid;
                }
            }
            unchecked {
                ++local.blockId;
                ++local.numBlocksVerified;
            }
        } // end of while-loop

        if (local.numBlocksVerified == 0) return;

        uint64 lastVerifiedBlockId;
        unchecked {
            lastVerifiedBlockId = local.b.lastVerifiedBlockId + local.numBlocksVerified;
        }
        local.slot = lastVerifiedBlockId % _config.blockRingBufferSize;

        _state.slotB.lastVerifiedBlockId = lastVerifiedBlockId;
        _state.blocks[local.slot].verifiedTransitionId = local.lastVerifiedTransitionId;

        if (local.syncStateRoot == 0) return;

        _state.slotA.lastSyncedBlockId = local.syncBlockId;
        _state.slotA.lastSyncedAt = uint64(block.timestamp);

        // We write the synced block's verifiedTransitionId to storage
        if (local.syncBlockId != lastVerifiedBlockId) {
            local.slot = local.syncBlockId % _config.blockRingBufferSize;
            _state.blocks[local.slot].verifiedTransitionId = local.syncTransitionId;
        }

        // Ask signal service to write cross chain signal
        ISignalService(_resolver.resolve(block.chainid, LibStrings.B_SIGNAL_SERVICE, false))
            .syncChainData(
            _config.chainId, LibStrings.H_STATE_ROOT, local.syncBlockId, local.syncStateRoot
        );
    }

    /// @dev Retrieves the prover of a verified block.
    /// @param _state Pointer to the protocol's storage.
    /// @param _config The protocol's configuration.
    /// @param _blockId The ID of the block.
    /// @return The address of the prover.
    function getVerifiedBlockProver(
        TaikoData.State storage _state,
        TaikoData.ConfigV3 memory _config,
        uint64 _blockId
    )
        internal
        view
        returns (address)
    {
        (TaikoData.BlockV3 storage blk,) = LibUtils.getBlock(_state, _config, _blockId);

        uint24 tid = blk.verifiedTransitionId;
        if (tid == 0) return address(0);

        return LibUtils.getTransitionById(_state, _config, _blockId, tid).prover;
    }
}
