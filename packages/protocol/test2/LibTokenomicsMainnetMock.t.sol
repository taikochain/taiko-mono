// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

// Uncomment if you want to compare fee/vs reward
import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {AddressManager} from "../contracts/thirdparty/AddressManager.sol";
import {TaikoConfig} from "../contracts/L1/TaikoConfig.sol";
import {TaikoData} from "../contracts/L1/TaikoData.sol";
import {TaikoL1} from "../contracts/L1/TaikoL1.sol";
import {TaikoToken} from "../contracts/L1/TaikoToken.sol";
import {SignalService} from "../contracts/signal/SignalService.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {TaikoL1TestBase} from "./TaikoL1TestBase.t.sol";

contract TaikoL1WithNonMintingConfig is TaikoL1 {
    function getConfig()
        public
        pure
        override
        returns (TaikoData.Config memory config)
    {
        config = TaikoConfig.getConfig();

        config.txListCacheExpiry = 5 minutes;
        config.maxVerificationsPerTx = 0;
        config.enableSoloProposer = false;
        config.enableOracleProver = false;
        config.maxNumProposedBlocks = 200;
        config.ringBufferSize = 240;
    }
}

// Since the fee/reward calculation heavily depends on the baseFeeProof and the proofTime
// we need to simulate proposing/proving so that can calculate them.
contract LibL1TokenomicsTest is TaikoL1TestBase {
    function deployTaikoL1() internal override returns (TaikoL1 taikoL1) {
        taikoL1 = new TaikoL1WithNonMintingConfig();
    }

    function setUp() public override {
        TaikoL1TestBase.setUp();

        _depositTaikoToken(Alice, 1E6 * 1E8, 100 ether);
        _depositTaikoToken(Bob, 1E6 * 1E8, 100 ether);
        _depositTaikoToken(Carol, 1E6 * 1E8, 100 ether);
    }

    /// @dev To mock a mainnet: set proofTImeTarget in TaikoConfig.sol to 30 mins and run this test

    /// @dev A possible (close to) mainnet scenarios is the following:
    //// - Blocks ever 10 seconds proposed
    //// - Proofs coming shifted slightly below 30 min / proposed block afterwards
    //// Expected result: Withdrawals and deposits are in balance but keep shrinking since quicker proofTime
    function xtest_possible_mainnet_scenario_proof_time_below_target()
        external
    {
        vm.pauseGasMetering();
        mine(1);

        _depositTaikoToken(Alice, 1E8 * 1E8, 1000 ether);
        _depositTaikoToken(Bob, 1E8 * 1E8, 1000 ether);
        _depositTaikoToken(Carol, 1E8 * 1E8, 1000 ether);

        // Check balances
        uint256 Alice_start_balance = L1.getBalance(Alice);
        uint256 Bob_start_balance = L1.getBalance(Bob);

        // Can play to adjust
        uint32 iterationCnt = 5000;
        uint8 proofTime = 179; // When proofs are coming, 179 means 1790 sec

        TaikoData.BlockMetadata[] memory meta = new TaikoData.BlockMetadata[](
            iterationCnt
        );
        uint64[] memory proposedAt = new uint64[](iterationCnt);
        bytes32[] memory parentHashes = new bytes32[](iterationCnt);
        bytes32[] memory blockHashes = new bytes32[](iterationCnt);
        bytes32[] memory signalRoots = new bytes32[](iterationCnt);

        bytes32 parentHash = GENESIS_BLOCK_HASH;
        console2.logBytes32(parentHash);

        // Run another session with huge times
        for (uint256 blockId = 1; blockId < iterationCnt; blockId++) {
            meta[blockId] = proposeBlock(Alice, 1024);
            proposedAt[blockId] = (uint64(block.timestamp));
            printVariables("after propose");
            blockHashes[blockId] = bytes32(1E10 + blockId);
            signalRoots[blockId] = bytes32(1E9 + blockId);

            if (blockId > proofTime) {
                //Start proving with an offset
                proveBlock(
                    Bob,
                    meta[blockId - proofTime],
                    parentHashes[blockId - proofTime],
                    blockHashes[blockId - proofTime],
                    signalRoots[blockId - proofTime]
                );

                uint64 provenAt = uint64(block.timestamp);
                console2.log(
                    "Proof reward is:",
                    L1.getProofReward(provenAt, proposedAt[blockId - proofTime])
                );
                verifyBlock(Carol, 1);
            }

            mine_every_10_sec();

            parentHashes[blockId] = parentHash;
            parentHash = blockHashes[blockId];
        }

        //Check end balances
        uint256 deposits = Alice_start_balance - L1.getBalance(Alice);
        uint256 withdrawals = L1.getBalance(Bob) - Bob_start_balance;

        //Check end balances
        deposits = Alice_start_balance - L1.getBalance(Alice);
        withdrawals = L1.getBalance(Bob) - Bob_start_balance;

        console2.log("Deposits:", deposits);
        console2.log("withdrawals:", withdrawals);
        // Assert their balance changed relatively the same way
        // 1e18 == within 100 % delta -> 1e17 10%, let's see if this is within that range
        assertApproxEqRel(deposits, withdrawals, 1e17);
    }

    /// @dev A possible (close to) mainnet scenarios is the following:
    //// - Blocks ever 10 seconds proposed
    //// - Proofs coming shifted 30 min / proposed block afterwards
    //// Expected result: Withdrawals and deposits are in balance and since it is coming at proofTimeTarget stays the same
    function xtest_possible_mainnet_scenario_proof_time_at_target() external {
        vm.pauseGasMetering();
        mine(1);

        _depositTaikoToken(Alice, 1E8 * 1E8, 1000 ether);
        _depositTaikoToken(Bob, 1E8 * 1E8, 1000 ether);
        _depositTaikoToken(Carol, 1E8 * 1E8, 1000 ether);

        // Check balances
        uint256 Alice_start_balance = L1.getBalance(Alice);
        uint256 Bob_start_balance = L1.getBalance(Bob);

        // Can play to adjust
        uint32 iterationCnt = 5000;
        uint32 proofTime = 180; // When proofs are coming, 180 means 1800 sec

        /// 1.step: mine 180 blocks without proofs - then start prooving with a -180 offset
        TaikoData.BlockMetadata[] memory meta = new TaikoData.BlockMetadata[](
            iterationCnt
        );
        uint64[] memory proposedAt = new uint64[](iterationCnt);
        bytes32[] memory parentHashes = new bytes32[](iterationCnt);
        bytes32[] memory blockHashes = new bytes32[](iterationCnt);
        bytes32[] memory signalRoots = new bytes32[](iterationCnt);

        bytes32 parentHash = GENESIS_BLOCK_HASH;
        console2.logBytes32(parentHash);

        for (uint256 blockId = 1; blockId < iterationCnt; blockId++) {
            meta[blockId] = proposeBlock(Alice, 1024);
            proposedAt[blockId] = (uint64(block.timestamp));
            printVariables("after propose");
            blockHashes[blockId] = bytes32(1E10 + blockId);
            signalRoots[blockId] = bytes32(1E9 + blockId);

            if (blockId > proofTime) {
                //Start proving with an offset
                proveBlock(
                    Bob,
                    meta[blockId - proofTime],
                    parentHashes[blockId - proofTime],
                    blockHashes[blockId - proofTime],
                    signalRoots[blockId - proofTime]
                );

                uint64 provenAt = uint64(block.timestamp);
                console2.log(
                    "Proof reward is:",
                    L1.getProofReward(provenAt, proposedAt[blockId - proofTime])
                );
                verifyBlock(Carol, 1);
            }

            mine_every_10_sec();

            parentHashes[blockId] = parentHash;
            parentHash = blockHashes[blockId];
        }

        //Check end balances
        uint256 deposits = Alice_start_balance - L1.getBalance(Alice);
        uint256 withdrawals = L1.getBalance(Bob) - Bob_start_balance;

        //Check end balances
        deposits = Alice_start_balance - L1.getBalance(Alice);
        withdrawals = L1.getBalance(Bob) - Bob_start_balance;

        console2.log("Deposits:", deposits);
        console2.log("withdrawals:", withdrawals);
        // Assert their balance changed relatively the same way
        // 1e18 == within 100 % delta -> 1e17 10%, let's see if this is within that range
        assertApproxEqRel(deposits, withdrawals, 1e17);
    }

    /// @dev A possible (close to) mainnet scenarios is the following:
    //// - Blocks ever 10 seconds proposed
    //// - Proofs coming shifted slightly above 30 min / proposed block afterwards
    //// Expected result: Withdrawals and deposits are in balance but fees keep growing
    function test_possible_mainnet_scenario_proof_time_above_target() external {
        vm.pauseGasMetering();
        mine(1);

        _depositTaikoToken(Alice, 1E8 * 1E8, 1000 ether);
        _depositTaikoToken(Bob, 1E8 * 1E8, 1000 ether);
        _depositTaikoToken(Carol, 1E8 * 1E8, 1000 ether);

        // Check balances
        uint256 Alice_start_balance = L1.getBalance(Alice);
        uint256 Bob_start_balance = L1.getBalance(Bob);

        // Can play to adjust
        uint32 iterationCnt = 5000;
        uint8 proofTime = 181; // When proofs are coming, 181 means 1810 sec

        TaikoData.BlockMetadata[] memory meta = new TaikoData.BlockMetadata[](
            iterationCnt
        );
        uint64[] memory proposedAt = new uint64[](iterationCnt);
        bytes32[] memory parentHashes = new bytes32[](iterationCnt);
        bytes32[] memory blockHashes = new bytes32[](iterationCnt);
        bytes32[] memory signalRoots = new bytes32[](iterationCnt);

        bytes32 parentHash = GENESIS_BLOCK_HASH;
        console2.logBytes32(parentHash);

        for (uint256 blockId = 1; blockId < iterationCnt; blockId++) {
            meta[blockId] = proposeBlock(Alice, 1024);
            proposedAt[blockId] = (uint64(block.timestamp));
            printVariables("after propose");
            blockHashes[blockId] = bytes32(1E10 + blockId);
            signalRoots[blockId] = bytes32(1E9 + blockId);

            if (blockId > proofTime) {
                //Start proving with an offset
                proveBlock(
                    Bob,
                    meta[blockId - proofTime],
                    parentHashes[blockId - proofTime],
                    blockHashes[blockId - proofTime],
                    signalRoots[blockId - proofTime]
                );

                uint64 provenAt = uint64(block.timestamp);
                console2.log(
                    "Proof reward is:",
                    L1.getProofReward(provenAt, proposedAt[blockId - proofTime])
                );
                verifyBlock(Carol, 1);
            }

            mine_every_10_sec();

            parentHashes[blockId] = parentHash;
            parentHash = blockHashes[blockId];
        }

        //Check end balances
        uint256 deposits = Alice_start_balance - L1.getBalance(Alice);
        uint256 withdrawals = L1.getBalance(Bob) - Bob_start_balance;

        //Check end balances
        deposits = Alice_start_balance - L1.getBalance(Alice);
        withdrawals = L1.getBalance(Bob) - Bob_start_balance;

        console2.log("Deposits:", deposits);
        console2.log("withdrawals:", withdrawals);
        // Assert their balance changed relatively the same way
        // 1e18 == within 100 % delta -> 1e17 10%, let's see if this is within that range
        assertApproxEqRel(deposits, withdrawals, 1e17);
    }

    // Currently set to 85s proofTimeTarget
    function mine_every_10_sec() internal {
        vm.warp(block.timestamp + 10);
        vm.roll(block.number + 1);
    }
}
