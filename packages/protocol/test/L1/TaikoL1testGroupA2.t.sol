// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "./TaikoL1TestGroupBase.sol";

contract TaikoL1ForkA2 is TaikoL1 {
    function getConfig() public pure override returns (TaikoData.Config memory config) {
        config = TaikoL1.getConfig();
        config.maxBlocksToVerify = 0;
        config.blockMaxProposals = 10;
        config.blockRingBufferSize = 15;
        config.stateRootSyncInternal = 2;
        config.forkHeight = 0;
        // config.forkHeight = 1; // works the same
    }
}

contract TaikoL1TestGroupA2 is TaikoL1TestGroupBase {
    function deployTaikoL1() internal override returns (TaikoL1) {
        return TaikoL1(
            payable(deployProxy({ name: "taiko", impl: address(new TaikoL1ForkA2()), data: "" }))
        );
    }

    // Test summary:
    // - Use the v2 immediately - forkHeight = 0 or 1
    // - propose and prove 5 blocks
    // - try to verify more than 5 blocks to verify all 5 blocks are verified.
    function test_taikoL1_group_a2_case_1() external {
        vm.warp(1_000_000);
        mine(1);
        printBlockAndTrans(0);

        giveEthAndTko(Alice, 10_000 ether, 1000 ether);

        bytes32 parentHash = GENESIS_BLOCK_HASH;

        proposeBlock(Alice, TaikoErrors.L1_FORK_ERROR.selector);

        TaikoData.BlockParams2 memory params;
        for (uint64 i = 1; i <= 5; ++i) {
            TaikoData.BlockMetadata2 memory meta2 = proposeBlock2(Alice, params, "");
            printBlockAndTrans(meta2.id);
            TaikoData.Block memory blk = L1.getBlock(i);
            assertEq(blk.livenessBond, 0);
            assertEq(blk.assignedProver, address(0));
            assertEq(blk.anchorBlockId, block.number - 1);
            assertEq(blk.timestamp, block.timestamp);

            // Prove the block
            bytes32 blockHash = bytes32(uint256(10_000 + i));
            bytes32 stateRoot = bytes32(uint256(20_000 + i));

            mineAndWrap(10 seconds);

            proveBlock2(Alice, meta2, parentHash, blockHash, stateRoot, meta2.minTier, "");
            parentHash = blockHash;

            printBlockAndTrans(meta2.id);
            blk = L1.getBlock(i);
            assertEq(blk.livenessBond, 0);
            assertEq(blk.assignedProver, address(0));
        }

        console2.log("====== Verify many blocks");
        mineAndWrap(7 days);
        verifyBlock(10);
        {
            (, TaikoData.SlotB memory b) = L1.getStateVariables();
            assertEq(b.lastVerifiedBlockId, 5);

            assertEq(tko.balanceOf(Alice), 10_000 ether);
        }
    }

    // Test summary:
    // - Use the v2 immediately - forkHeight = 0 or 1
    // - propose and prove 5 blocks
    // - try to verify more than 5 blocks to verify all 5 blocks are verified.
    function test_taikoL1_group_a2_case_2() external {
        vm.warp(1_000_000);
        mine(1);
        printBlockAndTrans(0);

        giveEthAndTko(Alice, 10_000 ether, 1000 ether);

        TaikoData.Config memory config = L1.getConfig();

        // Propose the first block with default parameters
        TaikoData.BlockParams2 memory params = TaikoData.BlockParams2({
            coinbase: address(0),
            extraData: 0,
            parentMetaHash: 0,
            anchorBlockId: 0,
            timestamp: 0
        });
        TaikoData.BlockMetadata2 memory meta = proposeBlock2(Alice, params, "");

        assertEq(meta.id, 1);
        assertTrue(meta.difficulty != 0);
        assertEq(meta.timestamp, block.timestamp);
        assertEq(meta.anchorBlockId, block.number - 1);
        assertEq(meta.anchorBlockHash, blockhash(block.number - 1));
        assertEq(meta.livenessBond, config.livenessBond);
        assertEq(meta.coinbase, Alice);
        assertEq(meta.parentMetaHash, bytes32(uint256(1)));
        assertEq(meta.extraData, params.extraData);

        TaikoData.Block memory blk = L1.getBlock(1);
        assertEq(blk.blockId, 1);
        assertEq(blk.proposedAt, block.timestamp);
        assertEq(blk.proposedIn, block.number);
        assertEq(blk.assignedProver, address(0));
        assertEq(blk.livenessBond, 0);
        assertEq(blk.anchorBlockId, meta.anchorBlockId);
        assertEq(blk.timestamp, meta.timestamp);
        assertEq(blk.nextTransitionId, 1);
        assertEq(blk.verifiedTransitionId, 0);
        assertEq(blk.metaHash, keccak256(abi.encode(meta)));

        // mine 100 blocks
        vm.roll(100);
        vm.warp(100 days);

        // Propose the second block with custom parameters

        params = TaikoData.BlockParams2({
            coinbase: Bob,
            extraData: bytes32(uint256(123)),
            parentMetaHash: 0,
            anchorBlockId: 90,
            timestamp: uint64(block.timestamp - 100)
        });
        meta = proposeBlock2(Alice, params, "");

        assertEq(meta.id, 2);
        assertTrue(meta.difficulty != 0);
        assertEq(meta.timestamp, block.timestamp - 100);
        assertEq(meta.anchorBlockId, 90);
        assertEq(meta.anchorBlockHash, blockhash(90));
        assertEq(meta.livenessBond, config.livenessBond);
        assertEq(meta.coinbase, Bob);
        assertEq(meta.parentMetaHash, blk.metaHash);
        assertEq(meta.extraData, params.extraData);

        blk = L1.getBlock(2);
        assertEq(blk.blockId, 2);
        assertEq(blk.proposedAt, block.timestamp);
        assertEq(blk.proposedIn, block.number);
        assertEq(blk.assignedProver, address(0));
        assertEq(blk.livenessBond, 0);
        assertEq(blk.anchorBlockId, meta.anchorBlockId);
        assertEq(blk.timestamp, meta.timestamp);
        assertEq(blk.nextTransitionId, 1);
        assertEq(blk.verifiedTransitionId, 0);
        assertEq(blk.metaHash, keccak256(abi.encode(meta)));

        for (uint256 i = 0; i < 3; ++i) {
            TaikoData.BlockParams2 memory params2;
            proposeBlock2(Alice, params2, "");
        }
    }
}
