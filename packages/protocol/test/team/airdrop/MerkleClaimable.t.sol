// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC20Airdrop as Airdrop } from
    "../../../contracts/team/airdrop/ERC20Airdrop.sol";
import { MerkleClaimable } from
    "../../../contracts/team/airdrop/MerkleClaimable.sol";
import { Test } from "forge-std/Test.sol";
import { ERC20 } from
    "lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import { console2 } from "forge-std/console2.sol";
import { ERC20Upgradeable } from
    "lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import { SafeERC20Upgradeable } from
    "lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/utils/SafeERC20Upgradeable.sol";

contract MyERC20 is ERC20 {
    constructor(address owner) ERC20("Taiko Token", "TKO") {
        _mint(owner, 1_000_000_000e18);
    }
}
// TODO(dani): only unit-test MerkleClaimable, with an empty `_claimWithData`
// function.

contract TestERC20Airdrop is Test {
    address internal Alice = vm.addr(0x1);
    address internal Bob = vm.addr(0x2);
    address internal Carol = vm.addr(0x3);
    address internal Dave = vm.addr(0x4);
    address internal Elvis = vm.addr(0x5);
    address internal ERC20VaultDAO = vm.addr(0x6);

    bytes32 merkleRoot =
        0x73a7330a8657ad864b954215a8f636bb3709d2edea60bcd4fcb8a448dbc6d70f;

    Airdrop airdrop = new Airdrop();

    ERC20 tko = new MyERC20(address(ERC20VaultDAO));

    function setUp() public {
        airdrop.init(0, 0, merkleRoot, address(tko), ERC20VaultDAO);

        airdrop.setConfig(
            uint128(block.timestamp + 10),
            uint128(block.timestamp + 10_000),
            merkleRoot
        );

        vm.roll(block.number + 1);
        vm.warp(block.timestamp + 12);

        vm.prank(ERC20VaultDAO, ERC20VaultDAO);
        MyERC20(address(tko)).approve(address(airdrop), 1_000_000_000e18);
    }

    function test_claim_but_claim_not_ongoing_yet() public {
        vm.warp(1);
        bytes32[] memory merkleProof = new bytes32[](3);
        merkleProof[0] =
            0x4014b456db813d18e801fe3b30bbe14542c9c84caa9a92b643f7f46849283077;
        merkleProof[1] =
            0xfc2f09b34fb9437f9bde16049237a2ab3caa6d772bd794da57a8c314aea22b3f;
        merkleProof[2] =
            0xc13844b93533d8aec9c7c86a3d9399efb4e834f4069b9fd8a88e7290be612d05;

        vm.expectRevert(MerkleClaimable.CLAIM_NOT_ONGOING.selector);
        vm.prank(Alice, Alice);
        airdrop.claim(abi.encode(Alice, 100), merkleProof);
    }

    function test_claim_but_claim_not_ongoing_anymore() public {
        vm.warp(uint128(block.timestamp + 11_000));

        bytes32[] memory merkleProof = new bytes32[](3);
        merkleProof[0] =
            0x4014b456db813d18e801fe3b30bbe14542c9c84caa9a92b643f7f46849283077;
        merkleProof[1] =
            0xfc2f09b34fb9437f9bde16049237a2ab3caa6d772bd794da57a8c314aea22b3f;
        merkleProof[2] =
            0xc13844b93533d8aec9c7c86a3d9399efb4e834f4069b9fd8a88e7290be612d05;

        vm.expectRevert(MerkleClaimable.CLAIM_NOT_ONGOING.selector);
        vm.prank(Alice, Alice);
        airdrop.claim(abi.encode(Alice, 100), merkleProof);
    }

    function test_claim_but_with_invalid_allowance() public {
        vm.warp(uint128(block.timestamp + 11));
        // These proofs are coming from 'pnpm run buildMerkle'
        bytes32[] memory merkleProof = new bytes32[](3);
        merkleProof[0] =
            0x4014b456db813d18e801fe3b30bbe14542c9c84caa9a92b643f7f46849283077;
        merkleProof[1] =
            0xfc2f09b34fb9437f9bde16049237a2ab3caa6d772bd794da57a8c314aea22b3f;
        merkleProof[2] =
            0xc13844b93533d8aec9c7c86a3d9399efb4e834f4069b9fd8a88e7290be612d05;

        vm.expectRevert(MerkleClaimable.INVALID_PROOF.selector);
        vm.prank(Alice, Alice);
        airdrop.claim(abi.encode(Alice, 200), merkleProof);
    }

    function test_claim() public {
        vm.warp(uint128(block.timestamp + 11));
        // These proofs are coming from 'pnpm run buildMerkle'
        bytes32[] memory merkleProof = new bytes32[](3);
        merkleProof[0] =
            0x4014b456db813d18e801fe3b30bbe14542c9c84caa9a92b643f7f46849283077;
        merkleProof[1] =
            0xfc2f09b34fb9437f9bde16049237a2ab3caa6d772bd794da57a8c314aea22b3f;
        merkleProof[2] =
            0xc13844b93533d8aec9c7c86a3d9399efb4e834f4069b9fd8a88e7290be612d05;

        vm.prank(Alice, Alice);
        airdrop.claim(abi.encode(Alice, 100), merkleProof);

        // Check Alice balance
        assertEq(tko.balanceOf(Alice), 100);
    }

    function test_claim_with_same_proofs_twice() public {
        vm.warp(uint128(block.timestamp + 11));
        // These proofs are coming from 'pnpm run buildMerkle'
        bytes32[] memory merkleProof = new bytes32[](3);
        merkleProof[0] =
            0x4014b456db813d18e801fe3b30bbe14542c9c84caa9a92b643f7f46849283077;
        merkleProof[1] =
            0xfc2f09b34fb9437f9bde16049237a2ab3caa6d772bd794da57a8c314aea22b3f;
        merkleProof[2] =
            0xc13844b93533d8aec9c7c86a3d9399efb4e834f4069b9fd8a88e7290be612d05;

        vm.prank(Alice, Alice);
        airdrop.claim(abi.encode(Alice, 100), merkleProof);

        // Check Alice balance
        assertEq(tko.balanceOf(Alice), 100);

        vm.expectRevert(MerkleClaimable.CLAIMED_ALREADY.selector);
        vm.prank(Alice, Alice);
        airdrop.claim(abi.encode(Alice, 100), merkleProof);
    }
}
