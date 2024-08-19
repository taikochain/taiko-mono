// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./ComposeVerifier.sol";

/// @title ZkVMVerifier
/// @notice This contract is a verifier for the Mainnet ZkVM that composes RiscZero and SP1
/// Verifiers.
/// @custom:security-contact security@taiko.xyz
contract ZkVMVerifier is ComposeVerifier {
    address internal immutable RISK_ZERO_VERIFIER;
    address internal immutable SP1_VERIFIER;

    constructor(address _risc0Verifier, address _sp1Verifier) {
        RISK_ZERO_VERIFIER = _risc0Verifier;
        SP1_VERIFIER = _sp1Verifier;
    }

    /// @notice Returns the address of the Risc0 verifier.
    /// @return The address of the Risc0 verifier.
    function getRisc0Verifier() public view virtual returns (address) {
        return RISK_ZERO_VERIFIER;
    }

    /// @notice Returns the address of the SP1 verifier.
    /// @return The address of the SP1 verifier.
    function getSp1Verifier() public view virtual returns (address) {
        return SP1_VERIFIER;
    }

    /// @inheritdoc ComposeVerifier
    function getSubVerifiers() public view override returns (address[] memory verifiers_) {
        verifiers_ = new address[](2);
        verifiers_[0] = getRisc0Verifier();
        verifiers_[1] = getSp1Verifier();
    }

    /// @inheritdoc ComposeVerifier
    function getMode() public pure override returns (Mode) {
        return Mode.ONE;
    }
}
