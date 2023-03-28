// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {LibMath} from "../../libs/LibMath.sol";
import {LibL1Tokenomics} from "./LibL1Tokenomics.sol";
import {
    SafeCastUpgradeable
} from "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import {TaikoData} from "../TaikoData.sol";

library LibUtils {
    using LibMath for uint256;

    error L1_BLOCK_ID();

    function getL2ChainData(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        uint256 blockId
    ) internal view returns (bool found, TaikoData.Block storage blk) {
        uint256 id = blockId == 0 ? state.lastVerifiedBlockId : blockId;
        blk = state.blocks[id % config.ringBufferSize];
        found = (blk.blockId == id && blk.verifiedForkChoiceId != 0);
    }

    function getStateVariables(
        TaikoData.State storage state,
        TaikoData.Config memory config
    ) internal view returns (TaikoData.StateVariables memory) {
        return
            TaikoData.StateVariables({
                feeBase: state.feeBase,
                genesisHeight: state.genesisHeight,
                genesisTimestamp: state.genesisTimestamp,
                numBlocks: state.numBlocks,
                lastProposedAt: state.lastProposedAt,
                avgBlockTime: state.avgBlockTime,
                lastVerifiedBlockId: state.lastVerifiedBlockId,
                avgProofTime: state.avgProofTime,
                basefee: 0, // TODO
                gasExcess: state.gasExcess
            });
    }

    function movingAverage(
        uint256 maValue,
        uint256 newValue,
        uint256 maf
    ) internal pure returns (uint256) {
        if (maValue == 0) {
            return newValue;
        }
        uint256 _ma = (maValue * (maf - 1) + newValue) / maf;
        return _ma > 0 ? _ma : maValue;
    }
}
