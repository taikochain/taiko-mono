// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "src/layer1/tiers/ITierRouter.sol";
import "src/layer1/tiers/TierProviderBase.sol";

/// @title MainnetTierRouter
/// @dev Labeled in AddressResolver as "tier_router"
/// @custom:security-contact security@taiko.xyz
contract MainnetTierRouter is ITierRouter, TierProviderBase {
    address public immutable DAO_FALLBACK_PROPOSER;

    constructor(address _daoFallbackProposer) {
        // 0xD3f681bD6B49887A48cC9C9953720903967E9DC0
        DAO_FALLBACK_PROPOSER = _daoFallbackProposer;
    }

    /// @inheritdoc ITierRouter
    function getProvider(uint256) external view returns (address) {
        return address(this);
    }

    /// @inheritdoc ITierProvider
    function getMinTier(address _proposer, uint256 _rand) public view override returns (uint16) {
        if (_proposer == DAO_FALLBACK_PROPOSER) {
            return _rand % 500 == 0 ? LibTiers.TIER_ZKVM_ANY : LibTiers.TIER_SGX;
        }
        return LibTiers.TIER_SGX;
    }
}
