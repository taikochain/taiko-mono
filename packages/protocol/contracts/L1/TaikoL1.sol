// SPDX-License-Identifier: MIT
//
// ╭━━━━╮╱╱╭╮╱╱╱╱╱╭╮╱╱╱╱╱╭╮
// ┃╭╮╭╮┃╱╱┃┃╱╱╱╱╱┃┃╱╱╱╱╱┃┃
// ╰╯┃┃┣┻━┳┫┃╭┳━━╮┃┃╱╱╭━━┫╰━┳━━╮
// ╱╱┃┃┃╭╮┣┫╰╯┫╭╮┃┃┃╱╭┫╭╮┃╭╮┃━━┫
// ╱╱┃┃┃╭╮┃┃╭╮┫╰╯┃┃╰━╯┃╭╮┃╰╯┣━━┃
// ╱╱╰╯╰╯╰┻┻╯╰┻━━╯╰━━━┻╯╰┻━━┻━━╯
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";

import "../common/EssentialContract.sol";
import "../common/ConfigManager.sol";
import "../common/IMintableERC20.sol";
import "../libs/LibBlockHeader.sol";
import "../libs/LibConstants.sol";
import "../libs/LibMerkleProof.sol";
import "../libs/LibStorageProof.sol";
import "../libs/LibTxList.sol";
import "../libs/LibZKP.sol";

struct BlockContext {
    uint256 id;
    uint256 anchorHeight;
    bytes32 anchorHash;
    address beneficiary;
    uint64 gasLimit;
    uint64 proposedAt;
    bytes32 txListHash;
    bytes32 mixHash;
    bytes extraData;
    uint256 proverFee;
}

struct Evidence {
    address prover;
    uint256 proverFee;
    uint64 proposedAt;
    uint64 provenAt;
    bytes32 blockHash;
}

// all stat time units are nanosecond
struct Stats {
    uint64 avgPendingSize;
    uint64 avgProvingDelay;
    uint64 avgFinalizationDelay;
}

