// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/src/Script.sol";
import "forge-std/src/console2.sol";

import "../contracts/tokenvault/ERC20Vault.sol";
import "../contracts/bridge/Bridge.sol";
import "../contracts/common/AddressManager.sol";

contract L2PostGenesisConfig is Script {
    // All following addresses are L2 addresses
    address public bridgedTKO = address(0); // TODO
    address public bridgedUSDC = address(0); // TODO

    address public erc20Vault = 0x1670000000000000000000000000000000000002;
    address public bridge = 0x1670000000000000000000000000000000000001;
    address public sam = 0x1670000000000000000000000000000000000006;

    function run() external view {
        require(bridgedTKO != address(0) && bridgedUSDC != address(0), "invalid address");
        ERC20Vault.CanonicalERC20 memory canonical;
        canonical.chainId = 1;

        canonical.addr = 0x10dea67478c5F8C5E2D90e5E9B26dBe60c54d800;
        canonical.decimals = 18;
        canonical.symbol = "TKO";
        canonical.name = "Taiko Token";

        // ERC20Vault(erc20Vault).changeBridgedToken(canonical, bridgedTKO);
        bytes memory call = abi.encodeCall(ERC20Vault.changeBridgedToken, (canonical, bridgedTKO));
        console2.log("--- erc20 change bridged TKO token");
        console2.log(erc20Vault);
        console.logBytes(call);

        canonical.addr = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        canonical.decimals = 6;
        canonical.symbol = "USDC";
        canonical.name = "USD Coin";
        // ERC20Vault(erc20Vault).changeBridgedToken(canonical, bridgedUSDC);
        call = abi.encodeCall(ERC20Vault.changeBridgedToken, (canonical, bridgedUSDC));
        console2.log("--- erc20 change USDC token");
        console2.log(erc20Vault);
        console.logBytes(call);

        call = abi.encodeCall(
            AddressManager.setAddress,
            (1, LibStrings.B_SIGNAL_SERVICE, 0x9e0a24964e5397B566c1ed39258e21aB5E35C77C)
        );
        console2.log("--- sam set signal service chain_id=1");
        console2.log(sam);
        console.logBytes(call);

        call = abi.encodeCall(
            AddressManager.setAddress,
            (1, LibStrings.B_BRIDGE, 0xd60247c6848B7Ca29eDdF63AA924E53dB6Ddd8EC)
        );
        console2.log("--- sam set bridge chain_id=1");
        console2.log(sam);
        console.logBytes(call);

        call = abi.encodeCall(
            AddressManager.setAddress,
            (1, LibStrings.B_ERC20_VAULT, 0x996282cA11E5DEb6B5D122CC3B9A1FcAAD4415Ab)
        );
        console2.log("--- sam set erc20 vault chain_id=1");
        console2.log(sam);
        console.logBytes(call);

        call = abi.encodeCall(
            AddressManager.setAddress,
            (1, LibStrings.B_ERC721_VAULT, 0x0b470dd3A0e1C41228856Fb319649E7c08f419Aa)
        );
        console2.log("--- sam set erc721 vault chain_id=1");
        console2.log(sam);
        console.logBytes(call);

        call = abi.encodeCall(
            AddressManager.setAddress,
            (1, LibStrings.B_ERC1155_VAULT, 0xaf145913EA4a56BE22E120ED9C24589659881702)
        );
        console2.log("--- sam set erc1155 vault chain_id=1");
        console2.log(sam);
        console.logBytes(call);

        call = abi.encodeCall(
            AddressManager.setAddress, (167_000, LibStrings.B_TAIKO_TOKEN, bridgedTKO)
        );
        console2.log("--- sam set tko token");
        console2.log(sam);
        console.logBytes(call);

        // Bridge(bridge).unpause();
        call = abi.encodeCall(EssentialContract.unpause, ());
        console2.log("--- bridge unpause");
        console2.log(bridge);
        console.logBytes(call);
    }
}
