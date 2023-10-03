// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.20;

import { LibFixedPointMath } from "../thirdparty/LibFixedPointMath.sol";
import { EssentialContract } from "../common/EssentialContract.sol";
import { ICrossChainSync } from "../common/ICrossChainSync.sol";
import { Proxied } from "../common/Proxied.sol";

import { LibMath } from "../libs/LibMath.sol";

import { Lib1559Math } from "./Lib1559Math.sol";
import { TaikoL2Signer } from "./TaikoL2Signer.sol";

/// @title TaikoL2
/// @notice Taiko L2 is a smart contract that handles cross-layer message
/// verification and manages EIP-1559 gas pricing for Layer 2 (L2) operations.
/// It is used to anchor the latest L1 block details to L2 for cross-layer
/// communication, manage EIP-1559 parameters for gas pricing, and store
/// verified L1 block information.
contract TaikoL2 is EssentialContract, TaikoL2Signer, ICrossChainSync {
    using LibMath for uint256;

    struct VerifiedBlock {
        bytes32 blockHash;
        bytes32 signalRoot;
    }

    // Mapping from L2 block numbers to their block hashes.
    // All L2 block hashes will be saved in this mapping.
    mapping(uint256 blockId => bytes32 blockHash) private _l2Hashes;
    mapping(uint256 blockId => VerifiedBlock) private _l1VerifiedBlocks;

    // A hash to check the integrity of public inputs.
    bytes32 public publicInputHash; // slot 3
    uint128 public gasExcess; // slot 4
    uint64 public latestSyncedL1Height;

    uint256[146] private __gap;

    // Captures all block variables mentioned in
    // https://docs.soliditylang.org/en/v0.8.20/units-and-global-variables.html
    event Anchored(bytes32 parentHash, uint128 gasExcess);

    error L2_BASEFEE_MISMATCH();
    error L2_INVALID_CHAIN_ID();
    error L2_INVALID_SENDER();
    error L2_GAS_EXCESS_TOO_LARGE();
    error L2_PUBLIC_INPUT_HASH_MISMATCH();
    error L2_TOO_LATE();

    /// @notice Initializes the TaikoL2 contract.
    /// @param _addressManager Address of the {AddressManager} contract.
    function init(
        address _addressManager,
        uint128 _gasExcess
    )
        external
        initializer
    {
        EssentialContract._init(_addressManager);

        if (block.chainid <= 1 || block.chainid >= type(uint64).max) {
            revert L2_INVALID_CHAIN_ID();
        }
        if (block.number > 1) revert L2_TOO_LATE();

        if (block.number > 0) {
            uint256 parentHeight = block.number - 1;
            _l2Hashes[parentHeight] = blockhash(parentHeight);
        }

        gasExcess = _gasExcess;
        (publicInputHash,) = _calcPublicInputHash(block.number);
    }

    /// @notice Anchors the latest L1 block details to L2 for cross-layer
    /// message verification.
    /// @param l1Hash The latest L1 block hash when this block was proposed.
    /// @param l1SignalRoot The latest value of the L1 signal service storage
    /// root.
    /// @param syncedL1Height The latest L1 block height when this block was
    /// proposed.
    /// @param parentGasUsed The gas used in the parent block.
    function anchor(
        bytes32 l1Hash,
        bytes32 l1SignalRoot,
        uint64 syncedL1Height,
        uint32 parentGasUsed
    )
        external
    {
        if (msg.sender != GOLDEN_TOUCH_ADDRESS) revert L2_INVALID_SENDER();

        // verify ancestor hashes
        (bytes32 publicInputHashOld, bytes32 publicInputHashNew) =
            _calcPublicInputHash(block.number - 1);
        if (publicInputHash != publicInputHashOld) {
            revert L2_PUBLIC_INPUT_HASH_MISMATCH();
        }
        publicInputHash = publicInputHashNew;

        // Verify the base fee per gas is correct
        uint256 basefee;
        (basefee, gasExcess) = _calc1559BaseFee(syncedL1Height, parentGasUsed);
        if (block.basefee != basefee) {
            revert L2_BASEFEE_MISMATCH();
        }

        bytes32 parentHash = blockhash(block.number - 1);
        _l2Hashes[block.number - 1] = parentHash;
        latestSyncedL1Height = syncedL1Height;
        _l1VerifiedBlocks[syncedL1Height] = VerifiedBlock(l1Hash, l1SignalRoot);

        emit CrossChainSynced(syncedL1Height, l1Hash, l1SignalRoot);
        emit Anchored(parentHash, gasExcess);
    }

    /// @inheritdoc ICrossChainSync
    function getCrossChainBlockHash(uint64 blockId)
        public
        view
        override
        returns (bytes32)
    {
        uint256 id = blockId == 0 ? latestSyncedL1Height : blockId;
        return _l1VerifiedBlocks[id].blockHash;
    }

    /// @inheritdoc ICrossChainSync
    function getCrossChainSignalRoot(uint64 blockId)
        public
        view
        override
        returns (bytes32)
    {
        uint256 id = blockId == 0 ? latestSyncedL1Height : blockId;
        return _l1VerifiedBlocks[id].signalRoot;
    }

    /// @notice Gets the basefee and gas excess using EIP-1559 configuration for
    /// the given parameters.
    /// @param syncedL1Height The synced L1 height in the next Taiko block
    /// @param parentGasUsed Gas used in the parent block.
    /// @return basefee The calculated EIP-1559 base fee per gas.
    function getBasefee(
        uint64 syncedL1Height,
        uint32 parentGasUsed
    )
        public
        view
        returns (uint256 basefee)
    {
        (basefee,) = _calc1559BaseFee(syncedL1Height, parentGasUsed);
    }

    /// @notice Returns EIP1559 related configurations
    function get1559Params()
        public
        pure
        virtual
        returns (uint64 gasTarget, uint256 adjustmentQuotient)
    {
        gasTarget = 15 * 1e6 * 10; // 10x Ethereum gas target
        adjustmentQuotient = 8;
    }

    /// @notice Retrieves the block hash for the given L2 block number.
    /// @param blockId The L2 block number to retrieve the block hash for.
    /// @return The block hash for the specified L2 block id, or zero if the
    /// block id is greater than or equal to the current block number.

    function getBlockHash(uint64 blockId) public view returns (bytes32) {
        if (blockId >= block.number) {
            return 0;
        } else if (blockId < block.number && blockId >= block.number - 256) {
            return blockhash(blockId);
        } else {
            return _l2Hashes[blockId];
        }
    }

    function _calcPublicInputHash(uint256 blockId)
        private
        view
        returns (bytes32 publicInputHashOld, bytes32 publicInputHashNew)
    {
        bytes32[256] memory inputs;

        // Unchecked is safe because it cannot overflow.
        unchecked {
            // Put the previous 255 blockhashes (excluding the parent's) into a
            // ring buffer.
            for (uint256 i; i < 255 && blockId >= i + 1; ++i) {
                uint256 j = blockId - i - 1;
                inputs[j % 255] = blockhash(j);
            }
        }

        inputs[255] = bytes32(block.chainid);

        assembly {
            publicInputHashOld := keccak256(inputs, 8192 /*mul(256, 32)*/ )
        }

        inputs[blockId % 255] = blockhash(blockId);
        assembly {
            publicInputHashNew := keccak256(inputs, 8192 /*mul(256, 32)*/ )
        }
    }

    function _calc1559BaseFee(
        uint64 syncedL1Height,
        uint32 parentGasUsed
    )
        private
        view
        returns (uint256 _basefee, uint128 _gasExcess)
    {
        // gasExcess being 0 indicate the dynamic 1559 base fee is disabled.
        if (gasExcess > 0) {
            // We always add the gas used by parent block to the gas excess
            // value as this has already happend
            uint256 excess = uint256(gasExcess) + parentGasUsed;

            // Calculate how much more gas to issue to offset gas excess.
            // after each L1 block time, config.gasTarget more gas is issued,
            // the gas excess will be reduced accordingly.
            // Note that when latestSyncedL1Height is zero, we skip this step.
            uint128 numL1Blocks;
            if (
                latestSyncedL1Height > 0
                    && syncedL1Height > latestSyncedL1Height
            ) {
                numL1Blocks = syncedL1Height - latestSyncedL1Height;
            }

            (uint64 gasTarget, uint256 adjustmentQuotient) = get1559Params();

            if (numL1Blocks > 0) {
                uint128 issuance = numL1Blocks * gasTarget;
                excess = excess > issuance ? excess - issuance : 1;
            }

            _gasExcess = uint128(excess.min(type(uint128).max));

            // The base fee per gas used by this block is the spot price at the
            // bonding curve, regardless the actual amount of gas used by this
            // block, however, the this block's gas used will affect the next
            // block's base fee.
            _basefee =
                Lib1559Math.basefee(_gasExcess, adjustmentQuotient * gasTarget);
        }

        // Always make sure basefee is nonzero, this is required by the node.
        if (_basefee == 0) _basefee = 1;
    }
}

/// @title ProxiedTaikoL2
/// @notice Proxied version of the TaikoL2 contract.
contract ProxiedTaikoL2 is Proxied, TaikoL2 { }