/// @dev We have the following design assumptions:
/// - Assumption 1: the `difficulty` and `nonce` fields in Taiko block header
//                  will always be zeros, and this will be checked by zkEVM.
///
/// - Assumption 2: Taiko L2 allows block.timestamp >= parent.timestamp.
///
/// - Assumption 3: mixHash will be used by Taiko L2 for randomness, see:
///                 https://blog.ethereum.org/2021/11/29/how-the-merge-impacts-app-layer
///
/// - Assumption 4: Taiko zkEVM will check `sum(tx_i.gasLimit) <= header.gasLimit`
///                 and `header.gasLimit <= MAX_TAIKO_BLOCK_GAS_LIMIT`
///
/// - Assumption 5: Prover can use its address as public input to generate unique
///                 ZKP that's only valid if he transacts with this address. This is
///                 critical to ensure the ZKP will not be stolen by others
///
/// This contract shall be deployed as the initial implementation of a
/// https://docs.openzeppelin.com/contracts/4.x/api/proxy#UpgradeableBeacon contract,
/// then a https://docs.openzeppelin.com/contracts/4.x/api/proxy#BeaconProxy contract
/// shall be deployed infront of it.
contract TaikoL1 is EssentialContract {
    using SafeCastUpgradeable for uint256;
    using LibBlockHeader for BlockHeader;
    using LibTxList for bytes;
    /**********************
     * Constants   *
     **********************/
    uint256 public constant MAX_ANCHOR_HEIGHT_DIFF = 128;
    uint256 public constant MAX_PENDING_BLOCKS = 2048;
    uint256 public constant MAX_THROW_AWAY_PARENT_DIFF = 1024;
    uint256 public constant MAX_FINALIZATION_PER_TX = 5;
    uint256 public constant DAO_REWARD_RATIO = 100; // 100%
    string public constant ZKP_VKEY = "TAIKO_ZKP_VKEY";

    bytes32 private constant JUMP_MARKER = bytes32(uint256(1));
    uint256 private constant STAT_AVERAGING_FACTOR = 2048;
    uint64 private constant NANO_PER_SECOND = 1E9;
    uint64 private constant UTILIZATION_FEE_RATIO = 500; // 5x

    /**********************
     * State Variables    *
     **********************/

    // Finalized taiko block headers
    mapping(uint256 => bytes32) public finalizedBlocks;

    // block id => block context hash
    mapping(uint256 => bytes32) public pendingBlocks;

    mapping(uint256 => mapping(bytes32 => Evidence)) public evidences;

    uint64 public genesisHeight;
    uint64 public lastFinalizedHeight;
    uint64 public lastFinalizedId;
    uint64 public nextPendingId;

    uint256 public proverFeeToDAO;

    uint256 public proverBaseFee;
    uint256 public proverGasPrice; // TODO: auto-adjustable

    Stats private _stats; // 1 slot

    uint256[42] private __gap;

    /**********************
     * Events             *
     **********************/

    event BlockProposed(uint256 indexed id, BlockContext context);
    event BlockProven(
        uint256 indexed id,
        bytes32 parentHash,
        Evidence evidence
    );
    event BlockProvenInvalid(uint256 indexed id);
    event BlockFinalized(
        uint256 indexed id,
        uint256 indexed height,
        Evidence evidence,
        uint256 blockReward,
        uint256 daoReward
    );

    /**********************
     * Modifiers          *
     **********************/

    modifier whenBlockIsPending(BlockContext calldata context) {
        _checkContextPending(context);
        _;
        finalizeBlocks();
    }

    /**********************
     * External Functions *
     **********************/

    function init(
        address _addressManager,
        bytes32 _genesisBlockHash,
        uint256 _proverBaseFee,
        uint256 _proverGasPrice,
        uint256 amountMintToDAO,
        uint256 amountMintToTeam
    ) external initializer {
        EssentialContract._init(_addressManager);

        proverBaseFee = _proverBaseFee;
        proverGasPrice = _proverGasPrice;

        finalizedBlocks[0] = _genesisBlockHash;
        nextPendingId = 1;

        genesisHeight = block.number.toUint64();

        Evidence memory evidence = Evidence({
            prover: address(0),
            proverFee: 0,
            proposedAt: 0,
            provenAt: 0,
            blockHash: _genesisBlockHash
        });

        if (amountMintToDAO != 0) {
            require(resolve("dao_vault") != address(0), "invalid dao vault");
            IMintableERC20(resolve("proto_token")).mint(
                resolve("dao_vault"),
                amountMintToDAO
            );
        }

        if (amountMintToTeam != 0) {
            require(resolve("team_vault") != address(0), "invalid team vault");
            IMintableERC20(resolve("proto_token")).mint(
                resolve("team_vault"),
                amountMintToTeam
            );
        }

        emit BlockFinalized(0, 0, evidence, 0, 0);
    }

    /// @notice Propose a Taiko L2 block.
    /// @param context The context that the actual L2 block header must satisfy.
    ///        Note the following fields in the provided context object must
    ///        be zeros, and their actual values will be provisioned by Ethereum.
    ///        - txListHash
    ///        - mixHash
    ///        - timestamp
    /// @param txList A list of transactions in this block, encoded with RLP.
    ///
    function proposeBlock(BlockContext memory context, bytes calldata txList)
        external
        payable
        nonReentrant
    {
        // Try to finalize blocks first to make room
        finalizeBlocks();

        require(txList.length > 0, "empty txList");
        require(
            nextPendingId <= lastFinalizedId + MAX_PENDING_BLOCKS,
            "too many pending blocks"
        );
        validateContext(context);

        _stats.avgPendingSize = _calcAverage(
            _stats.avgPendingSize,
            nextPendingId - lastFinalizedId - 1
        );

        context.id = nextPendingId;
        context.proposedAt = block.timestamp.toUint64();
        context.txListHash = txList.hashTxList();

        // if multiple L2 blocks included in the same L1 block,
        // their block.mixHash fields for randomness will be the same.
        context.mixHash = bytes32(block.difficulty);

        // Check fees
        context.proverFee = context.gasLimit * proverGasPrice + proverBaseFee;

        _chargeProposerFee(context.proverFee);

        _savePendingBlock(nextPendingId, _hashContext(context));
        emit BlockProposed(nextPendingId++, context);
    }

    // TODO: how to verify the zkp is associated with msg.sender?
    function proveBlock(
        bool anchored,
        BlockHeader calldata header,
        BlockContext calldata context,
        bytes[2] calldata proofs
    ) external nonReentrant whenBlockIsPending(context) {
        _validateHeaderForContext(header, context);
        bytes32 blockHash = header.hashBlockHeader();

        LibZKP.verify(
            ConfigManager(resolve("config_manager")).get(ZKP_VKEY),
            header.parentHash,
            blockHash,
            context.txListHash,
            proofs[0]
        );

        (bytes32 proofKey, bytes32 proofVal) = LibStorageProof
            .computeAnchorProofKV(
                header.height,
                context.anchorHeight,
                context.anchorHash
            );

        if (!anchored) {
            proofVal = 0x0;
        }

        LibMerkleProof.verify(
            header.stateRoot,
            resolve("taiko_l2"),
            proofKey,
            proofVal,
            proofs[1]
        );

        Evidence memory evidence = Evidence({
            prover: msg.sender,
            proverFee: context.proverFee,
            proposedAt: context.proposedAt,
            provenAt: block.timestamp.toUint64(),
            blockHash: blockHash
        });

        evidences[context.id][header.parentHash] = evidence;

        emit BlockProven(context.id, header.parentHash, evidence);
    }

    // TODO: how to verify the zkp is associated with msg.sender?
    function proveBlockInvalid(
        bytes32 throwAwayTxListHash, // hash of a txList that contains a verifyBlockInvalid tx on L2.
        BlockHeader calldata throwAwayHeader,
        BlockContext calldata context,
        bytes[2] calldata proofs
    ) external nonReentrant whenBlockIsPending(context) {
        require(
            throwAwayHeader.isPartiallyValidForTaiko(),
            "throwAwayHeader invalid"
        );

        require(
            lastFinalizedHeight <=
                throwAwayHeader.height + MAX_THROW_AWAY_PARENT_DIFF,
            "parent too old"
        );
        require(
            throwAwayHeader.parentHash ==
                finalizedBlocks[throwAwayHeader.height - 1],
            "parent mismatch"
        );

        LibZKP.verify(
            ConfigManager(resolve("config_manager")).get(ZKP_VKEY),
            throwAwayHeader.parentHash,
            throwAwayHeader.hashBlockHeader(),
            throwAwayTxListHash,
            proofs[0]
        );

        (bytes32 key, bytes32 value) = LibStorageProof
            .computeInvalidTxListProofKV(context.txListHash);

        LibMerkleProof.verify(
            throwAwayHeader.stateRoot,
            resolve("taiko_l2"),
            key,
            value,
            proofs[1]
        );

        _invalidateBlock(context, false);
    }

    function verifyBlockInvalid(
        BlockContext calldata context,
        bytes calldata txList
    ) external nonReentrant whenBlockIsPending(context) {
        require(txList.hashTxList() == context.txListHash, "txList mismatch");
        require(!LibTxListValidator.isTxListValid(txList), "txList decoded");

        _invalidateBlock(context, true);
    }

    /**********************
     * Public Functions   *
     **********************/

    function finalizeBlocks() public {
        uint64 id = lastFinalizedId + 1;
        uint256 processed = 0;
        while (id < nextPendingId && processed <= MAX_FINALIZATION_PER_TX) {
            Evidence storage evidence = evidences[id][
                finalizedBlocks[lastFinalizedHeight]
            ];

            if (evidence.prover != address(0)) {
                finalizedBlocks[++lastFinalizedHeight] = evidence.blockHash;
                _finalizeBlock(id, lastFinalizedHeight, evidence);
            } else if (evidences[id][JUMP_MARKER].prover != address(0)) {
                _finalizeBlock(
                    id,
                    lastFinalizedHeight,
                    evidences[id][JUMP_MARKER]
                );
            } else {
                break;
            }

            lastFinalizedId += 1;
            id += 1;
            processed += 1;
        }
    }

    function validateContext(BlockContext memory context) public view {
        require(
            context.id == 0 &&
                context.txListHash == 0x0 &&
                context.mixHash == 0x0 &&
                context.proposedAt == 0 &&
                context.proverFee == 0,
            "nonzero placeholder fields"
        );

        require(
            block.number <= context.anchorHeight + MAX_ANCHOR_HEIGHT_DIFF &&
                context.anchorHash == blockhash(context.anchorHeight) &&
                context.anchorHash != 0x0,
            "invalid anchor"
        );

        require(context.beneficiary != address(0), "null beneficiary");
        require(
            context.gasLimit <= LibConstants.MAX_TAIKO_BLOCK_GAS_LIMIT,
            "invalid gasLimit"
        );
        require(context.extraData.length <= 32, "extraData too large");
    }

    function getStats() public view returns (Stats memory stats) {
        stats = _stats;
        stats.avgPendingSize /= NANO_PER_SECOND;
        stats.avgProvingDelay /= NANO_PER_SECOND;
        stats.avgFinalizationDelay /= NANO_PER_SECOND;
    }

    function getUtilizationFeeBips()
        public
        view
        returns (
            uint256 /*basisPoints*/
        )
    {
        // TODO(daniel): optimize the math. Maybe also include `proverGasPrice` in the
        // calculation.
        uint256 numPendingBlocks = nextPendingId - lastFinalizedId;

        // threshold is the middle point of MAX_PENDING_BLOCKS/2 and
        // _stats.avgPendingSize
        uint256 threshold = MAX_PENDING_BLOCKS / 4 + _stats.avgPendingSize / 2;
        if (numPendingBlocks <= threshold) return 0;

        return
            (UTILIZATION_FEE_RATIO * 100 * (numPendingBlocks - threshold)) /
            (MAX_PENDING_BLOCKS - threshold);
    }

    function getBlockTaiReward(uint256 provingDelay)
        public
        view
        returns (uint256)
    {
        // TODO: implement this
    }

    /**********************
     * Private Functions  *
     **********************/

    function _invalidateBlock(BlockContext memory context, bool noZKP) private {
        require(
            evidences[context.id][JUMP_MARKER].prover == address(0),
            "already invalidated"
        );
        evidences[context.id][JUMP_MARKER] = Evidence({
            prover: msg.sender,
            proverFee: context.proverFee,
            proposedAt: context.proposedAt,
            provenAt: noZKP ? context.proposedAt : block.timestamp.toUint64(),
            blockHash: 0x0
        });
        emit BlockProvenInvalid(context.id);
    }

    function _finalizeBlock(
        uint64 id,
        uint64 _lastFinalizedHeight,
        Evidence storage evidence
    ) private {
        _payProverFee(evidence.prover, evidence.proverFee);
        (uint256 blockReward, uint256 daoReward) = _payBlockReward(
            evidence.prover,
            evidence.provenAt - evidence.proposedAt
        );

        // Update stats
        _stats.avgProvingDelay = _calcAverage(
            _stats.avgProvingDelay,
            evidence.provenAt - evidence.proposedAt
        );

        _stats.avgFinalizationDelay = _calcAverage(
            _stats.avgFinalizationDelay,
            block.timestamp.toUint64() - evidence.proposedAt
        );

        emit BlockFinalized(
            id,
            _lastFinalizedHeight,
            evidence,
            blockReward,
            daoReward
        );

        // Delete the evidence to potentially avoid 4 sstore ops.
        evidence.prover = address(0);
        evidence.proverFee = 0;
        evidence.proposedAt = 0;
        evidence.proposedAt = 0;
        evidence.blockHash = 0x0;
    }

    function _chargeProposerFee(uint256 proverFee) private {
        address daoVault = resolve("dao_vault");
        uint256 utilizationFee = daoVault == address(0)
            ? 0
            : (proverFee * getUtilizationFeeBips()) / 10000;
        uint256 totalFees = proverFee + utilizationFee;

        require(msg.value >= totalFees, "insufficient fee");

        // Refund
        if (msg.value > totalFees) {
            payable(msg.sender).transfer(msg.value - totalFees);
        }
        if (utilizationFee > 0) {
            payable(daoVault).transfer(utilizationFee);
        }
    }

    function _payProverFee(address prover, uint256 proverFee) private {
        // Pay prover fee
        bool success;
        (success, ) = prover.call{value: proverFee}("");
        if (success) return;

        proverFeeToDAO += proverFee;

        address daoVault = resolve("dao_vault");
        if (daoVault == address(0)) return;

        (success, ) = daoVault.call{value: proverFeeToDAO - 1}("");
        if (success) {
            proverFeeToDAO = 1;
        }
    }

    function _payBlockReward(address prover, uint256 provingDelay)
        private
        returns (uint256 blockReward, uint256 daoReward)
    {
        address protoToken = resolve("proto_token");
        if (protoToken == address(0)) return (0, 0);

        blockReward = getBlockTaiReward(provingDelay);
        if (blockReward != 0) {
            IMintableERC20(protoToken).mint(prover, blockReward);

            address daoVault = resolve("dao_vault");
            daoReward = daoVault == address(0)
                ? 0
                : (blockReward * DAO_REWARD_RATIO) / 100;

            if (daoReward != 0) {
                IMintableERC20(protoToken).mint(daoVault, daoReward);
            }
        }
    }

    function _savePendingBlock(uint256 id, bytes32 contextHash)
        private
        returns (bytes32)
    {
        return pendingBlocks[id % MAX_PENDING_BLOCKS] = contextHash;
    }

    function _getPendingBlock(uint256 id) private view returns (bytes32) {
        return pendingBlocks[id % MAX_PENDING_BLOCKS];
    }

    function _checkContextPending(BlockContext calldata context) private view {
        require(
            context.id > lastFinalizedId && context.id < nextPendingId,
            "invalid id"
        );
        require(
            _getPendingBlock(context.id) == _hashContext(context),
            "context mismatch"
        );
    }

    function _validateHeader(BlockHeader calldata header) private pure {
        require(
            header.parentHash != 0x0 &&
                header.gasLimit <= LibConstants.MAX_TAIKO_BLOCK_GAS_LIMIT &&
                header.extraData.length <= 32 &&
                header.difficulty == 0 &&
                header.nonce == 0,
            "header mismatch"
        );
    }

    function _validateHeaderForContext(
        BlockHeader calldata header,
        BlockContext memory context
    ) private pure {
        require(
            header.beneficiary == context.beneficiary &&
                header.gasLimit == context.gasLimit &&
                header.timestamp == context.proposedAt &&
                keccak256(header.extraData) == keccak256(context.extraData) && // TODO: direct compare
                header.mixHash == context.mixHash,
            "header mismatch"
        );
    }

    function _hashContext(BlockContext memory context)
        private
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(context));
    }

    function _calcAverage(uint64 avg, uint64 current)
        private
        pure
        returns (uint64)
    {
        if (current == 0) return avg;
        if (avg == 0) return current;

        uint256 _avg = ((STAT_AVERAGING_FACTOR - 1) *
            avg +
            current *
            NANO_PER_SECOND) / STAT_AVERAGING_FACTOR;
        return _avg.toUint64();
    }
}
