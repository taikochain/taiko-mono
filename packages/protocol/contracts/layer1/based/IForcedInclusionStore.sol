// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title IForcedInclusionStore
/// @custom:security-contact security@taiko.xyz
interface IForcedInclusionStore {
    /// @dev Error thrown when a blob is not found.
    error BlobNotFound();
    /// @dev Error thrown when the parameters are invalid.
    error InvalidParams();
    /// @dev Error thrown when the fee is incorrect.
    error IncorrectFee();

    /// @dev Event emitted when a forced inclusion is stored.
    event ForcedInclusionStored(ForcedInclusion forcedInclusion);
    /// @dev Event emitted when a forced inclusion is consumed.
    event ForcedInclusionConsumed(ForcedInclusion forcedInclusion);

    struct ForcedInclusion {
        bytes32 blobHash;
        uint256 fee;
        uint64 createdAt;
        uint32 blobByteOffset;
        uint32 blobByteSize;
    }

    /// @dev Consume a forced inclusion request.
    /// The inclusion request must be marked as processed and the priority fee must be paid to the
    /// caller.
    /// @return inclusion_ The forced inclusion request.
    function consumeForcedInclusion(address _feeRecipient)
        external
        returns (ForcedInclusion memory);

    /// @dev Store a forced inclusion request.
    /// The priority fee must be paid to the contract.
    /// @param blobIndex The index of the blob that contains the transaction data.
    /// @param blobByteOffset The byte offset in the blob
    /// @param blobByteSize The size of the blob in bytes
    function storeForcedInclusion(
        uint8 blobIndex,
        uint32 blobByteOffset,
        uint32 blobByteSize
    )
        external
        payable;
}
