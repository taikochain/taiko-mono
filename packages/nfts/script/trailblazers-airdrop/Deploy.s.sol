// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import { UtilsScript } from "./Utils.s.sol";
import { Script, console } from "forge-std/src/Script.sol";
import { Merkle } from "murky/Merkle.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { TrailblazersBadges } from "../../contracts/trailblazers-badges/TrailblazersBadges.sol";
import { IMinimalBlacklist } from "@taiko/blacklist/IMinimalBlacklist.sol";
import { AirdropVault } from "../../contracts/trailblazers-airdrop/AirdropVault.sol";
import { ERC20Airdrop } from "../../contracts/trailblazers-airdrop/ERC20Airdrop.sol";
import { ERC20Mock } from "../../test/util/MockTokens.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract DeployScript is Script {
    UtilsScript public utils;
    string public jsonLocation;
    uint256 public deployerPrivateKey;
    address public deployerAddress;

    IMinimalBlacklist blacklist = IMinimalBlacklist(0xe61E9034b5633977eC98E302b33e321e8140F105);


    ERC20Airdrop public airdrop;
    AirdropVault public vault;
    uint256 constant TOTAL_AVAILABLE_FUNDS = 1000 ether;

    uint256 constant CLAIM_AMOUNT = 10 ether;

    // hekla test root
    bytes32 public merkleRoot = 0xea5b2299e76b4860965e9059388d021145269c96b816b07a808ff391cd80753e;


    // rewards token
    ERC20Upgradeable public erc20;

    // start and end times for the claim
    uint256 constant CLAIM_START = 100;
    uint256 constant CLAIM_END = 200;


    function setUp() public {
        utils = new UtilsScript();
        utils.setUp();

        jsonLocation = utils.getContractJsonLocation();
        deployerPrivateKey = utils.getPrivateKey();
        deployerAddress = utils.getAddress();

                    vm.startBroadcast(deployerPrivateKey);

        // deploy the vault contract
        vault = new AirdropVault(erc20);
        console.log("Deployed AirdropVault to:", address(vault));


        if (block.chainid != 167_000){

            // not mainnet, create mock contracts
            ERC20Mock mockERC20 = new ERC20Mock();

            mockERC20.mint(address(vault), TOTAL_AVAILABLE_FUNDS);


            erc20 = ERC20Upgradeable(address(mockERC20));
        }

                    vm.stopBroadcast();

    }

    function run() public {
        string memory jsonRoot = "root";

        vm.startBroadcast(deployerPrivateKey);


        // deploy token with empty root
        address impl = address(new ERC20Airdrop());
        address proxy = address(
            new ERC1967Proxy(
                impl,
                abi.encodeCall(
                    ERC20Airdrop.initialize,
                    (CLAIM_START, CLAIM_END,
                    merkleRoot,
                    erc20, blacklist, vault)
                )
            )
        );

        airdrop = ERC20Airdrop(proxy);

        console.log("Deployed ERC20Airdrop to:", address(airdrop));

        vm.serializeBytes32(jsonRoot, "MerkleRoot", merkleRoot);
        vm.serializeAddress(jsonRoot, "ERC20Airdrop", address(airdrop));

        string memory finalJson =
            vm.serializeAddress(jsonRoot, "AirdropVault", address(vault));
        vm.writeJson(finalJson, jsonLocation);

        vm.stopBroadcast();
    }
}
