// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "src/layer1/tiers/ITierRouter.sol";
import "src/layer1/tiers/TierProviderBase.sol";

/// @title MainnetTierRouter
/// @dev Any changes to the configuration in this file must be announced and documented on our site.
/// Ensure all modifications are reviewed by the devrel team.
/// @dev Labeled in AddressResolver as "tier_router"
/// @custom:security-contact security@taiko.xyz
contract MainnetTierRouter is ITierRouter, TierProviderBase {
    address public immutable DAO_FALLBACK_PROPOSER;
    uint8  public counter;

    constructor(address _daoFallbackProposer) {
        // 0x68d30f47F19c07bCCEf4Ac7FAE2Dc12FCa3e0dC9
        DAO_FALLBACK_PROPOSER = _daoFallbackProposer;
        counter = 0;
    }

    /// @inheritdoc ITierRouter
    function getProvider(uint256) external view returns (address) {
        return address(this);
    }

    /// @inheritdoc ITierProvider
    function getTierIds() external pure returns (uint16[] memory tiers_) {
        tiers_ = new uint16[](3);
        tiers_[0] = LibTiers.TIER_SGX;
        tiers_[1] = LibTiers.TIER_GUARDIAN_MINORITY;
        tiers_[2] = LibTiers.TIER_GUARDIAN;
    }

    /// @inheritdoc ITierProvider
    function getMinTier(address _proposer, uint256 _rand) public pure override returns (uint16) {
        if (_proposer == DAO_FALLBACK_PROPOSER) {
            if (counter == 0) {
                counter ++;
                return LibTiers.TIER_ZKVM_SP1;
            } else if (counter == 1) {
                counter ++;
                return LibTiers.TIER_ZKVM_RISC0;
            } else {
                if (_rand % 1000 == 0) return LibTiers.TIER_ZKVM_RISC0;
                else if (_rand % 1000 == 1) return LibTiers.TIER_ZKVM_SP1;
                else return LibTiers.TIER_SGX;
            }
        }
        return LibTiers.TIER_SGX;
    }
}
