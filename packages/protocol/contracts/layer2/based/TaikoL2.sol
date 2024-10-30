// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "src/shared/data/LibSharedData.sol";
import "src/shared/common/EssentialContract.sol";
import "src/shared/common/LibStrings.sol";
import "src/shared/common/LibAddress.sol";
import "src/shared/signal/ISignalService.sol";
import "./LibEIP1559.sol";
import "./LibL2Config.sol";
import "./IBlockHash.sol";

/// @title TaikoL2
/// @notice Taiko L2 is a smart contract that handles cross-layer message
/// verification and manages EIP-1559 gas pricing for Layer 2 (L2) operations.
/// It is used to anchor the latest L1 block details to L2 for cross-layer
/// communication, manage EIP-1559 parameters for gas pricing, and store
/// verified L1 block information.
/// @custom:security-contact security@taiko.xyz
contract TaikoL2 is EssentialContract, IBlockHash {
    using LibAddress for address;
    using SafeERC20 for IERC20;

    /// @notice Golden touch address is the only address that can do the anchor transaction.
    address public constant GOLDEN_TOUCH_ADDRESS = 0x0000777735367b36bC9B61C50022d9D0700dB4Ec;

    /// @notice Mapping from L2 block numbers to their block hashes. All L2 block hashes will
    /// be saved in this mapping.
    mapping(uint256 blockId => bytes32 blockHash) private _blockhashes;

    /// @notice A hash to check the integrity of public inputs.
    /// @dev Slot 2.
    bytes32 public ancestorsHash;

    /// @notice The gas excess value used to calculate the base fee.
    /// @dev Slot 3.
    uint64 public parentGasExcess;

    /// @notice The last synced L1 block height.
    uint64 public lastSyncedBlock;

    /// @notice The last L2 block's timestamp.
    uint64 private _parentTimestamp;

    /// @notice The last L2 block's gas target.
    uint64 public parentGasTarget;

    /// @notice The L1's chain ID.
    uint64 public l1ChainId;

    uint256[46] private __gap;

    /// @notice Emitted when the latest L1 block details are anchored to L2.
    /// @param parentHash The hash of the parent block.
    /// @param parentGasExcess The gas excess value used to calculate the base fee.
    event Anchored(bytes32 parentHash, uint64 parentGasExcess);

    event UpdateGasTargetSucceeded(uint64 oldGasTarget, uint64 newGasTarget);
    event UpdateGasTargetFailed();

    error L2_BASEFEE_MISMATCH();
    error L2_FORK_ERROR();
    error L2_INVALID_L1_CHAIN_ID();
    error L2_INVALID_L2_CHAIN_ID();
    error L2_INVALID_PARAM();
    error L2_INVALID_SENDER();
    error L2_PUBLIC_INPUT_HASH_MISMATCH();
    error L2_TOO_LATE();

    modifier onlyGoldenTouch() {
        require(msg.sender == GOLDEN_TOUCH_ADDRESS, L2_INVALID_SENDER());
        _;
    }

    /// @notice Initializes the contract.
    /// @param _owner The owner of this contract. msg.sender will be used if this value is zero.
    /// @param _rollupAddressManager The address of the {AddressManager} contract.
    /// @param _l1ChainId The ID of the base layer.
    /// @param _initialGasExcess The initial parentGasExcess.
    function init(
        address _owner,
        address _rollupAddressManager,
        uint64 _l1ChainId,
        uint64 _initialGasExcess
    )
        external
        initializer
    {
        __Essential_init(_owner, _rollupAddressManager);

        require(_l1ChainId != 0, L2_INVALID_L1_CHAIN_ID());
        require(_l1ChainId != block.chainid, L2_INVALID_L1_CHAIN_ID());
        require(block.chainid > 1, L2_INVALID_L2_CHAIN_ID());
        require(block.chainid <= type(uint64).max, L2_INVALID_L2_CHAIN_ID());

        if (block.number == 0) {
            // This is the case in real L2 genesis
        } else if (block.number == 1) {
            // This is the case in tests
            uint256 parentHeight = block.number - 1;
            _blockhashes[parentHeight] = blockhash(parentHeight);
        } else {
            revert L2_TOO_LATE();
        }

        l1ChainId = _l1ChainId;
        parentGasExcess = _initialGasExcess;
        (ancestorsHash,) = _calcAncestorsHash(block.number);
    }

    /// @dev DEPRECATED but used by node/client for syncing old blocks
    /// @notice Anchors the latest L1 block details to L2 for cross-layer
    /// message verification.
    /// @dev This function can be called freely as the golden touch private key is publicly known,
    /// but the Taiko node guarantees the first transaction of each block is always this anchor
    /// transaction, and any subsequent calls will revert with L2_PUBLIC_INPUT_HASH_MISMATCH.
    /// @param _l1StateRoot The state root for the L1 block with id equals `_anchorBlockId`
    /// @param _l1BlockId The `anchorBlockId` value in this block's metadata.
    /// @param _parentGasUsed The gas used in the parent block.
    function anchor(
        bytes32, /*_l1BlockHash*/
        bytes32 _l1StateRoot,
        uint64 _l1BlockId,
        uint32 _parentGasUsed
    )
        external
        nonZeroBytes32(_l1StateRoot)
        nonZeroValue(_l1BlockId)
        onlyGoldenTouch
        nonReentrant
    {
        require(block.number < ontakeForkHeight(), L2_FORK_ERROR());

        uint256 parentId = block.number - 1;
        _verifyAndUpdateAncestorsHash(parentId);
        _verifyBaseFeeAndUpdateGasExcess(_l1BlockId, _parentGasUsed);
        _syncChainData(_l1BlockId, _l1StateRoot);
        _updateParentHashAndTimestamp(parentId);
    }

    /// @notice Anchors the latest L1 block details to L2 for cross-layer
    /// message verification.
    /// @dev This function can be called freely as the golden touch private key is publicly known,
    /// but the Taiko node guarantees the first transaction of each block is always this anchor
    /// transaction, and any subsequent calls will revert with L2_PUBLIC_INPUT_HASH_MISMATCH.
    /// @param _anchorBlockId The `anchorBlockId` value in this block's metadata.
    /// @param _anchorStateRoot The state root for the L1 block with id equals `_anchorBlockId`.
    /// @param _parentGasUsed The gas used in the parent block.
    /// @param _baseFeeConfig The base fee configuration.
    function anchorV2(
        uint64 _anchorBlockId,
        bytes32 _anchorStateRoot,
        uint32 _parentGasUsed,
        LibSharedData.BaseFeeConfig calldata _baseFeeConfig
    )
        external
        nonZeroBytes32(_anchorStateRoot)
        nonZeroValue(_anchorBlockId)
        nonZeroValue(_baseFeeConfig.gasIssuancePerSecond)
        nonZeroValue(_baseFeeConfig.adjustmentQuotient)
        onlyGoldenTouch
        nonReentrant
    {
        require(block.number >= ontakeForkHeight(), L2_FORK_ERROR());

        uint256 parentId = block.number - 1;
        _verifyAndUpdateAncestorsHash(parentId);
        _verifyBaseFeeAndUpdateGasExcessV2(_parentGasUsed, _baseFeeConfig);
        _syncChainData(_anchorBlockId, _anchorStateRoot);
        _updateParentHashAndTimestamp(parentId);
    }

    /// @notice Withdraw token or Ether from this address.
    /// Note: This contract receives a portion of L2 base fees, while the remainder is directed to
    /// L2 block's coinbase address.
    /// @param _token Token address or address(0) if Ether.
    /// @param _to Withdraw to address.
    function withdraw(
        address _token,
        address _to
    )
        external
        nonZeroAddr(_to)
        whenNotPaused
        onlyFromOwnerOrNamed(LibStrings.B_WITHDRAWER)
        nonReentrant
    {
        if (_token == address(0)) {
            _to.sendEtherAndVerify(address(this).balance);
        } else {
            IERC20(_token).safeTransfer(_to, IERC20(_token).balanceOf(address(this)));
        }
    }

    /// @dev DEPRECATED but used by node/client for syncing old blocks
    /// @notice Gets the basefee and gas excess using EIP-1559 configuration for
    /// the given parameters.
    /// @param _anchorBlockId The synced L1 height in the next Taiko block
    /// @param _parentGasUsed Gas used in the parent block.
    /// @return basefee_ The calculated EIP-1559 base fee per gas.
    /// @return parentGasExcess_ The new parentGasExcess value.
    function getBasefee(
        uint64 _anchorBlockId,
        uint32 _parentGasUsed
    )
        public
        view
        returns (uint256 basefee_, uint64 parentGasExcess_)
    {
        LibL2Config.Config memory config = LibL2Config.get();

        (basefee_, parentGasExcess_) = LibEIP1559.calc1559BaseFee(
            uint64(config.gasTargetPerL1Block) * config.basefeeAdjustmentQuotient,
            parentGasExcess,
            uint64(_anchorBlockId - lastSyncedBlock) * config.gasTargetPerL1Block,
            _parentGasUsed,
            0
        );
    }

    /// @notice Calculates the base fee and gas excess using EIP-1559 configuration for the given
    /// parameters.
    /// @param _parentGasUsed Gas used in the parent block.
    /// @param _baseFeeConfig Configuration parameters for base fee calculation.
    /// @return basefee_ The calculated EIP-1559 base fee per gas.
    /// @return parentGasExcess_ The new parentGasExcess value.
    /// @return parentGasTarget_ The new parentGasTarget value.
    /// @return newGasTargetApplied_ Indicates if a new gas target was applied.
    function getBasefeeV2(
        uint32 _parentGasUsed,
        LibSharedData.BaseFeeConfig calldata _baseFeeConfig
    )
        public
        view
        returns (
            uint256 basefee_,
            uint64 parentGasExcess_,
            uint64 parentGasTarget_,
            bool newGasTargetApplied_
        )
    {
        // Check if the gas settings has changed
        uint64 newGasTarget =
            uint64(_baseFeeConfig.gasIssuancePerSecond) * _baseFeeConfig.adjustmentQuotient;

        if (parentGasTarget != newGasTarget) {
            if (parentGasTarget == 0) {
                parentGasExcess_ = parentGasExcess;
                parentGasTarget_ = newGasTarget;
            } else {
                uint64 newGasExcess;
                (newGasTargetApplied_, newGasExcess) =
                    LibEIP1559.adjustExcess(parentGasExcess, parentGasTarget, newGasTarget);

                if (newGasTargetApplied_) {
                    parentGasExcess_ = newGasExcess;
                    parentGasTarget_ = newGasTarget;
                } else {
                    // asssert(newGasExcess == 0);
                    parentGasExcess_ = parentGasExcess;
                    parentGasTarget_ = parentGasTarget;
                }
            }
        }

        uint64 gasIssuance =
            uint64(block.timestamp - _parentTimestamp) * _baseFeeConfig.gasIssuancePerSecond;

        if (
            _baseFeeConfig.maxGasIssuancePerBlock != 0
                && gasIssuance > _baseFeeConfig.maxGasIssuancePerBlock
        ) {
            gasIssuance = _baseFeeConfig.maxGasIssuancePerBlock;
        }

        (basefee_, parentGasExcess_) = LibEIP1559.calc1559BaseFee(
            parentGasTarget_,
            parentGasExcess_,
            gasIssuance,
            _parentGasUsed,
            _baseFeeConfig.minGasExcess
        );
    }

    /// @inheritdoc IBlockHash
    function getBlockHash(uint256 _blockId) public view returns (bytes32) {
        if (_blockId >= block.number) return 0;
        if (_blockId + 256 >= block.number) return blockhash(_blockId);
        return _blockhashes[_blockId];
    }

    /// @notice Tells if we need to validate basefee (for simulation).
    /// @return Returns true to skip checking basefee mismatch.
    function skipFeeCheck() public pure virtual returns (bool) {
        return false;
    }

    /// @notice Returns the parent timestamp.
    /// @return The timestamp of the parent block.
    function getParentTimestamp() public view returns (uint64) {
        return _parentTimestamp;
    }

    /// @notice Returns the Ontake fork height.
    /// @return The Ontake fork height.
    function ontakeForkHeight() public pure virtual returns (uint64) {
        return 0;
    }

    /// @dev Synchronizes chain data with the given anchor block ID and state root.
    /// @param _anchorBlockId The ID of the anchor block.
    /// @param _anchorStateRoot The state root of the anchor block.
    function _syncChainData(uint64 _anchorBlockId, bytes32 _anchorStateRoot) private {
        /// @dev If the anchor block ID is less than or equal to the last synced block, return
        /// early.
        if (_anchorBlockId <= lastSyncedBlock) return;

        /// @dev Store the L1's state root as a signal to the local signal service to
        /// allow for multi-hop bridging.
        ISignalService(resolve(LibStrings.B_SIGNAL_SERVICE, false)).syncChainData(
            l1ChainId, LibStrings.H_STATE_ROOT, _anchorBlockId, _anchorStateRoot
        );

        /// @dev Update the last synced block to the current anchor block ID.
        lastSyncedBlock = _anchorBlockId;
    }

    /// @dev Updates the parent block hash and timestamp.
    /// @param _parentId The ID of the parent block.
    function _updateParentHashAndTimestamp(uint256 _parentId) private {
        // Get the block hash of the parent block.
        bytes32 parentHash = blockhash(_parentId);

        // Store the parent block hash in the _blockhashes mapping.
        _blockhashes[_parentId] = parentHash;

        // Update the parent timestamp to the current block timestamp.
        _parentTimestamp = uint64(block.timestamp);

        // Emit an event to signal that the parent hash and gas excess have been anchored.
        emit Anchored(parentHash, parentGasExcess);
    }
    /// @dev Verifies that the base fee per gas is correct and updates the gas excess.
    /// @param _l1BlockId The ID of the L1 block.
    /// @param _parentGasUsed The gas used by the parent block.

    function _verifyBaseFeeAndUpdateGasExcess(uint64 _l1BlockId, uint32 _parentGasUsed) private {
        uint256 basefee_;

        // Calculate the base fee and update the parent gas excess.
        (basefee_, parentGasExcess) = getBasefee(_l1BlockId, _parentGasUsed);

        // Ensure the base fee matches the expected value or skip the check if allowed.
        require(skipFeeCheck() || block.basefee == basefee_, L2_BASEFEE_MISMATCH());
    }

    /// @dev Verifies that the base fee per gas is correct and updates the gas excess.
    /// @param _parentGasUsed The gas used by the parent block.
    /// @param _baseFeeConfig The configuration parameters for calculating the base fee.
    function _verifyBaseFeeAndUpdateGasExcessV2(
        uint32 _parentGasUsed,
        LibSharedData.BaseFeeConfig calldata _baseFeeConfig
    )
        private
    {
        uint256 basefee_;
        bool newGasTargetApplied_;
        uint64 parentGasTarget_;

        (basefee_, parentGasExcess, parentGasTarget_, newGasTargetApplied_) =
            getBasefeeV2(_parentGasUsed, _baseFeeConfig);

        require(skipFeeCheck() || block.basefee == basefee_, L2_BASEFEE_MISMATCH());

        if (!newGasTargetApplied_) {
            emit UpdateGasTargetFailed();
        } else if (parentGasTarget != parentGasTarget_) {
            emit UpdateGasTargetSucceeded(parentGasTarget, parentGasTarget_);
            parentGasTarget = parentGasTarget_;
        }
    }

    /// @dev Verifies the current ancestor hash and updates it with a new aggregated hash.
    /// @param _parentId The ID of the parent block.
    function _verifyAndUpdateAncestorsHash(uint256 _parentId) private {
        // Calculate the current and new ancestor hashes based on the parent block ID.
        (bytes32 currAncestorsHash_, bytes32 newAncestorsHash_) = _calcAncestorsHash(_parentId);

        // Ensure the current ancestor hash matches the expected value.
        require(ancestorsHash == currAncestorsHash_, L2_PUBLIC_INPUT_HASH_MISMATCH());

        // Update the ancestor hash to the new calculated value.
        ancestorsHash = newAncestorsHash_;
    }

    /// @dev Calculates the aggregated ancestor block hash for the given block ID.
    /// @dev This function computes two public input hashes: one for the previous state and one for
    /// the new state.
    /// It uses a ring buffer to store the previous 255 block hashes and the current chain ID.
    /// @param _blockId The ID of the block for which the public input hash is calculated.
    /// @return currAncestorsHash_ The public input hash for the previous state.
    /// @return newAncestorsHash_ The public input hash for the new state.
    function _calcAncestorsHash(uint256 _blockId)
        private
        view
        returns (bytes32 currAncestorsHash_, bytes32 newAncestorsHash_)
    {
        bytes32[256] memory inputs;

        // Unchecked is safe because it cannot overflow.
        unchecked {
            // Put the previous 255 blockhashes (excluding the parent's) into a
            // ring buffer.
            for (uint256 i; i < 255 && _blockId >= i + 1; ++i) {
                uint256 j = _blockId - i - 1;
                inputs[j % 255] = blockhash(j);
            }
        }

        inputs[255] = bytes32(block.chainid);

        assembly {
            currAncestorsHash_ := keccak256(inputs, 8192 /*mul(256, 32)*/ )
        }

        inputs[_blockId % 255] = blockhash(_blockId);
        assembly {
            newAncestorsHash_ := keccak256(inputs, 8192 /*mul(256, 32)*/ )
        }
    }
}
