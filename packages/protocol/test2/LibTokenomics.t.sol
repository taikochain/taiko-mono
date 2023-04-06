// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {TaikoData} from "../contracts/L1/TaikoData.sol";
import {LibTokenomics} from "../contracts/L1/libs/LibTokenomics.sol";
import {
    SafeCastUpgradeable
} from "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";

contract TestLibTokenomics is Test {
    using SafeCastUpgradeable for uint256;

    struct FeeConfig {
        uint64 avgTimeMAF;
        uint64 avgTimeCap;
        uint64 gracePeriodPctg;
        uint64 maxPeriodPctg;
        // extra fee/reward on top of baseFee
        uint64 multiplerPctg;
    }

    function testTokenomicsFeeCalcWithNonZeroStartBips() public {
        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 0 seconds,
            isProposal: true,
            dampingFactorBips: 4000, // 40%
            expectedFeeBase: 140 * 1E8,
            expectedPreimumRate: 0
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 20 seconds,
            isProposal: true,
            dampingFactorBips: 4000, // 40%
            expectedFeeBase: 120 * 1E8,
            expectedPreimumRate: 0
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 40 seconds,
            isProposal: true,
            dampingFactorBips: 4000, // 40%
            expectedFeeBase: 100 * 1E8,
            expectedPreimumRate: 0
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 60 seconds,
            isProposal: true,
            dampingFactorBips: 4000, // 40%
            expectedFeeBase: 80 * 1E8,
            expectedPreimumRate: 0
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 80 seconds,
            isProposal: true,
            dampingFactorBips: 4000, // 40%
            expectedFeeBase: 60 * 1E8,
            expectedPreimumRate: 0
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 81 seconds,
            isProposal: true,
            dampingFactorBips: 4000, // 40%
            expectedFeeBase: 60 * 1E8,
            expectedPreimumRate: 0
        });
    }

    function testTokenomicsFeeCalcWithZeroStartBips() public {
        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 0 seconds,
            isProposal: true,
            dampingFactorBips: 0, // 0%
            expectedFeeBase: 100 * 1E8,
            expectedPreimumRate: 0
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 20 seconds,
            isProposal: true,
            dampingFactorBips: 0, // 0%
            expectedFeeBase: 100 * 1E8,
            expectedPreimumRate: 0
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 40 seconds,
            isProposal: true,
            dampingFactorBips: 0, // 0%
            expectedFeeBase: 100 * 1E8,
            expectedPreimumRate: 0
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 60 seconds,
            isProposal: true,
            dampingFactorBips: 0, // 0%
            expectedFeeBase: 100 * 1E8,
            expectedPreimumRate: 0
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 80 seconds,
            isProposal: true,
            dampingFactorBips: 0, // 0%
            expectedFeeBase: 100 * 1E8,
            expectedPreimumRate: 0
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 81 seconds,
            isProposal: true,
            dampingFactorBips: 0, // 0%
            expectedFeeBase: 100 * 1E8,
            expectedPreimumRate: 0
        });
    }

    function testTokenomicsRewardCalcWithNonZeroStartBips() public {
        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 0 seconds,
            isProposal: false,
            dampingFactorBips: 4000, // 40%
            expectedFeeBase: 60 * 1E8,
            expectedPreimumRate: 0
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 20 seconds,
            isProposal: false,
            dampingFactorBips: 4000, // 40%
            expectedFeeBase: 80 * 1E8,
            expectedPreimumRate: 0
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 40 seconds,
            isProposal: false,
            dampingFactorBips: 4000, // 40%
            expectedFeeBase: 100 * 1E8,
            expectedPreimumRate: 0
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 60 seconds,
            isProposal: false,
            dampingFactorBips: 4000, // 40%
            expectedFeeBase: 120 * 1E8,
            expectedPreimumRate: 5000
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 80 seconds,
            isProposal: false,
            dampingFactorBips: 4000, // 40%
            expectedFeeBase: 140 * 1E8,
            expectedPreimumRate: 10000
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 81 seconds,
            isProposal: false,
            dampingFactorBips: 4000, // 40%
            expectedFeeBase: 140 * 1E8,
            expectedPreimumRate: 10000
        });
    }

    function testTokenomicsRewardCalcWithZeroStartBips() public {
        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 0 seconds,
            isProposal: false,
            dampingFactorBips: 0, // 0%
            expectedFeeBase: 100 * 1E8,
            expectedPreimumRate: 0
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 20 seconds,
            isProposal: false,
            dampingFactorBips: 0, // 0%
            expectedFeeBase: 100 * 1E8,
            expectedPreimumRate: 0
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 40 seconds,
            isProposal: false,
            dampingFactorBips: 0, // 0%
            expectedFeeBase: 100 * 1E8,
            expectedPreimumRate: 0
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 60 seconds,
            isProposal: false,
            dampingFactorBips: 0, // 0%
            expectedFeeBase: 100 * 1E8,
            expectedPreimumRate: 0
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 80 seconds,
            isProposal: false,
            dampingFactorBips: 0, // 0%
            expectedFeeBase: 100 * 1E8,
            expectedPreimumRate: 0
        });

        testTimeAdjustedFee({
            feeBase: 100 * 1E8,
            timeAverageSec: 40 seconds,
            timeUsedSec: 81 seconds,
            isProposal: false,
            dampingFactorBips: 0, // 0%
            expectedFeeBase: 100 * 1E8,
            expectedPreimumRate: 0
        });
    }

    function testTimeAdjustedFee(
        uint256 feeBase,
        uint256 timeAverageSec,
        uint256 timeUsedSec,
        bool isProposal,
        uint16 dampingFactorBips,
        uint256 expectedFeeBase,
        uint256 expectedPreimumRate
    ) private {
        TaikoData.FeeConfig memory feeConfig = TaikoData.FeeConfig({
            avgTimeMAF: 1024,
            dampingFactorBips: dampingFactorBips
        });

        (uint256 _feeBase, uint256 _premiumRate) = LibTokenomics
            .getTimeAdjustedFee(
                feeConfig,
                feeBase.toUint64(),
                isProposal,
                timeUsedSec,
                timeAverageSec * 1000
            );

        assertEq(_premiumRate, expectedPreimumRate);
        assertEq(_feeBase, expectedFeeBase);
    }
}
