// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { console2 } from "forge-std/console2.sol";
import { TestBase } from "../TestBase.sol";
import { Lib1559Math } from "../../contracts/L2/1559/Lib1559Math.sol";

contract Lib1559MathTest is TestBase {
    function test_1559() public view {
        // Some data from A5 testnet
        uint24[100] memory data = [
            127_856,
            6_046_273,
            7_909_401,
            7_928_008,
            1_956_212,
            127_856,
            510_716,
            5_848_659,
            5_874_423,
            5_542_922,
            6_348_112,
            950_557,
            208_357,
            1_025_524,
            6_999_092,
            6_129_324,
            5_542_922,
            5_874_531,
            5_542_886,
            6_437_534,
            167_656,
            5_542_922,
            5_874_411,
            5_874_435,
            1_646_251,
            7_095_818,
            5_895_447,
            5_542_922,
            5_596_570,
            1_113_373,
            127_856,
            7_097_146,
            167_656,
            6_020_623,
            5_874_507,
            6_883_077,
            1_262_001,
            127_856,
            7_156_369,
            5_737_163,
            5_543_054,
            5_663_573,
            1_129_832,
            7_140_222,
            5_874_555,
            6_912_869,
            8_049_939,
            7_880_045,
            127_856,
            127_856,
            365_143,
            5_895_471,
            7_822_458,
            8_078_775,
            2_305_031,
            6_068_601,
            127_856,
            726_038,
            127_856,
            5_542_922,
            5_874_543,
            7_764_396,
            1_023_753,
            321_323,
            6_359_882,
            6_614_024,
            167_661,
            127_844,
            691_145,
            407_862,
            127_844,
            5_874_507,
            6_322_002,
            8_119_695,
            1_353_739,
            6_880_246,
            167_661,
            7_145_171,
            5_542_922,
            5_542_886,
            6_020_671,
            739_778,
            127_856,
            127_856,
            127_856,
            127_856,
            127_856,
            127_856,
            6_833_962,
            127_856,
            413_667,
            127_856,
            127_856,
            127_856,
            5_542_922,
            5_543_258,
            5_874_531,
            5_543_234,
            127_856,
            127_856
        ];
        uint256 n = data.length;
        uint256 totalGas;

        for (uint64 i = 0; i < n; i++) {
            uint32 gasUsed = data[i];
            totalGas += gasUsed;
        }

        uint256 baseFeePerGas = 10 * 1_000_000_000; // 10 Gwei
        uint256 blockGasTarget = totalGas / n;
        console2.log("blockGasTarget", blockGasTarget);

        for (uint64 i = 0; i < n; i++) {
            uint32 gasUsed = data[i];
            baseFeePerGas = Lib1559Math.calcBaseFeePerGas(
                baseFeePerGas, gasUsed, blockGasTarget
            );
            console2.log(
                "gasUsed:", gasUsed, " => baseFeePerGas:", baseFeePerGas
            );
        }
    }
}
