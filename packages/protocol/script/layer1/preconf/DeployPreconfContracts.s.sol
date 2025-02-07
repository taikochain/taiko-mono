// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../../BaseScript.sol";
import "src/layer1/preconf/impl/PreconfWhitelist.sol";
import "src/layer1/preconf/impl/PreconfRouter.sol";
import "src/shared/libs/LibStrings.sol";

/// @title DeployPreconfContracts
/// @notice This script deploys the Preconf contracts (Whitelist and Router)
contract DeployPreconfContracts is BaseScript {
    function run() external broadcast {
        // Validate required env vars
        address contractOwner = vm.envAddress("CONTRACT_OWNER");
        require(contractOwner != address(0), "invalid CONTRACT_OWNER");

        address sharedResolver = vm.envAddress("SHARED_RESOLVER");
        require(sharedResolver != address(0), "invalid SHARED_RESOLVER");

        address taikoWrapper = vm.envAddress("TAIKO_WRAPPER");
        require(taikoWrapper != address(0), "invalid TAIKO_WRAPPER");

        address preconfWhitelist = vm.envAddress("PRECONF_WHITELIST");
        require(preconfWhitelist != address(0), "invalid PRECONF_WHITELIST");

        // Deploy PreconfWhitelist
        deploy(
            LibStrings.B_PRECONF_WHITELIST,
            address(new PreconfWhitelist(sharedResolver)),
            abi.encodeCall(PreconfWhitelist.init, (contractOwner))
        );

        // Deploy PreconfRouter
        deploy(
            LibStrings.B_PRECONF_ROUTER,
            address(new PreconfRouter(sharedResolver, taikoWrapper, preconfWhitelist)),
            abi.encodeCall(PreconfRouter.init, (contractOwner))
        );
    }
}
