// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../../common/LibStrings.sol";
import "./ITierProvider.sol";

/// @title TierProviderBase
/// @custom:security-contact security@taiko.xyz
abstract contract TierProviderBase is ITierProvider {
    /// @dev Grace period for block proving service.
    /// @notice This constant defines the time window (in minutes) during which the block proving
    /// service may be paused if gas prices are excessively high. Since block proving is
    /// asynchronous, this grace period allows provers to defer submissions until gas
    /// prices become more favorable, potentially reducing transaction costs.
    uint16 public constant GRACE_PERIOD = 240; // 4 hours

    /// @inheritdoc ITierProvider
    function getTier(
        uint16 _tierId
    )
        public
        pure
        virtual
        override
        returns (ITierProvider.Tier memory)
    {
        if (_tierId == LibTiers.TIER_OPTIMISTIC) {
            return ITierProvider.Tier({
                verifierName: "",
                validityBond: 125 ether, // TKO
                contestBond: 250 ether, // TKO
                cooldownWindow: 1440, //24 hours
                provingWindow: GRACE_PERIOD + 15, // 15 minutes
                maxBlocksToVerifyPerProof: 0
            });
        }

        if (_tierId == LibTiers.TIER_SGX) {
            return ITierProvider.Tier({
                verifierName: LibStrings.B_TIER_SGX,
                validityBond: 125 ether, // TKO
                contestBond: 820 ether, // =250TKO * 6.5625
                cooldownWindow: 1440, //24 hours
                provingWindow: GRACE_PERIOD + 60, // 1 hours
                maxBlocksToVerifyPerProof: 0
            });
        }

        if (_tierId == LibTiers.TIER_SGX2) {
            return ITierProvider.Tier({
                verifierName: LibStrings.B_TIER_SGX2,
                validityBond: 125 ether, // TKO
                contestBond: 820 ether, // =250TKO * 6.5625
                cooldownWindow: 1440, //24 hours
                provingWindow: GRACE_PERIOD + 60, // 1 hours
                maxBlocksToVerifyPerProof: 0
            });
        }

        if (_tierId == LibTiers.TIER_ZKVM_RISC0) {
            return ITierProvider.Tier({
                verifierName: LibStrings.B_TIER_ZKVM_RISC0,
                validityBond: 250 ether, // TKO
                contestBond: 1640 ether, // =500TKO * 6.5625
                cooldownWindow: 1440, //24 hours
                provingWindow: GRACE_PERIOD + 240, // 4 hours
                maxBlocksToVerifyPerProof: 0
            });
        }

        if (_tierId == LibTiers.TIER_SGX_ZKVM) {
            return ITierProvider.Tier({
                verifierName: LibStrings.B_TIER_SGX_ZKVM,
                validityBond: 250 ether, // TKO
                contestBond: 1640 ether, // =500TKO * 6.5625
                cooldownWindow: 1440, //24 hours
                provingWindow: GRACE_PERIOD + 240, // 4 hours
                maxBlocksToVerifyPerProof: 0
            });
        }

        if (_tierId == LibTiers.TIER_GUARDIAN_MINORITY) {
            return ITierProvider.Tier({
                verifierName: LibStrings.B_TIER_GUARDIAN_MINORITY,
                validityBond: 250 ether, // TKO
                contestBond: 1640 ether, // =500TKO * 6.5625
                cooldownWindow: GRACE_PERIOD + 240, // 4 hours
                provingWindow: 2880, // 48 hours
                maxBlocksToVerifyPerProof: 0
            });
        }

        if (_tierId == LibTiers.TIER_GUARDIAN) {
            return ITierProvider.Tier({
                verifierName: LibStrings.B_TIER_GUARDIAN,
                validityBond: 0, // must be 0 for top tier
                contestBond: 0, // must be 0 for top tier
                cooldownWindow: 1440, // 24 hours
                provingWindow: GRACE_PERIOD + 2880, // 48 hours
                maxBlocksToVerifyPerProof: 0
            });
        }

        revert TIER_NOT_FOUND();
    }
}
