// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/src/Script.sol";
import "forge-std/src/console2.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../../contracts/team/tokenunlock/TokenUnlock.sol";

contract VestTokenUnlock is Script {
    using stdJson for string;

    struct VestingItem {
        address recipient;
        address proxy;
        uint256 vestAmount;
    }

    // On L2 it shall be: 0xA9d23408b9bA935c230493c40C73824Df71A0975
    ERC20 private tko = ERC20(0x10dea67478c5F8C5E2D90e5E9B26dBe60c54d800);

    function run() external {
        vm.startBroadcast();

        string memory path = "/script/tokenunlock/Vest.data.json";
        VestingItem[] memory items = abi.decode(
            vm.parseJson(vm.readFile(string.concat(vm.projectRoot(), path))), (VestingItem[])
        );

        uint256 total;
        for (uint256 i; i < items.length; i++) {
            // WARNING: JSON parsing seems to be buggy!!!
            // proxy is parsed as recipient and recipient is parsed as proxy.
            address recipient = items[i].proxy;
            address proxy = items[i].recipient;
            uint256 vestAmount = uint256(items[i].vestAmount);

            console2.log(items[i].recipient, items[i].proxy, items[i].vestAmount);

            TokenUnlock target = TokenUnlock(proxy);

            require(target.recipient() == recipient, "recipient mismatch");
            require(target.owner() == 0x9CBeE534B5D8a6280e01a14844Ee8aF350399C7F, "owner mismatch");

            total += SafeCastUpgradeable.toUint128(items[i].vestAmount * 1e18);
        }

        console2.log("total:", total / 1e18);
        require(tko.balanceOf(msg.sender) >= total, "insufficient TKO balance");

        // for (uint256 i; i < items.length; i++) {
        //     // This is needed due to some memory read operation! It seems forge/foundry
        //     // parseJson works in a way that we need to read into local variables from struct,
        //     // as it acts like a stack-like buffer read.
        //     address proxy = items[i].recipient;
        //     uint128 vestAmount = uint128(items[i].vestAmount * 1e18);

        //     tko.approve(proxy, vestAmount);
        //     TokenUnlock(proxy).vest(vestAmount);
        // }
        vm.stopBroadcast();
    }
}
