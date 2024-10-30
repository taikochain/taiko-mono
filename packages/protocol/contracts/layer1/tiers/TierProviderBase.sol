// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "src/shared/common/LibStrings.sol";
import "./ITierProvider.sol";
import "./LibTiers.sol";

/// @title TierProviderBase
/// @custom:security-contact security@taiko.xyz
abstract contract TierProviderBase is ITierProvider {
    /// @dev Grace period for block proving service.
    /// @notice This constant defines the time window (in minutes) during which the block proving
    /// service may be paused if gas prices are excessively high. Since block proving is
    /// asynchronous, this grace period allows provers to defer submissions until gas
    /// prices become more favorable, potentially reducing transaction costs.
    uint16 public constant GRACE_PERIOD = 240; // minutes
    uint96 public constant BOND_UNIT = 75 ether; // TAIKO tokens

    /// @inheritdoc ITierProvider
    function getTierIds() external pure returns (uint16[] memory ids_) {
        ids_ = new uint16[](10);
        ids_[0] = LibTiers.TIER_OPTIMISTIC;
        ids_[1] = LibTiers.TIER_SGX;
        ids_[2] = LibTiers.TIER_TDX;
        ids_[3] = LibTiers.TIER_TEE_ANY;
        ids_[4] = LibTiers.TIER_ZKVM_RISC0;
        ids_[5] = LibTiers.TIER_ZKVM_SP1;
        ids_[6] = LibTiers.TIER_ZKVM_ANY;
        ids_[7] = LibTiers.TIER_ZKVM_AND_TEE;
        ids_[8] = LibTiers.TIER_GUARDIAN_MINORITY;
        ids_[9] = LibTiers.TIER_GUARDIAN;
    }

    /// @inheritdoc ITierProvider
    /// @notice Each tier, except the top tier, has a validity bond that is 75 TAIKO higher than the
    /// previous tier. Additionally, each tier's contest bond is 6.5625 times its validity bond.
    function getTier(uint16 _tierId) public pure virtual returns (ITierProvider.Tier memory) {
        if (_tierId == LibTiers.TIER_OPTIMISTIC) {
            // cooldownWindow is 24 hours and provingWindow is 15 minutes
            return _buildTier("", BOND_UNIT, 24, 15);
        }

        // TEE Tiers
        if (_tierId == LibTiers.TIER_SGX) return _buildTeeTier(LibStrings.B_TIER_SGX);
        if (_tierId == LibTiers.TIER_TDX) return _buildTeeTier(LibStrings.B_TIER_TDX);
        if (_tierId == LibTiers.TIER_TEE_ANY) return _buildTeeTier(LibStrings.B_TIER_TEE_ANY);

        // ZKVM Tiers
        if (_tierId == LibTiers.TIER_ZKVM_RISC0) return _buildZkTier(LibStrings.B_TIER_ZKVM_RISC0);
        if (_tierId == LibTiers.TIER_ZKVM_SP1) return _buildZkTier(LibStrings.B_TIER_ZKVM_SP1);
        if (_tierId == LibTiers.TIER_ZKVM_ANY) return _buildZkTier(LibStrings.B_TIER_ZKVM_ANY);

        // ZKVM+TEE Tier
        if (_tierId == LibTiers.TIER_ZKVM_AND_TEE) {
            // cooldownWindow is 2 hours and provingWindow is 3 hours
            return _buildTier(LibStrings.B_TIER_ZKVM_AND_TEE, BOND_UNIT * 4, 2, 180);
        }

        // Guardian Minority Tiers
        if (_tierId == LibTiers.TIER_GUARDIAN_MINORITY) {
            // cooldownWindow is 4 hours
            return _buildTier(LibStrings.B_TIER_GUARDIAN_MINORITY, BOND_UNIT * 4, 4, 0);
        }

        // Guardian Major Tiers
        if (_tierId == LibTiers.TIER_GUARDIAN) {
            // cooldownWindow is 4 hours
            return _buildTier(LibStrings.B_TIER_GUARDIAN, 0, 4, 0);
        }

        revert TIER_NOT_FOUND();
    }

    /// @dev Builds a TEE tier with a specific verifier name.
    /// @param _verifierName The name of the verifier.
    /// @return A Tier struct with predefined parameters for TEE.
    function _buildTeeTier(bytes32 _verifierName)
        private
        pure
        returns (ITierProvider.Tier memory)
    {
        // cooldownWindow is 4 hours and provingWindow is 60 minutes
        return _buildTier(_verifierName, BOND_UNIT * 2, 4, 60);
    }

    /// @dev Builds a ZK tier with a specific verifier name.
    /// @param _verifierName The name of the verifier.
    /// @return A Tier struct with predefined parameters for ZK.
    function _buildZkTier(bytes32 _verifierName) private pure returns (ITierProvider.Tier memory) {
        // cooldownWindow is 4 hours and provingWindow is 3 hours
        return _buildTier(_verifierName, BOND_UNIT * 3, 4, 180);
    }

    /// @dev Builds a generic tier with specified parameters.
    /// @param _verifierName The name of the verifier.
    /// @param _validityBond The validity bond amount.
    /// @param _cooldownWindow The cooldown window duration in hours.
    /// @param _provingWindow The proving window duration in minutes.
    /// @return A Tier struct with the provided parameters.
    function _buildTier(
        bytes32 _verifierName,
        uint96 _validityBond,
        uint16 _cooldownWindow,
        uint16 _provingWindow
    )
        private
        pure
        returns (ITierProvider.Tier memory)
    {
        return ITierProvider.Tier({
            verifierName: _verifierName,
            validityBond: _validityBond,
            contestBond: _validityBond / 10_000 * 65_625,
            cooldownWindow: _cooldownWindow * 60,
            provingWindow: GRACE_PERIOD + _provingWindow,
            maxBlocksToVerifyPerProof: 0
        });
    }
}
