// SPDX-License-Identifier: MIT
//
// ╭━━━━╮╱╱╭╮╱╱╱╱╱╭╮╱╱╱╱╱╭╮
// ┃╭╮╭╮┃╱╱┃┃╱╱╱╱╱┃┃╱╱╱╱╱┃┃
// ╰╯┃┃┣┻━┳┫┃╭┳━━╮┃┃╱╱╭━━┫╰━┳━━╮
// ╱╱┃┃┃╭╮┣┫╰╯┫╭╮┃┃┃╱╭┫╭╮┃╭╮┃━━┫
// ╱╱┃┃┃╭╮┃┃╭╮┫╰╯┃┃╰━╯┃╭╮┃╰╯┣━━┃
// ╱╱╰╯╰╯╰┻┻╯╰┻━━╯╰━━━┻╯╰┻━━┻━━╯
pragma solidity ^0.8.9;

import "../libs/Lib1559Math.sol";

contract TestLib1559Math {
    function adjustTarget(
        uint256 firstTarget,
        uint256 startingMeasurement,
        uint256 baseTargetVal,
        uint256 adjustmentFactor
    ) public pure returns (uint256 nextTarget) {
        nextTarget = Lib1559Math.adjustTarget(
            firstTarget,
            startingMeasurement,
            baseTargetVal,
            adjustmentFactor
        );
    }

    function adjustTargetReverse(
        uint256 firstTarget,
        uint256 startingMeasurement,
        uint256 baseTargetVal,
        uint256 adjustmentFactor
    ) public pure returns (uint256 nextTarget) {
        nextTarget = Lib1559Math.adjustTargetReverse(
            firstTarget,
            startingMeasurement,
            baseTargetVal,
            adjustmentFactor
        );
    }
}
