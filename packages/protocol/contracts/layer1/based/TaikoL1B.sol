// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import "src/shared/common/EssentialContract.sol";
import "./LibProposing.sol";
import "./LibProving.sol";
import "./LibVerifying.sol";
import "./TaikoEvents.sol";
import "./ITaikoL1.sol";

/// @title TaikoL1V3B
/// @notice This contract serves as the "base layer contract" of the Taiko protocol, providing
/// functionalities for proposing, proving, and verifying blocks. The term "base layer contract"
/// means that although this is usually deployed on L1, it can also be deployed on L2s to create
/// L3s. The contract also handles the deposit and withdrawal of Taiko tokens and Ether.
/// Additionally, this contract doesn't hold any Ether. Ether deposited to L2 are held by the Bridge
/// contract.
/// @dev Labeled in AddressResolver as "taiko"
/// @custom:security-contact security@taiko.xyz
contract TaikoL1V3B is EssentialContract, TaikoEvents {
    using LibMath for uint256;

    uint256 private constant SECONDS_PER_BLOCK = 12 seconds;

    /// @notice The TaikoL1 state.
    TaikoData.State public state;

    uint256[50] private __gap;

    function getConfigV3() public view virtual returns (TaikoData.ConfigV3 memory) {
        return TaikoData.ConfigV3({
            chainId: LibNetwork.TAIKO_MAINNET,
            blockMaxProposals: 324_000, // = 7200 * 45
            blockRingBufferSize: 360_000, // = 7200 * 50
            maxBlocksToVerify: 16,
            blockMaxGasLimit: 240_000_000,
            livenessBond: 125e18, // 125 Taiko token
            stateRootSyncInternal: 16,
            maxAnchorHeightOffset: 64,
            baseFeeConfig: LibSharedData.BaseFeeConfig({
                adjustmentQuotient: 8,
                sharingPctg: 75,
                gasIssuancePerSecond: 5_000_000,
                minGasExcess: 1_340_000_000,
                maxGasIssuancePerBlock: 600_000_000 // two minutes
             }),
            pacayaForkHeight: 0,
            provingWindow: 2 hours
        });
    }

    struct ParentInfo {
        bytes32 metaHash;
        uint64 anchorBlockId;
        uint64 timestamp;
    }

    function proposeBlocksV3(
        address _proposer,
        address _coinbase,
        bytes[] calldata _blockParams
    )
        external
        whenNotPaused
        nonReentrant
        returns (TaikoData.BlockMetadataV3[] memory metas_)
    {
        TaikoData.ConfigV3 memory config = getConfigV3();
        TaikoData.SlotB memory slotB = state.slotB;
        require(_blockParams.length != 0, "NoBlocksToPropose");
        require(slotB.numBlocks >= config.pacayaForkHeight, "InvalidForkHeight");
        require(
            slotB.numBlocks + _blockParams.length
                <= slotB.lastVerifiedBlockId + config.blockMaxProposals,
            "TooManyBlocks"
        );

        ParentInfo memory parent;
        {
            TaikoData.BlockV3 storage parentBlk =
                state.blocks[(slotB.numBlocks - 1) % config.blockRingBufferSize];
            parent = ParentInfo({
                metaHash: parentBlk.metaHash,
                timestamp: parentBlk.timestamp,
                anchorBlockId: parentBlk.anchorBlockId
            });
        }

        _proposer = _checkProposer(_proposer);
        if (_coinbase == address(0)) {
            _coinbase = _proposer;
        }
        metas_ = new TaikoData.BlockMetadataV3[](_blockParams.length);

        for (uint256 i; i < _blockParams.length; ++i) {
            TaikoData.BlockParamsV3 memory params =
                _validateBlockParams(_blockParams[i], config, parent);

            bytes32 metaHash;
            (metas_[i], metaHash) = _proposeBlock(config, slotB, params, _proposer, _coinbase);
            unchecked {
                slotB.numBlocks += 1;
                slotB.lastProposedIn = uint56(block.number);
            }

            parent.metaHash = metaHash;
            parent.timestamp = params.timestamp;
            parent.anchorBlockId = params.anchorBlockId;
        } // end of for-loop

        // SSTORE #3
        _debitBond(_proposer, config.livenessBond * _blockParams.length);

        slotB = _verifyBlocks(slotB, _blockParams.length);
        emit StateVariablesUpdated(slotB);

        // SSTORE #4
        state.slotB = slotB;
    }

    function _proposeBlock(
        TaikoData.ConfigV3 memory _config,
        TaikoData.SlotB memory _slotB,
        TaikoData.BlockParamsV3 memory _params,
        address _proposer,
        address _coinbase
    )
        internal
        returns (TaikoData.BlockMetadataV3 memory meta_, bytes32 metaHash_)
    {
        // Initialize metadata to compute a metaHash, which forms a part of the block data to be
        // stored on-chain for future integrity checks. If we choose to persist all data fields
        // in
        // the metadata, it will require additional storage slots.
        meta_ = TaikoData.BlockMetadataV3({
            anchorBlockHash: blockhash(_params.anchorBlockId),
            difficulty: keccak256(abi.encode("TAIKO_DIFFICULTY", _slotB.numBlocks)),
            blobHash: blobhash(_params.blobIndex),
            // Encode _config.baseFeeConfig into extraData to allow L2 block execution without
            // metadata. Metadata might be unavailable until the block is proposed on-chain. In
            // preconfirmation scenarios, multiple blocks may be built but not yet proposed,
            // making
            // metadata unavailable.
            extraData: bytes32(uint256(_config.baseFeeConfig.sharingPctg)),
            // outside
            // and compute only once.
            coinbase: _coinbase,
            id: _slotB.numBlocks,
            gasLimit: _config.blockMaxGasLimit,
            timestamp: _params.timestamp,
            anchorBlockId: _params.anchorBlockId,
            parentMetaHash: _params.parentMetaHash,
            proposer: _proposer,
            livenessBond: _config.livenessBond,
            proposedAt: uint64(block.timestamp),
            proposedIn: uint64(block.number),
            blobTxListOffset: _params.blobTxListOffset,
            blobTxListLength: _params.blobTxListLength,
            blobIndex: _params.blobIndex,
            baseFeeConfig: _config.baseFeeConfig
        });

        require(meta_.blobHash != 0, "BlobNotFound");

        // Use a storage pointer for the block in the ring buffer
        TaikoData.BlockV3 storage blk = state.blocks[_slotB.numBlocks % _config.blockRingBufferSize];

        // Store each field of the block separately
        // SSTORE #1
        metaHash_ = keccak256(abi.encode(meta_));
        blk.metaHash = metaHash_;

        // SSTORE #2 {{
        blk.blockId = _slotB.numBlocks;
        blk.timestamp = _params.timestamp;
        blk.anchorBlockId = _params.anchorBlockId;
        blk.nextTransitionId = 1;
        blk.livenessBondReturned = false; // TODO(daniel): remove this.
        blk.verifiedTransitionId = 0;
        // SSTORE #2 }}
    }

    function proveBlocks(
        TaikoData.BlockMetadataV3[] calldata _metas,
        TaikoData.TransitionV3[] calldata _transitions,
        bytes calldata proof
    )
        external
    {
        require(_metas.length == _transitions.length, "InvalidParam");
        TaikoData.ConfigV3 memory config = getConfigV3();
        TaikoData.SlotB memory slotB = state.slotB;

        IVerifier.ContextV3[] memory ctxs = new IVerifier.ContextV3[](_metas.length);

        for (uint256 i; i < _metas.length; ++i) {
            ctxs[i] = _proposeBlock(config, slotB, _metas[i], _transitions[i]);
        }

        IVerifier(resolve("TODO", false)).verifyProofV3(ctxs, proof);

        slotB = _verifyBlocks(slotB, _metas.length);
        // SSTORE #4
        emit StateVariablesUpdated(slotB);
        state.slotB = slotB;
    }

    function _proposeBlock(
        TaikoData.ConfigV3 memory _config,
        TaikoData.SlotB memory _slotB,
        TaikoData.BlockMetadataV3 calldata _meta,
        TaikoData.TransitionV3 calldata _tran
    )
        private
        returns (IVerifier.ContextV3 memory ctx_)
    {
        require(_meta.id >= _config.pacayaForkHeight, "InvalidForkHeight");
        require(_meta.id < _slotB.lastVerifiedBlockId, "BlockVerified");
        require(_meta.id < _slotB.numBlocks, "BlockNotProposed");

        require(_tran.parentHash != 0, "InvalidTransitionParentHash");
        require(_tran.blockHash != 0, "InvalidTransitionBlockHash");
        require(_tran.stateRoot != 0, "InvalidTransitionStateRoot");

        ctx_.metaHash = keccak256(abi.encode(_meta));
        ctx_.difficulty = _meta.difficulty;
        ctx_.tran = _tran;

        uint256 slot = _meta.id % _config.blockRingBufferSize;
        TaikoData.BlockV3 storage blk = state.blocks[slot];
        require(ctx_.metaHash == blk.metaHash, "MataMismatch");

        TaikoData.TransitionStateV3 storage ts = state.transitions[slot][1];
        require(ts.key != _tran.parentHash, "AlreadyProvenAsFirstTransition");
        require(state.transitionIds[_meta.id][_tran.parentHash] == 0, "AlreadyProven");

        uint24 tid = blk.nextTransitionId++;
        ts = state.transitions[slot][tid];

        // Checks if only the assigned prover is permissioned to prove the block. The assigned
        // prover is granted exclusive permission to prove only the first transition.
        if (tid == 1) {
            if (msg.sender == _meta.proposer) {
                _creditBond(_meta.proposer, _config.livenessBond);
            } else {
                uint256 deadline = uint256(_meta.proposedAt).max(_slotB.lastUnpausedAt);
                deadline += _config.provingWindow;
                require(block.timestamp >= deadline, "ProvingWindowNotPassed");
            }
            ts.key = _tran.parentHash;
        } else {
            state.transitionIds[_meta.id][_tran.parentHash] = tid;
        }

        ts.blockHash = _tran.blockHash;

        if (_isSyncBlock(_config.stateRootSyncInternal, _meta.id)) {
            ts.stateRoot = _tran.stateRoot;
        }
    }

    function _validateBlockParams(
        bytes calldata _blockParam,
        TaikoData.ConfigV3 memory _config,
        ParentInfo memory _parent
    )
        private
        view
        returns (TaikoData.BlockParamsV3 memory params_)
    {
        if (_blockParam.length != 0) {
            params_ = abi.decode(_blockParam, (TaikoData.BlockParamsV3));
        }

        if (params_.anchorBlockId == 0) {
            params_.anchorBlockId = uint64(block.number - 1);
        } else {
            require(
                params_.anchorBlockId + _config.maxAnchorHeightOffset >= block.number
                    && params_.anchorBlockId < block.number
                    && params_.anchorBlockId >= _parent.anchorBlockId,
                "InvalidAnchorBlockId"
            );
        }

        if (params_.timestamp == 0) {
            params_.timestamp = uint64(block.timestamp);
        } else {
            // Verify the provided timestamp to anchor. Note that params_.anchorBlockId
            // and
            // params_.timestamp may not correspond to the same L1 block.
            require(
                params_.timestamp + _config.maxAnchorHeightOffset * SECONDS_PER_BLOCK
                    >= block.timestamp && params_.timestamp <= block.timestamp
                    && params_.timestamp >= _parent.timestamp,
                "InvalidTiemstamp"
            );
        }

        // Check if parent block has the right meta hash. This is to allow the proposer to
        // make sure the block builds on the expected latest chain state.
        require(
            params_.parentMetaHash == 0 || params_.parentMetaHash == _parent.metaHash,
            "ParentMetaHashMismatch"
        );
    }

    function _verifyBlocks(
        TaikoData.SlotB memory _slotB,
        uint256 _length
    )
        private
        returns (TaikoData.SlotB memory)
    {
        return _slotB;
    }

    function _checkProposer(address _customProposer) private view returns (address) {
        if (_customProposer == address(0)) return msg.sender;

        address preconfTaskManager = resolve(LibStrings.B_PRECONF_TASK_MANAGER, true);
        require(preconfTaskManager != address(0), "CustomProposerNotAllowed");
        require(preconfTaskManager == msg.sender, "MsgSenderNotPreconfTaskManager");
        return _customProposer;
    }

    function _debitBond(address _user, uint256 _amount) internal {
        if (_amount == 0) return;

        uint256 balance = state.bondBalance[_user];
        if (balance >= _amount) {
            unchecked {
                state.bondBalance[_user] = balance - _amount;
            }
        } else {
            // Note that the following function call will revert if bond asset is Ether.
            _handleDeposit(_user, _amount);
        }
        emit TaikoEvents.BondDebited(_user, 0, _amount);
    }

    function _creditBond(address _user, uint256 _amount) internal {
        if (_amount == 0) return;
        unchecked {
            state.bondBalance[_user] += _amount;
        }
        emit TaikoEvents.BondCredited(_user, 0, _amount);
    }

    function _handleDeposit(address _user, uint256 _amount) private {
        address bondToken = _bondToken();

        if (bondToken != address(0)) {
            require(msg.value == 0, "InvalidMsgValue");
            IERC20(bondToken).transferFrom(_user, address(this), _amount);
        } else {
            require(msg.value == _amount, "EtherNotPaidAsBond");
        }
        emit TaikoEvents.BondDeposited(_user, _amount);
    }

    function _bondToken() private view returns (address) {
        return resolve(LibStrings.B_BOND_TOKEN, true);
    }

    function _getTransitionId(
        TaikoData.BlockV3 storage _blk,
        uint256 _slot,
        bytes32 _parentHash
    )
        internal
        view
        returns (uint24 tid_)
    {
        if (state.transitions[_slot][1].key == _parentHash) {
            tid_ = 1;
            require(tid_ < _blk.nextTransitionId, "UnexpectedLargeTid");
        } else {
            tid_ = state.transitionIds[_blk.blockId][_parentHash];
            require(tid_ == 0 || tid_ < _blk.nextTransitionId, "UnexpectedLargeTid");
        }
    }

    function _isSyncBlock(
        uint256 _stateRootSyncInternal,
        uint256 _blockId
    )
        internal
        pure
        returns (bool)
    {
        if (_stateRootSyncInternal <= 1) return true;
        unchecked {
            // We could use `_blockId % _stateRootSyncInternal == 0`, but this will break many unit
            // tests as in most of these tests, we test block#1, so by setting
            // config._stateRootSyncInternal = 2, we can keep the tests unchanged.
            return _blockId % _stateRootSyncInternal == _stateRootSyncInternal - 1;
        }
    }
}
