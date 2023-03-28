// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {AddressResolver} from "../../common/AddressResolver.sol";
import {LibMath} from "../../libs/LibMath.sol";
import {LibFixedPointMath} from "../../thirdparty/LibFixedPointMath.sol";
import {
    SafeCastUpgradeable
} from "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import {TaikoData} from "../TaikoData.sol";

import {console2} from "forge-std/console2.sol";

library LibL2Tokenomics {
    using LibMath for uint256;
    using SafeCastUpgradeable for uint256;

    error L1_OUT_OF_BLOCK_SPACE();

    function get1559Basefee(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        uint32 gasInBlock
    ) internal view returns (uint64 newGasExcess, uint64 basefee) {
        return
            calc1559Basefee(
                state.gasExcess,
                config.gasTargetPerSecond,
                config.gasAdjustmentQuotient,
                gasInBlock,
                uint64(block.timestamp - state.lastProposedAt)
            );
    }

    // @dev Return adjusted basefee per gas for the next L2 block.
    //      See https://ethresear.ch/t/make-eip-1559-more-like-an-amm-curve/9082
    //      But the current implementation use AMM style math as we don't yet
    //      have a solidity exp(uint256 x) implementation.
    function calc1559Basefee(
        uint64 gasExcess,
        uint64 gasTargetPerSecond,
        uint64 gasAdjustmentQuotient,
        uint32 gasInBlock,
        uint64 blockTime
    ) internal view returns (uint64 newGasExcess, uint64 basefee) {
        if (gasInBlock == 0) {
            uint256 _basefee = ethQty(gasExcess, gasAdjustmentQuotient) /
                gasAdjustmentQuotient;
            basefee = uint64(_basefee.min(type(uint64).max));

            return (gasExcess, basefee);
        }
        unchecked {
            uint64 newGas = gasTargetPerSecond * blockTime;
            uint64 _gasExcess = gasExcess > newGas ? gasExcess - newGas : 0;

            if (uint256(_gasExcess) + gasInBlock >= type(uint64).max)
                revert L1_OUT_OF_BLOCK_SPACE();

            newGasExcess = _gasExcess + gasInBlock;

            uint256 a = ethQty(
                newGasExcess, // larger
                gasAdjustmentQuotient
            );
            uint256 b = ethQty(
                _gasExcess, // smaller
                gasAdjustmentQuotient
            );
            uint256 _basefee = (a - b) / gasInBlock;
            basefee = uint64(_basefee.min(type(uint64).max));

            console2.log("-----------------------");
            console2.log("gasExcess:", gasExcess);
            console2.log("newGas:", newGas);
            console2.log("_gasExcess:", _gasExcess);
            console2.log("newGasExcess:", newGasExcess);
            console2.log("a:", a);
            console2.log("b:", b);
            console2.log("_basefee:", _basefee);
            console2.log("basefee:", basefee);
        }
    }

    function ethQty(
        uint64 gasAmount,
        uint64 gasAdjustmentQuotient
    ) internal view returns (uint256 qty) {
        uint x = gasAmount / gasAdjustmentQuotient;
        int y = LibFixedPointMath.exp(int256(uint256(x)));
        qty = y > 0 ? uint256(y) : 0;
        console2.log("   -  gasAmount:", gasAmount);
        console2.log("   -  qty:", qty);
    }

    function calcGasExcess(
        uint64 basefee,
        uint64 gasAdjustmentQuotient
    ) internal view returns (uint64 gasExcess) {
        console2.log("   =  basefee:", basefee);
        console2.log("   =  gasAdjustmentQuotient:", gasAdjustmentQuotient);
        uint x = basefee * gasAdjustmentQuotient * 1E8;
        console2.log("   =  x:", x);
        console2.log("   =  ln:", LibFixedPointMath.ln(int(x)));

        uint64 y = uint256(LibFixedPointMath.ln(int(x))).toUint64();
        gasExcess = y * gasAdjustmentQuotient;

        console2.log("   =  y:", y);
        console2.log("   =  gasExcess:", gasExcess);
    }
}
