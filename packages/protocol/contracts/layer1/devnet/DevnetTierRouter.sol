// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../tiers/TierProviderBase.sol";
import "../tiers/ITierRouter.sol";

/// @title DevnetTierRouter
/// @custom:security-contact security@taiko.xyz
contract DevnetTierRouter is TierProviderBase, ITierRouter {
    /// @inheritdoc ITierRouter
    function getProvider(uint256) external view returns (address) {
        return address(this);
    }

    /// @inheritdoc ITierProvider
    function getTierIds() external pure returns (uint16[] memory ids_) {
        ids_ = new uint16[](3);
        ids_[0] = LibTiers.TIER_OPTIMISTIC;
        ids_[1] = LibTiers.TIER_GUARDIAN_MINORITY;
        ids_[2] = LibTiers.TIER_GUARDIAN;
    }

    /// @inheritdoc ITierProvider
    function getMinTier(address, uint256) public pure override returns (uint16) {
        return LibTiers.TIER_OPTIMISTIC;
    }
}
