// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../based/TaikoL2.sol";

/// @title MainnetTaikoL2
/// @custom:security-contact security@taiko.xyz
contract MainnetTaikoL2 is TaikoL2 {
    function ontakeForkHeight() public pure override returns (uint64) {
        return 538_304;
    }
}
