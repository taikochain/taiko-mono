// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { Test, console } from "forge-std/src/Test.sol";
import { TaikoonToken } from "../../contracts/taikoon/TaikoonToken.sol";
import { TaikoonTokenV2 } from "../../contracts/taikoon/TaikoonTokenV2.sol";
import { Merkle } from "murky/Merkle.sol";
import "forge-std/src/StdJson.sol";
import { UtilsScript } from "../../script/taikoon/sol/Utils.s.sol";
import { MockBlacklist } from "../util/Blacklist.sol";


import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract UpgradeableTest is Test {
    using stdJson for string;

    UtilsScript public utils;

    TaikoonToken public token;

    address public owner = vm.addr(0x5);

    address[3] public minters = [vm.addr(0x1), vm.addr(0x2), vm.addr(0x3)];
    bytes32[] public leaves = new bytes32[](minters.length);

    uint256 constant FREE_MINTS = 5;

    MockBlacklist public blacklist;

    Merkle tree = new Merkle();

    function setUp() public {
        utils = new UtilsScript();
        utils.setUp();
        blacklist = new MockBlacklist();

        // create whitelist merkle tree
        vm.startBroadcast(owner);
        bytes32 root = tree.getRoot(leaves);

        // deploy token with empty root
        address impl = address(new TaikoonToken());


        address proxy = address(
            new ERC1967Proxy(
                impl,
                abi.encodeCall(TaikoonToken.initialize, (address(0), "ipfs://", root, blacklist))
            )
        );

        token = TaikoonToken(proxy);

        address v2 = address(new TaikoonTokenV2());





       new ERC1967Proxy(
                impl,
                abi.encodeCall(TaikoonToken.initialize, (address(0), "ipfs://", root, blacklist))
            ).upgradeTo(v2);

        vm.stopBroadcast();
    }
}
