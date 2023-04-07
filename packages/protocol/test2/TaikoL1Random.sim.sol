// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {AddressManager} from "../contracts/thirdparty/AddressManager.sol";
import {FoundryRandom} from "foundry-random/FoundryRandom.sol";
import {TaikoConfig} from "../contracts/L1/TaikoConfig.sol";
import {TaikoData} from "../contracts/L1/TaikoData.sol";
import {TaikoL1} from "../contracts/L1/TaikoL1.sol";
import {TaikoToken} from "../contracts/L1/TaikoToken.sol";
import {SignalService} from "../contracts/signal/SignalService.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {TaikoL1TestBase} from "./TaikoL1TestBase.t.sol";

// forge test  -vvv  --match-test testGeneratingManyRandomBlocks  --block-gas-limit  3000000000 > log.csv
contract TaikoL1_b is TaikoL1 {
    function getConfig()
        public
        pure
        override
        returns (TaikoData.Config memory config)
    {
        config = TaikoConfig.getConfig();

        config.enableTokenomics = true;
        config.txListCacheExpiry = 5 minutes;
        config.proposerDepositPctg = 0;
        config.maxVerificationsPerTx = 0;
        config.enableSoloProposer = false;
        config.enableOracleProver = false;
        config.maxNumProposedBlocks = 10;
        config.ringBufferSize = 12;
    }
}

contract Verifier {
    fallback(bytes calldata) external returns (bytes memory) {
        return bytes.concat(keccak256("taiko"));
    }
}

contract TaikoL1RandomTest is TaikoL1TestBase, FoundryRandom {
    function deployTaikoL1() internal override returns (TaikoL1 taikoL1) {
        taikoL1 = new TaikoL1_b();
    }

    function setUp() public override {
        TaikoL1TestBase.setUp();
        _registerAddress(
            string(abi.encodePacked("verifier_", uint16(100))),
            address(new Verifier())
        );
    }

    function testGeneratingManyRandomBlocks() external {
        uint256 randomNum = randomNumber(12);

        _depositTaikoToken(Alice, 1E6 * 1E8, 10000 ether);

        bytes32 parentHash = GENESIS_BLOCK_HASH;
        printBlockInfoHeader();
        printBlockInfo();

        for (
            uint256 blockId = 1;
            blockId < conf.maxNumProposedBlocks * 1;
            blockId++
        ) {
            TaikoData.BlockMetadata memory meta = proposeBlock(Alice, 1024);
            printBlockInfo();

            bytes32 blockHash = bytes32(1E10 + blockId);
            bytes32 signalRoot = bytes32(1E9 + blockId);
            proveBlock(Bob, meta, parentHash, blockHash, signalRoot);
            parentHash = blockHash;

            vm.warp(block.timestamp + 20);
            vm.roll(block.number);
        }
    }

    function printBlockInfoHeader() internal {
        TaikoData.StateVariables memory vars = L1.getStateVariables();
        (uint256 fee, ) = L1.getBlockFee();
        string memory str = string.concat(
            "\nlogCount,",
            "time,",
            "lastVerifiedBlockId,",
            "numBlocks,",
            "feeBase,",
            "fee,",
            "lastProposedAt"
        );
        console2.log(str);
    }

    function printBlockInfo() internal {
        TaikoData.StateVariables memory vars = L1.getStateVariables();
        (uint256 fee, ) = L1.getBlockFee();
        string memory str = string.concat(
            Strings.toString(logCount++),
            ",",
            Strings.toString(block.timestamp),
            ",",
            Strings.toString(vars.lastVerifiedBlockId),
            ",",
            Strings.toString(vars.numBlocks),
            ",",
            Strings.toString(vars.feeBase),
            ",",
            Strings.toString(fee),
            ",",
            Strings.toString(vars.lastProposedAt)
        );
        console2.log(str);
    }
}
