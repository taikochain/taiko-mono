// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../based/ITaikoInbox.sol";
import "../../shared/common/IPausable.sol";

/// @title IVerifier
/// @notice Defines the function that handles proof verification.
/// @custom:security-contact security@taiko.xyz
interface IVerifier is IPausable {
    struct Context {
        uint64 batchId;
        bytes32 metaHash;
        ITaikoInbox.Transition transition;
    }

    /// @notice Verifies multiple proofs. This function must throw if the proof cannot be verified.
    /// @param _ctxs The array of contexts for the proof verifications.
    /// @param _proof The batch proof to verify.
    function verifyProof(Context[] calldata _ctxs, bytes calldata _proof) external;
}
