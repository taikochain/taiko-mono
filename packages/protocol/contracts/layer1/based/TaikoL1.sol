// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "src/shared/common/EssentialContract.sol";
import "src/shared/libs/LibAddress.sol";
import "src/shared/libs/LibMath.sol";
import "src/shared/libs/LibNetwork.sol";
import "src/shared/libs/LibStrings.sol";
import "src/shared/signal/ISignalService.sol";
import "src/layer1/verifiers/IVerifier.sol";
import "./ITaikoL1.sol";

/// @title TaikoL1
/// @notice This contract serves as the "base layer contract" of the Taiko protocol, providing
/// functionalities for proposing, proving, and verifying blocks. The term "base layer contract"
/// means that although this is usually deployed on L1, it can also be deployed on L2s to create
/// L3s. The contract also handles the deposit and withdrawal of Taiko tokens and Ether.
/// Additionally, this contract doesn't hold any Ether. Ether deposited to L2 are held by the Bridge
/// contract.
/// @dev Labeled in AddressResolver as "taiko"
/// @custom:security-contact security@taiko.xyz
contract TaikoL1 is EssentialContract, ITaikoL1, IBondManager {
    using LibMath for uint256;

    struct TransientParentBlock {
        bytes32 metaHash;
        uint64 anchorBlockId;
        uint64 timestamp;
    }

    struct TransientSyncedBlock {
        uint64 blockId;
        uint slot;
        uint24 tid;
        bytes32 stateRoot;
    }

    State public state;
    uint256[50] private __gap;

    // External functions
    // ------------------------------------------------------------------------------------------

    function init(
        address _owner,
        address _rollupResolver,
        bytes32 _genesisBlockHash
    )
        external
        initializer
    {
        __TaikoL1_init(_owner, _rollupResolver, _genesisBlockHash);
    }

    function proposeBlocksV3(
        address _proposer,
        address _coinbase,
        bytes[] calldata _blockParams
    )
        external
        whenNotPaused
        nonReentrant
        returns (BlockMetadataV3[] memory metas_)
    {
        ConfigV3 memory config = getConfigV3();
        SlotB memory slotB = state.slotB;
        require(_blockParams.length != 0, "NoBlocksToPropose");
        require(slotB.numBlocks >= config.pacayaForkHeight, "InvalidForkHeight");
        require(
            slotB.numBlocks + _blockParams.length
                <= slotB.lastVerifiedBlockId + config.blockMaxProposals,
            "TooManyBlocks"
        );

        TransientParentBlock memory parent;
        {
            BlockV3 storage parentBlk =
                state.blocks[(slotB.numBlocks - 1) % config.blockRingBufferSize];
            parent = TransientParentBlock({
                metaHash: parentBlk.metaHash,
                timestamp: parentBlk.timestamp,
                anchorBlockId: parentBlk.anchorBlockId
            });
        }

        _proposer = _checkProposer(_proposer);
        if (_coinbase == address(0)) {
            _coinbase = _proposer;
        }
        metas_ = new BlockMetadataV3[](_blockParams.length);

        for (uint256 i; i < _blockParams.length; ++i) {
            BlockParamsV3 memory params = _validateBlockParams(_blockParams[i], config, parent);

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

        slotB = _verifyBlocks(config, slotB, _blockParams.length);
        emit StateVariablesUpdated(slotB);

        // SSTORE #4
        state.slotB = slotB;
    }

    function proveBlocksV3(
        BlockMetadataV3[] calldata _metas,
        TransitionV3[] calldata _transitions,
        bytes calldata proof
    )
        external
        whenNotPaused
        nonReentrant
    {
        require(_metas.length == _transitions.length, "InvalidParam");
        ConfigV3 memory config = getConfigV3();
        SlotB memory slotB = state.slotB;

        IVerifier.ContextV3[] memory ctxs = new IVerifier.ContextV3[](_metas.length);

        for (uint256 i; i < _metas.length; ++i) {
            ctxs[i] = _proveBlock(config, slotB, _metas[i], _transitions[i]);
        }

        IVerifier(resolve("TODO", false)).verifyProofV3(ctxs, proof);

        slotB = _verifyBlocks(config, slotB, _metas.length);
        // SSTORE #4
        emit StateVariablesUpdated(slotB);
        state.slotB = slotB;
    }

    function depositBond(uint256 _amount) external payable whenNotPaused {
        state.bondBalance[msg.sender] += _amount;
        _handleDeposit(msg.sender, _amount);
    }

    function withdrawBond(uint256 _amount) external whenNotPaused {
        emit BondWithdrawn(msg.sender, _amount);

        state.bondBalance[msg.sender] -= _amount;

        address bond = bondToken();
        if (bond != address(0)) {
            IERC20(bond).transfer(msg.sender, _amount);
        } else {
            LibAddress.sendEtherAndVerify(msg.sender, _amount);
        }
    }

    function lastProposedIn() external view returns (uint56) {
        return state.slotB.lastProposedIn;
    }

    function getLastVerifiedBlockV3()
        external
        view
        returns (uint64 blockId_, bytes32 blockHash_, bytes32 stateRoot_)
    {
        blockId_ = state.slotB.lastVerifiedBlockId;
        (blockHash_, stateRoot_) = _getBlockInfo(blockId_);
    }

    function getLastSyncedBlockV3()
        external
        view
        returns (uint64 blockId_, bytes32 blockHash_, bytes32 stateRoot_)
    {
        blockId_ = state.slotA.lastSyncedBlockId;
        (blockHash_, stateRoot_) = _getBlockInfo(blockId_);
    }

    function bondBalanceOf(address _user) external view returns (uint256) {
        return state.bondBalance[_user];
    }

    function getBlockV3(uint64 _blockId) external view returns (BlockV3 memory blk_) {
        ConfigV3 memory config = getConfigV3();
        require(_blockId >= config.pacayaForkHeight, "InvalidForkHeight");
        (blk_,) = _getBlock(config, _blockId);
    }

    // Public functions
    // ------------------------------------------------------------------------------------------

    function unpause() public override whenPaused {
        _authorizePause(msg.sender, false);
        __paused = _FALSE;
        state.slotB.lastUnpausedAt = uint64(block.timestamp);
        emit Unpaused(msg.sender);
    }

    function bondToken() public view returns (address) {
        return resolve(LibStrings.B_BOND_TOKEN, true);
    }

    function getConfigV3() public view virtual returns (ConfigV3 memory) {
        return ConfigV3({
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

    // Internal functions
    // ------------------------------------------------------------------------------------------

    function __TaikoL1_init(
        address _owner,
        address _rollupResolver,
        bytes32 _genesisBlockHash
    )
        internal
    {
        __Essential_init(_owner, _rollupResolver);

        require(_genesisBlockHash != 0, "InvalidGenesisBlockHash");
        // Init state
        state.slotA.genesisHeight = uint64(block.number);
        state.slotA.genesisTimestamp = uint64(block.timestamp);
        state.slotB.numBlocks = 1;

        // Init the genesis block
        BlockV3 storage blk = state.blocks[0];
        blk.nextTransitionId = 2;
        blk.timestamp = uint64(block.timestamp);
        blk.anchorBlockId = uint64(block.number);
        blk.verifiedTransitionId = 1;
        blk.metaHash = bytes32(uint256(1)); // Give the genesis metahash a non-zero value.

        // Init the first state transition
        TransitionV3 storage ts = state.transitions[0][1];
        ts.blockHash = _genesisBlockHash;

        emit BlockVerifiedV3({ blockId: 0, blockHash: _genesisBlockHash });
    }

    // Private functions
    // ------------------------------------------------------------------------------------------

    function _proposeBlock(
        ConfigV3 memory _config,
        SlotB memory _slotB,
        BlockParamsV3 memory _params,
        address _proposer,
        address _coinbase
    )
        internal
        returns (BlockMetadataV3 memory meta_, bytes32 metaHash_)
    {
        // Initialize metadata to compute a metaHash, which forms a part of the block data to be
        // stored on-chain for future integrity checks. If we choose to persist all data fields
        // in
        // the metadata, it will require additional storage slots.
        meta_ = BlockMetadataV3({
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
        BlockV3 storage blk = state.blocks[_slotB.numBlocks % _config.blockRingBufferSize];

        // Store each field of the block separately
        // SSTORE #1
        metaHash_ = keccak256(abi.encode(meta_));
        blk.metaHash = metaHash_;

        // SSTORE #2 {{
        blk.blockId = _slotB.numBlocks;
        blk.timestamp = _params.timestamp;
        blk.anchorBlockId = _params.anchorBlockId;
        blk.nextTransitionId = 1;
        blk.verifiedTransitionId = 0;
        // SSTORE #2 }}

        emit BlockProposedV3(_slotB.numBlocks, meta_);
    }

    function _proveBlock(
        ConfigV3 memory _config,
        SlotB memory _slotB,
        BlockMetadataV3 calldata _meta,
        TransitionV3 calldata _tran
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
        BlockV3 storage blk = state.blocks[slot];
        require(ctx_.metaHash == blk.metaHash, "MataMismatch");

        TransitionV3 storage ts = state.transitions[slot][1];
        require(ts.parentHash != _tran.parentHash, "AlreadyProvenAsFirstTransition");
        require(state.transitionIds[_meta.id][_tran.parentHash] == 0, "AlreadyProven");

        uint24 tid = blk.nextTransitionId++;
        ts = state.transitions[slot][tid];

        // Checks if only the assigned prover is permissioned to prove the block. The assigned
        // prover is granted exclusive permission to prove only the first transition.
        if (tid == 1) {
            if (msg.sender == _meta.proposer) {
                _creditBond(_meta.proposer, _meta.livenessBond);
            } else {
                uint256 deadline = uint256(_meta.proposedAt).max(_slotB.lastUnpausedAt);
                deadline += _config.provingWindow;
                require(block.timestamp >= deadline, "ProvingWindowNotPassed");
            }
            ts.parentHash = _tran.parentHash;
        } else {
            state.transitionIds[_meta.id][_tran.parentHash] = tid;
        }

        ts.blockHash = _tran.blockHash;

        if (_isSyncBlock(_config.stateRootSyncInternal, _meta.id)) {
            ts.stateRoot = _tran.stateRoot;
        }

        emit BlockProvedV3(_meta.id, _tran);
    }

    function _verifyBlocks(
        ConfigV3 memory _config,
        SlotB memory _slotB,
        uint256 _length
    )
        private
        returns (SlotB memory)
    {
        uint64 blockId = _slotB.lastVerifiedBlockId;
        uint256 slot = blockId % _config.blockRingBufferSize;
        BlockV3 storage blk = state.blocks[slot];
        uint24 verifiedTransitionId = blk.verifiedTransitionId;
        bytes32 verifiedBlockHash = state.transitions[slot][verifiedTransitionId].blockHash;
        uint64 count;

        TransientSyncedBlock memory synced;
        while (++blockId < _slotB.numBlocks && count < _config.maxBlocksToVerify * _length) {
            slot = blockId % _config.blockRingBufferSize;
            blk = state.blocks[slot];
            // get Tid;
            uint24 tid;

            if (tid == 0) break;
            TransitionV3 storage ts = state.transitions[slot][tid];

            verifiedBlockHash = ts.blockHash;
            verifiedTransitionId = tid;

            if (_isSyncBlock(_config.stateRootSyncInternal, blockId)) {
                synced.blockId = blockId;
                synced.slot = slot;
                synced.tid = tid;
                synced.stateRoot = ts.stateRoot;
            }
            unchecked {
                ++blockId;
                ++count;
            }
        }

        if (count == 0) return _slotB;

        _slotB.lastVerifiedBlockId += count;

        slot = _slotB.lastVerifiedBlockId % _config.blockRingBufferSize;
        blk = state.blocks[slot];
        blk.verifiedTransitionId = verifiedTransitionId;

        emit BlockVerifiedV3(_slotB.lastVerifiedBlockId, verifiedBlockHash);

        if (synced.blockId == 0) return _slotB;

        state.slotA.lastSyncedBlockId = synced.blockId;
        state.slotA.lastSyncedAt = uint64(block.timestamp);

        // We write the synced block's verifiedTransitionId to storage
        if (synced.blockId != _slotB.lastVerifiedBlockId) {
            state.blocks[synced.slot].verifiedTransitionId = synced.tid;
        }

        // Ask signal service to write cross chain signal
        ISignalService(resolve(LibStrings.B_SIGNAL_SERVICE, false)).syncChainData(
            _config.chainId, LibStrings.H_STATE_ROOT, synced.blockId, synced.stateRoot
        );

        emit BlockSyncedV3(synced.blockId, synced.stateRoot);
        return _slotB;
    }

    function _debitBond(address _user, uint256 _amount) private {
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
        emit BondDebited(_user, 0, _amount);
    }

    function _creditBond(address _user, uint256 _amount) private {
        if (_amount == 0) return;
        unchecked {
            state.bondBalance[_user] += _amount;
        }
        emit BondCredited(_user, 0, _amount);
    }

    function _handleDeposit(address _user, uint256 _amount) private {
        address bond = bondToken();

        if (bond != address(0)) {
            require(msg.value == 0, "InvalidMsgValue");
            IERC20(bond).transferFrom(_user, address(this), _amount);
        } else {
            require(msg.value == _amount, "EtherNotPaidAsBond");
        }
        emit BondDeposited(_user, _amount);
    }

    function _validateBlockParams(
        bytes calldata _blockParam,
        ConfigV3 memory _config,
        TransientParentBlock memory _parent
    )
        private
        view
        returns (BlockParamsV3 memory params_)
    {
        if (_blockParam.length != 0) {
            params_ = abi.decode(_blockParam, (BlockParamsV3));
        }

        if (params_.anchorBlockId == 0) {
            params_.anchorBlockId = uint64(block.number - 1);
        } else {
            require(
                params_.anchorBlockId + _config.maxAnchorHeightOffset >= block.number,
                "AnchorBlockId"
            );
            require(params_.anchorBlockId < block.number, "AnchorBlockId");
            require(params_.anchorBlockId >= _parent.anchorBlockId, "AnchorBlockId");
        }

        if (params_.timestamp == 0) {
            params_.timestamp = uint64(block.timestamp);
        } else {
            // Verify the provided timestamp to anchor. Note that params_.anchorBlockId
            // and params_.timestamp may not correspond to the same L1 block.
            require(
                params_.timestamp + _config.maxAnchorHeightOffset * LibNetwork.ETHEREUM_BLOCK_TIME
                    >= block.timestamp,
                "InvalidTimestamp"
            );
            require(params_.timestamp <= block.timestamp, "InvalidTimestamp");
            require(params_.timestamp >= _parent.timestamp, "InvalidTimestamp");
        }

        // Check if parent block has the right meta hash. This is to allow the proposer to
        // make sure the block builds on the expected latest chain state.
        require(
            params_.parentMetaHash == 0 || params_.parentMetaHash == _parent.metaHash,
            "ParentMetaHashMismatch"
        );
    }

    function _checkProposer(address _customProposer) private view returns (address) {
        if (_customProposer == address(0)) return msg.sender;

        address preconfTaskManager = resolve(LibStrings.B_PRECONF_TASK_MANAGER, true);
        require(preconfTaskManager != address(0), "CustomProposerNotAllowed");
        require(preconfTaskManager == msg.sender, "MsgSenderNotPreconfTaskManager");
        return _customProposer;
    }

    function _getBlockInfo(uint64 _blockId)
        private
        view
        returns (bytes32 blockHash_, bytes32 stateRoot_)
    {
        ConfigV3 memory config = getConfigV3();
        (BlockV3 storage blk, uint64 slot) = _getBlock(config, _blockId);

        if (blk.verifiedTransitionId != 0) {
            TransitionV3 storage ts = state.transitions[slot][blk.verifiedTransitionId];
            blockHash_ = ts.blockHash;
            stateRoot_ = ts.stateRoot;
        }
    }

    function _getBlock(
        ConfigV3 memory _config,
        uint64 _blockId
    )
        private
        view
        returns (BlockV3 storage blk_, uint64 slot_)
    {
        slot_ = _blockId % _config.blockRingBufferSize;
        blk_ = state.blocks[slot_];
        require(blk_.blockId == _blockId, "BlockNotFound");
    }

    function _isSyncBlock(
        uint256 _stateRootSyncInternal,
        uint256 _blockId
    )
        private
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
