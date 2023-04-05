// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {AddressResolver} from "../../common/AddressResolver.sol";
import {LibMath} from "../../libs/LibMath.sol";
import {
    SafeCastUpgradeable
} from "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import {TaikoData} from "../TaikoData.sol";
import {TaikoToken} from "../TaikoToken.sol";

library LibTokenomics {
    using LibMath for uint256;

    error L1_INSUFFICIENT_TOKEN();
    error L1_INVALID_PARAM();

    function withdraw(
        TaikoData.State storage state,
        AddressResolver resolver,
        uint256 amount
    ) internal {
        uint256 balance = state.balances[msg.sender];
        if (balance < amount) revert L1_INSUFFICIENT_TOKEN();

        unchecked {
            state.balances[msg.sender] -= amount;
        }

        TaikoToken(resolver.resolve("taiko_token", false)).mint(
            msg.sender,
            amount
        );
    }

    function deposit(
        TaikoData.State storage state,
        AddressResolver resolver,
        uint256 amount
    ) internal {
        if (amount > 0) {
            TaikoToken(resolver.resolve("taiko_token", false)).burn(
                msg.sender,
                amount
            );
            state.balances[msg.sender] += amount;
        }
    }

    function getBlockFee(
        TaikoData.State storage state,
        TaikoData.Config memory config
    )
        internal
        view
        returns (uint64 newFeeBase, uint64 fee, uint64 depositAmount)
    {
        (newFeeBase, ) = getTimeAdjustedFee({
            feeConfig: config.proposingConfig,
            feeBase: state.feeBase,
            isProposal: true,
            timeUsed: block.timestamp - state.lastProposedAt,
            timeAverage: state.avgBlockTime
        });
        fee = getSlotsAdjustedFee({
            state: state,
            config: config,
            isProposal: true,
            feeBase: newFeeBase
        });

        unchecked {
            depositAmount = uint64((config.proposerDepositPctg * fee) / 100);
        }
    }

    function getProofReward(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        uint64 provenAt,
        uint64 proposedAt
    )
        internal
        view
        returns (uint64 newFeeBase, uint64 reward, uint64 premiumRate)
    {
        if (proposedAt > provenAt) revert L1_INVALID_PARAM();

        (newFeeBase, premiumRate) = getTimeAdjustedFee({
            feeConfig: config.provingConfig,
            feeBase: state.feeBase,
            isProposal: false,
            timeUsed: provenAt - proposedAt,
            timeAverage: state.avgProofTime
        });
        reward = getSlotsAdjustedFee({
            state: state,
            config: config,
            isProposal: false,
            feeBase: newFeeBase
        });

        unchecked {
            reward = uint64((reward * (10000 - config.rewardBurnBips)) / 10000);
        }
    }

    // Implement "Slot-availability Multipliers", see the whitepaper.
    function getSlotsAdjustedFee(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        bool isProposal,
        uint64 feeBase
    ) internal view returns (uint64) {
        unchecked {
            // m is the `n'` in the whitepaper
            uint256 m = 1000 *
                config.maxNumProposedBlocks +
                config.slotSmoothingFactor;
            // n is the number of unverified blocks
            uint256 n = 1000 *
                (state.numBlocks - state.lastVerifiedBlockId - 1);
            // k is `m − n + 1` or `m − n - 1`in the whitepaper
            uint256 k = isProposal ? m - n - 1000 : m - n + 1000;
            return uint64((feeBase * (m - 1000) * m) / (m - n) / k);
        }
    }

    // Implement "Incentive Multipliers", see the whitepaper.
    function getTimeAdjustedFee(
        TaikoData.FeeConfig memory feeConfig,
        uint64 feeBase,
        bool isProposal,
        uint256 timeUsed, // seconds
        uint256 timeAverage // milliseconds
    ) internal pure returns (uint64 newFeeBase, uint64 premiumRate) {
        if (timeAverage == 0) {
            return (feeBase, 0);
        }
        unchecked {
            uint256 p = feeConfig.dampingFactorBips; // [0-10000]
            uint256 a = timeAverage;
            uint256 t = (timeUsed * 1000).min(a * 2); // millisconds

            newFeeBase = uint64((feeBase * (10000 + (t * p) / a - p)) / 10000);

            if (isProposal) {
                newFeeBase = (feeBase * 2) - newFeeBase;
            } else if (p > 0) {
                premiumRate = uint64(((t.max(a) - a) * 10000) / a);
            }
        }
    }
}
