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
contract TaikoL1 is EssentialContract, ITaikoL1 {
    using LibMath for uint256;

    struct TransientParentBlock {
        bytes32 metaHash;
        uint64 anchorBlockId;
        uint64 timestamp;
    }

    struct TransientSyncedBlock {
        uint64 blockId;
        uint24 tid;
        bytes32 stateRoot;
    }

    State public state;

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
        nonReentrant
        returns (BlockMetadataV3[] memory metas_)
    {
        require(_blockParams.length != 0, "NoBlocksToPropose");

        Stats2 memory stats2 = state.stats2;
        require(stats2.paused == false, "ContractPaused");

        ConfigV3 memory config = getConfigV3();
        require(stats2.numBlocks >= config.pacayaForkHeight, "InvalidForkHeight");

        require(
            stats2.numBlocks + _blockParams.length
                <= stats2.lastVerifiedBlockId + config.blockMaxProposals,
            "TooManyBlocks"
        );

        TransientParentBlock memory parent;
        {
            BlockV3 storage parentBlk =
                state.blocks[(stats2.numBlocks - 1) % config.blockRingBufferSize];
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
            BlockParamsV3 memory params =
                _validateBlockParams(_blockParams[i], config.maxAnchorHeightOffset, parent);

            // Initialize metadata to compute a metaHash, which forms a part of the block data to be
            // stored on-chain for future integrity checks. If we choose to persist all data fields
            // in the metadata, it will require additional storage slots.
            metas_[i] = BlockMetadataV3({
                anchorBlockHash: blockhash(params.anchorBlockId),
                difficulty: keccak256(abi.encode("TAIKO_DIFFICULTY", stats2.numBlocks)),
                blobHash: blobhash(params.blobIndex),
                extraData: bytes32(uint256(config.baseFeeConfig.sharingPctg)),
                coinbase: _coinbase,
                blockId: stats2.numBlocks,
                gasLimit: config.blockMaxGasLimit,
                timestamp: params.timestamp,
                anchorBlockId: params.anchorBlockId,
                parentMetaHash: params.parentMetaHash,
                proposer: _proposer,
                livenessBond: config.livenessBond,
                proposedAt: uint64(block.timestamp),
                proposedIn: uint64(block.number),
                blobTxListOffset: params.blobTxListOffset,
                blobTxListLength: params.blobTxListLength,
                blobIndex: params.blobIndex,
                baseFeeConfig: config.baseFeeConfig
            });

            require(metas_[i].blobHash != 0, "BlobNotFound");

            // Use a storage pointer for the block in the ring buffer
            BlockV3 storage blk = state.blocks[stats2.numBlocks % config.blockRingBufferSize];

            bytes32 metaHash = keccak256(abi.encode(metas_[i]));
            // SSTORE
            blk.metaHash = metaHash;

            // SSTORE {{
            blk.blockId = stats2.numBlocks;
            blk.timestamp = params.timestamp;
            blk.anchorBlockId = params.anchorBlockId;
            blk.nextTransitionId = 1;
            blk.verifiedTransitionId = 0;
            // SSTORE }}

            emit BlockProposedV3(metas_[i].blockId, metas_[i]);

            parent.metaHash = metaHash;
            parent.timestamp = params.timestamp;
            parent.anchorBlockId = params.anchorBlockId;

            unchecked {
                stats2.numBlocks += 1;
                stats2.lastProposedIn = uint56(block.number);
            }
        } // end of for-loop

        _debitBond(_proposer, config.livenessBond * _blockParams.length);
        _verifyBlocks(config, stats2, _blockParams.length);
    }

    function proveBlocksV3(
        BlockMetadataV3[] calldata _metas,
        TransitionV3[] calldata _transitions,
        bytes calldata proof
    )
        external
        nonReentrant
    {
        require(_metas.length == _transitions.length, "InvalidParam");

        Stats2 memory stats2 = state.stats2;
        require(stats2.paused == false, "ContractPaused");

        ConfigV3 memory config = getConfigV3();
        require(stats2.numBlocks >= config.pacayaForkHeight, "InvalidForkHeight");

        IVerifier.ContextV3[] memory ctxs = new IVerifier.ContextV3[](_metas.length);
        for (uint256 i; i < _metas.length; ++i) {
            BlockMetadataV3 calldata meta = _metas[i];

            require(meta.blockId >= config.pacayaForkHeight, "InvalidForkHeight");
            require(meta.blockId < stats2.lastVerifiedBlockId, "BlockVerified");
            require(meta.blockId < stats2.numBlocks, "BlockNotProposed");

            TransitionV3 calldata tran = _transitions[i];
            require(tran.parentHash != 0, "InvalidTransitionParentHash");
            require(tran.blockHash != 0, "InvalidTransitionBlockHash");
            require(tran.stateRoot != 0, "InvalidTransitionStateRoot");

            ctxs[i].metaHash = keccak256(abi.encode(meta));
            ctxs[i].difficulty = meta.difficulty;
            ctxs[i].tran = tran;

            uint256 slot = meta.blockId % config.blockRingBufferSize;
            BlockV3 storage blk = state.blocks[slot];
            require(ctxs[i].metaHash == blk.metaHash, "MataMismatch");

            TransitionStateV3 storage ts = state.transitions[slot][1];
            require(ts.parentHash != tran.parentHash, "AlreadyProvenAsFirstTransition");
            require(state.transitionIds[meta.blockId][tran.parentHash] == 0, "AlreadyProven");

            uint24 tid = blk.nextTransitionId++;
            ts = state.transitions[slot][tid];

            // Checks if only the assigned prover is permissioned to prove the block. The assigned
            // prover is granted exclusive permission to prove only the first transition.
            if (tid == 1) {
                if (msg.sender == meta.proposer) {
                    _creditBond(meta.proposer, meta.livenessBond);
                } else {
                    uint256 deadline = uint256(meta.proposedAt).max(stats2.lastUnpausedAt);
                    deadline += config.provingWindow;
                    require(block.timestamp >= deadline, "ProvingWindowNotPassed");
                }
                ts.parentHash = tran.parentHash;
            } else {
                state.transitionIds[meta.blockId][tran.parentHash] = tid;
            }

            ts.blockHash = tran.blockHash;

            if (_isSyncBlock(meta.blockId, config.stateRootSyncInternal)) {
                ts.stateRoot = tran.stateRoot;
            }

            emit BlockProvedV3(meta.blockId, tran);
        }

        if (_metas.length != 0) {
            IVerifier(resolve(LibStrings.B_PROOF_VERIFIER, false)).verifyProofV3(ctxs, proof);
        }

        _verifyBlocks(config, stats2, _metas.length);
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

    function getStats1() external view returns (uint64 lastSyncedBlockId_, uint64 lastSyncedAt_) {
        Stats1 memory stats1 = state.stats1;
        lastSyncedBlockId_ = stats1.lastSyncedBlockId;
        lastSyncedAt_ = stats1.lastSyncedAt;
    }

    function getStats2()
        external
        view
        returns (
            uint64 numBlocks_,
            uint64 lastVerifiedBlockId_,
            bool paused_,
            uint56 lastProposedIn_,
            uint64 lastUnpausedAt_
        )
    {
        Stats2 memory stats2 = state.stats2;
        numBlocks_ = stats2.numBlocks;
        lastVerifiedBlockId_ = stats2.lastVerifiedBlockId;
        paused_ = stats2.paused;
        lastProposedIn_ = stats2.lastProposedIn;
        lastUnpausedAt_ = stats2.lastUnpausedAt;
    }

    function getLastVerifiedTransitionV3()
        external
        view
        returns (uint64 blockId_, TransitionV3 memory tran_)
    {
        blockId_ = state.stats2.lastVerifiedBlockId;
        tran_ = getBlockVerifyingTransition(blockId_);
    }

    function getLastSyncedTransitionV3()
        external
        view
        returns (uint64 blockId_, TransitionV3 memory tran_)
    {
        blockId_ = state.stats1.lastSyncedBlockId;
        tran_ = getBlockVerifyingTransition(blockId_);
    }

    function bondBalanceOf(address _user) external view returns (uint256) {
        return state.bondBalance[_user];
    }

    function getBlockV3(uint64 _blockId) external view returns (BlockV3 memory blk_) {
        ConfigV3 memory config = getConfigV3();
        require(_blockId >= config.pacayaForkHeight, "InvalidForkHeight");

        blk_ = state.blocks[_blockId % config.blockRingBufferSize];
        require(blk_.blockId == _blockId, "BlockNotFound");
    }

    // Public functions
    // ------------------------------------------------------------------------------------------

    function paused() public view override returns (bool) {
        return state.stats2.paused;
    }

    function bondToken() public view returns (address) {
        return resolve(LibStrings.B_BOND_TOKEN, true);
    }

    function getBlockVerifyingTransition(uint64 _blockId)
        public
        view
        returns (TransitionV3 memory tran_)
    {
        ConfigV3 memory config = getConfigV3();

        uint64 slot = _blockId % config.blockRingBufferSize;
        BlockV3 storage blk = state.blocks[slot];
        require(blk.blockId == _blockId, "BlockNotFound");

        if (blk.verifiedTransitionId != 0) {
            TransitionStateV3 storage ts = state.transitions[slot][blk.verifiedTransitionId];
            tran_.blockHash = ts.blockHash;
            tran_.stateRoot = ts.stateRoot;
        }
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
        state.stats2.numBlocks = 1;

        // Init the genesis block
        BlockV3 storage blk = state.blocks[0];
        blk.nextTransitionId = 2;
        blk.timestamp = uint64(block.timestamp);
        blk.anchorBlockId = uint64(block.number);
        blk.verifiedTransitionId = 1;
        blk.metaHash = bytes32(uint256(1)); // Give the genesis metahash a non-zero value.

        // Init the first state transition
        TransitionStateV3 storage ts = state.transitions[0][1];
        ts.blockHash = _genesisBlockHash;

        emit BlockVerifiedV3({ blockId: 0, blockHash: _genesisBlockHash });
    }

    function _unpause() internal override {
        state.stats2.lastUnpausedAt = uint64(block.timestamp);
        state.stats2.paused = false;
    }

    function _pause() internal override {
        state.stats2.paused = true;
    }

    // Private functions
    // ------------------------------------------------------------------------------------------

    function _verifyBlocks(
        ConfigV3 memory _config,
        Stats2 memory _stats2,
        uint256 _length
    )
        private
    {
        uint64 blockId = _stats2.lastVerifiedBlockId;
        uint256 slot = blockId % _config.blockRingBufferSize;
        BlockV3 storage blk = state.blocks[slot];
        uint24 verifiedTransitionId = blk.verifiedTransitionId;
        bytes32 verifiedBlockHash = state.transitions[slot][verifiedTransitionId].blockHash;

        TransientSyncedBlock memory synced;

        uint256 stopBlockId = (_config.maxBlocksToVerify * _length + _stats2.lastVerifiedBlockId)
            .min(_stats2.numBlocks);

        for (++blockId; blockId <= stopBlockId; ++blockId) {
            slot = blockId % _config.blockRingBufferSize;
            blk = state.blocks[slot];
            // TODO(daniel): get Tid;
            uint24 tid;

            if (tid == 0) break;
            TransitionStateV3 storage ts = state.transitions[slot][tid];

            verifiedBlockHash = ts.blockHash;
            verifiedTransitionId = tid;

            if (_isSyncBlock(blockId, _config.stateRootSyncInternal)) {
                synced.blockId = blockId;
                synced.tid = tid;
                synced.stateRoot = ts.stateRoot;
            }
        }

        unchecked {
            --blockId;
        }

        if (_stats2.lastVerifiedBlockId != blockId) {
            _stats2.lastVerifiedBlockId = blockId;

            blk = state.blocks[_stats2.lastVerifiedBlockId % _config.blockRingBufferSize];
            blk.verifiedTransitionId = verifiedTransitionId;
            emit BlockVerifiedV3(_stats2.lastVerifiedBlockId, verifiedBlockHash);
        }

        if (synced.blockId != 0) {
            Stats1 memory stats1 = state.stats1;
            stats1.lastSyncedBlockId = synced.blockId;
            stats1.lastSyncedAt = uint64(block.timestamp);
            state.stats1 = stats1;

            emit Stats1Updated(stats1);

            // We write the synced block's verifiedTransitionId to storage
            if (synced.blockId != _stats2.lastVerifiedBlockId) {
                blk = state.blocks[synced.blockId % _config.blockRingBufferSize];
                blk.verifiedTransitionId = synced.tid;
            }

            // Ask signal service to write cross chain signal
            ISignalService(resolve(LibStrings.B_SIGNAL_SERVICE, false)).syncChainData(
                _config.chainId, LibStrings.H_STATE_ROOT, synced.blockId, synced.stateRoot
            );
        }

        state.stats2 = _stats2;
        emit Stats2Updated(_stats2);
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
        uint64 _maxAnchorHeightOffset,
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
            require(params_.anchorBlockId + _maxAnchorHeightOffset >= block.number, "AnchorBlockId");
            require(params_.anchorBlockId < block.number, "AnchorBlockId");
            require(params_.anchorBlockId >= _parent.anchorBlockId, "AnchorBlockId");
        }

        if (params_.timestamp == 0) {
            params_.timestamp = uint64(block.timestamp);
        } else {
            // Verify the provided timestamp to anchor. Note that params_.anchorBlockId
            // and params_.timestamp may not correspond to the same L1 block.
            require(
                params_.timestamp + _maxAnchorHeightOffset * LibNetwork.ETHEREUM_BLOCK_TIME
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

    function _isSyncBlock(
        uint64 _blockId,
        uint256 _stateRootSyncInternal
    )
        private
        pure
        returns (bool)
    {
        return _stateRootSyncInternal == 0 || _blockId % _stateRootSyncInternal == 0;
    }
}
