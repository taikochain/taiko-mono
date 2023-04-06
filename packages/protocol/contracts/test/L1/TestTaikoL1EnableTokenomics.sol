// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {TaikoL1} from "../../L1/TaikoL1.sol";
import {TaikoData} from "../../L1/TaikoData.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

contract TestTaikoL1EnableTokenomics is TaikoL1 {
    function getConfig()
        public
        pure
        override
        returns (TaikoData.Config memory config)
    {
        config.chainId = 167;
        // up to 2048 pending blocks
        config.maxNumProposedBlocks = 6;
        config.ringBufferSize = 8;
        // This number is calculated from maxNumProposedBlocks to make
        // the 'the maximum value of the multiplier' close to 20.0
        config.maxVerificationsPerTx = 0; // dont verify blocks automatically
        config.blockMaxGasLimit = 30000000;
        config.maxTransactionsPerBlock = 20;
        config.maxBytesPerTxList = 120000;
        config.minTxGasLimit = 21000;
        config.slotSmoothingFactor = 590000;
        config.rewardBurnBips = 100; // 100 basis points or 1%
        config.proposerDepositPctg = 25; // 25%

        // Moving average factors
        config.feeBaseMAF = 1024;

        config.enableTokenomics = true;
        config.skipZKPVerification = true;

        config.proposingConfig = TaikoData.FeeConfig({
            avgTimeMAF: 64,
            dampingFactorBips: 5000
        });

        config.provingConfig = TaikoData.FeeConfig({
            avgTimeMAF: 64,
            dampingFactorBips: 5000
        });
    }

    // The old implementation that is also used in hardhat tests.
    function keyForName(
        uint256 chainId,
        string memory name
    ) public pure override returns (string memory key) {
        key = string.concat(Strings.toString(chainId), ".", name);
    }
}
