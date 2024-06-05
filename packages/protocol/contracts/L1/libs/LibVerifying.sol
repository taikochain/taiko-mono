// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../../signal/ISignalService.sol";
import "./LibUtils.sol";

/// @title LibVerifying
/// @notice A library for handling block verification in the Taiko protocol.
/// @custom:security-contact security@taiko.xyz
library LibVerifying {
    using LibMath for uint256;

    struct Local {
        uint64 blockId;
        uint64 slot;
        uint32 tid;
        bytes32 blockHash;
        bytes32 stateRoot;
        uint64 numBlocksVerified;
        ITierProvider tierProvider;
        uint256 blockGroup;
    }

    // Warning: Any events defined here must also be defined in TaikoEvents.sol.
    /// @notice Emitted when a block is verified.
    /// @param blockId The block ID.
    /// @param prover The actual prover of the block.
    /// @param blockHash The block hash.
    /// @param stateRoot The state root.
    /// @param tier The tier of the transition used for verification.
    event BlockVerified(
        uint256 indexed blockId,
        address indexed prover,
        bytes32 blockHash,
        bytes32 stateRoot,
        uint16 tier
    );

    /// @notice Emitted when some state variable values changed.
    /// @dev This event is currently used by Taiko node/client for block proposal/proving.
    /// @param slotB The SlotB data structure.
    event StateVariablesUpdated(TaikoData.SlotB slotB);

    // Warning: Any errors defined here must also be defined in TaikoErrors.sol.
    error L1_BLOCK_MISMATCH();
    error L1_INVALID_CONFIG();
    error L1_INVALID_GENESIS_HASH();
    error L1_TRANSITION_ID_ZERO();
    error L1_TOO_LATE();

    /// @notice Initializes the Taiko protocol state.
    /// @param _state The state to initialize.
    /// @param _config The configuration for the Taiko protocol.
    /// @param _genesisBlockHash The block hash of the genesis block.
    function init(
        TaikoData.State storage _state,
        TaikoData.Config memory _config,
        bytes32 _genesisBlockHash
    )
        internal
    {
        if (!_isConfigValid(_config)) revert L1_INVALID_CONFIG();

        _setupGenesisBlock(_state, _genesisBlockHash);
    }

    function resetGenesisHash(TaikoData.State storage _state, bytes32 _genesisBlockHash) internal {
        if (_state.slotB.numBlocks != 1) revert L1_TOO_LATE();

        _setupGenesisBlock(_state, _genesisBlockHash);
    }

    /// @dev Verifies up to N blocks.
    function verifyBlocks(
        TaikoData.State storage _state,
        IERC20 _tko,
        TaikoData.Config memory _config,
        IAddressResolver _resolver,
        uint64 _maxBlocksToVerify
    )
        internal
    {
        if (_maxBlocksToVerify == 0) {
            return;
        }

        // Retrieve the latest verified block and the associated transition used
        // for its verification.
        TaikoData.SlotB memory b = _state.slotB;

        Local memory local;
        local.blockId = b.lastVerifiedBlockId;
        local.slot = local.blockId % _config.blockRingBufferSize;

        TaikoData.Block storage blk = _state.blocks[local.slot];
        if (blk.blockId != local.blockId) revert L1_BLOCK_MISMATCH();

        local.tid = blk.verifiedTransitionId;

        // The following scenario should never occur but is included as a
        // precaution.
        if (local.tid == 0) revert L1_TRANSITION_ID_ZERO();

        // The `blockHash` variable represents the most recently trusted
        // blockHash on L2.
        local.blockHash = _state.transitions[local.slot][local.tid].blockHash;

        // Unchecked is safe:
        // - assignment is within ranges
        // - blockId and numBlocksVerified values incremented will still be OK in the
        // next 584K years if we verifying one block per every second
        unchecked {
            ++local.blockId;

            while (local.blockId < b.numBlocks && local.numBlocksVerified < _maxBlocksToVerify) {
                local.slot = local.blockId % _config.blockRingBufferSize;

                blk = _state.blocks[local.slot];
                if (blk.blockId != local.blockId) revert L1_BLOCK_MISMATCH();

                local.tid = LibUtils.getTransitionId(_state, blk, local.slot, local.blockHash);
                // When `tid` is 0, it indicates that there is no proven
                // transition with its parentHash equal to the blockHash of the
                // most recently verified block.
                if (local.tid == 0) break;

                // A transition with the correct `parentHash` has been located.
                TaikoData.TransitionState storage ts = _state.transitions[local.slot][local.tid];

                // It's not possible to verify this block if either the
                // transition is contested and awaiting higher-tier proof or if
                // the transition is still within its cooldown period.
                uint16 tier = ts.tier;

                if (ts.contester != address(0)) {
                    break;
                } else {
                    uint256 blockGroup = LibUtils.blockIdToGroup(local.blockId);
                    if (
                        local.tierProvider == ITierProvider(address(0))
                            || local.blockGroup != blockGroup
                    ) {
                        local.blockGroup = blockGroup;
                        local.tierProvider = LibUtils.getTierProvider(_resolver, blockGroup);
                    }

                    if (
                        !LibUtils.isPostDeadline(
                            ts.timestamp,
                            b.lastUnpausedAt,
                            local.tierProvider.getTier(tier).cooldownWindow
                        )
                    ) {
                        // If cooldownWindow is 0, the block can theoretically
                        // be proved and verified within the same L1 block.
                        break;
                    }
                }

                // Mark this block as verified
                blk.verifiedTransitionId = local.tid;

                // Update variables
                local.blockHash = ts.blockHash;
                local.stateRoot = ts.stateRoot;

                address prover = ts.prover;
                _tko.transfer(prover, ts.validityBond);

                // Note: We exclusively address the bonds linked to the
                // transition used for verification. While there may exist
                // other transitions for this block, we disregard them entirely.
                // The bonds for these other transitions are burned (more precisely held in custody)
                // either when the transitions are generated or proven. In such cases, both the
                // provers and contesters of those transitions forfeit their bonds.

                emit BlockVerified({
                    blockId: local.blockId,
                    prover: prover,
                    blockHash: local.blockHash,
                    stateRoot: local.stateRoot,
                    tier: tier
                });

                ++local.blockId;
                ++local.numBlocksVerified;
            }

            if (local.numBlocksVerified != 0) {
                uint64 lastVerifiedBlockId = b.lastVerifiedBlockId + local.numBlocksVerified;

                // Update protocol level state variables
                _state.slotB.lastVerifiedBlockId = lastVerifiedBlockId;

                // Sync chain data
                _syncChainData(_state, _config, _resolver, lastVerifiedBlockId, local.stateRoot);
            }
        }
    }

    /// @notice Emit events used by client/node.
    function emitEventForClient(TaikoData.State storage _state) internal {
        emit StateVariablesUpdated({ slotB: _state.slotB });
    }

    function _setupGenesisBlock(
        TaikoData.State storage _state,
        bytes32 _genesisBlockHash
    )
        private
    {
        if (_genesisBlockHash == 0) revert L1_INVALID_GENESIS_HASH();
        // Init state
        _state.slotA.genesisHeight = uint64(block.number);
        _state.slotA.genesisTimestamp = uint64(block.timestamp);
        _state.slotB.numBlocks = 1;

        // Init the genesis block
        TaikoData.Block storage blk = _state.blocks[0];
        blk.nextTransitionId = 2;
        blk.proposedAt = uint64(block.timestamp);
        blk.verifiedTransitionId = 1;
        blk.metaHash = bytes32(uint256(1)); // Give the genesis metahash a non-zero value.

        // Init the first state transition
        TaikoData.TransitionState storage ts = _state.transitions[0][1];
        ts.blockHash = _genesisBlockHash;
        ts.prover = address(0);
        ts.timestamp = uint64(block.timestamp);

        emit BlockVerified({
            blockId: 0,
            prover: address(0),
            blockHash: _genesisBlockHash,
            stateRoot: 0,
            tier: 0
        });
    }

    function _syncChainData(
        TaikoData.State storage _state,
        TaikoData.Config memory _config,
        IAddressResolver _resolver,
        uint64 _lastVerifiedBlockId,
        bytes32 _stateRoot
    )
        private
    {
        ISignalService signalService =
            ISignalService(_resolver.resolve(LibStrings.B_SIGNAL_SERVICE, false));

        (uint64 lastSyncedBlock,) = signalService.getSyncedChainData(
            _config.chainId, LibStrings.H_STATE_ROOT, 0 /* latest block Id*/
        );

        if (_lastVerifiedBlockId > lastSyncedBlock + _config.blockSyncThreshold) {
            _state.slotA.lastSyncedBlockId = _lastVerifiedBlockId;
            _state.slotA.lastSynecdAt = uint64(block.timestamp);

            signalService.syncChainData(
                _config.chainId, LibStrings.H_STATE_ROOT, _lastVerifiedBlockId, _stateRoot
            );
        }
    }

    function _isConfigValid(TaikoData.Config memory _config) private view returns (bool) {
        if (
            _config.chainId <= 1 || _config.chainId == block.chainid //
                || _config.blockMaxProposals <= 1
                || _config.blockRingBufferSize <= _config.blockMaxProposals + 1
                || _config.blockMaxGasLimit == 0 || _config.livenessBond == 0
        ) return false;

        return true;
    }
}
