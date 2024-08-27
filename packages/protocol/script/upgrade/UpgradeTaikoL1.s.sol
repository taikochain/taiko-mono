// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/src/Script.sol";
import "forge-std/src/console2.sol";

import "./UpgradeScript.s.sol";
import "../../contracts/devnet/DevnetTaikoL1.sol";

contract UpgradeTaikoL1 is UpgradeScript {
    function run() external setUp {
        upgrade("DevnetTaikoL1", address(new DevnetTaikoL1()));
    }
}
