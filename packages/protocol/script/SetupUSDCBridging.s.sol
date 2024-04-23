// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../test/DeployCapability.sol";
import "../contracts/tokenvault/ERC20Vault.sol";

contract SetupUSDCBridging is DeployCapability {
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;

    uint256 public privateKey = vm.envUint("PRIVATE_KEY");
    address public erc20VaultOnL2 = vm.envAddress("ERC20_VAULT_ON_L2");
    address public usdcOnL2 = vm.envAddress("USDC_ADDRESS_ON_L2");

    function run() external {
        require(erc20VaultOnL2 != address(0) && usdcOnL2 != address(0), "invalid params");

        ERC20Vault vault = ERC20Vault(erc20VaultOnL2);

        address currBridgedtoken = vault.canonicalToBridged(1, USDC);
        console2.log("current btoken for usdc:", currBridgedtoken);

        ERC20Vault.CanonicalERC20 memory ctoken = ERC20Vault.CanonicalERC20({
            chainId: 1,
            addr: USDC,
            decimals: 6,
            symbol: "USDC",
            name: "USD Coin"
        });

        vm.startBroadcast(privateKey);
        vault.changeBridgedToken(ctoken, usdcOnL2);
        vault.unpause();
        vm.stopBroadcast();

        address newBridgedToken = vault.canonicalToBridged(1, USDC);
        console2.log("new btoken for usdc:", newBridgedToken);

        require(usdcOnL2 == newBridgedToken, "unexpected result");
    }
}
