// SPDX-License-Identifier: MIT
//
// ╭━━━━╮╱╱╭╮╱╱╱╱╱╭╮╱╱╱╱╱╭╮
// ┃╭╮╭╮┃╱╱┃┃╱╱╱╱╱┃┃╱╱╱╱╱┃┃
// ╰╯┃┃┣┻━┳┫┃╭┳━━╮┃┃╱╱╭━━┫╰━┳━━╮
// ╱╱┃┃┃╭╮┣┫╰╯┫╭╮┃┃┃╱╭┫╭╮┃╭╮┃━━┫
// ╱╱┃┃┃╭╮┃┃╭╮┫╰╯┃┃╰━╯┃╭╮┃╰╯┣━━┃
// ╱╱╰╯╰╯╰┻┻╯╰┻━━╯╰━━━┻╯╰┻━━┻━━╯
pragma solidity ^0.8.9;

import "../../common/AddressResolver.sol";
import "../LibData.sol";
import "../TkoToken.sol";
import "./V1Utils.sol";

/// @author dantaik <dan@taiko.xyz>
library V1Finalizing {
    using SafeCastUpgradeable for uint256;
    event BlockFinalized(uint256 indexed id, bytes32 blockHash);

    event HeaderSynced(
        uint256 indexed height,
        uint256 indexed srcHeight,
        bytes32 srcHash
    );

    function init(
        LibData.State storage s,
        bytes32 _genesisBlockHash,
        uint256 _feeBase
    ) public {
        require(_feeBase > 0, "L1:feeBase");

        s.genesisHeight = uint64(block.number);
        s.genesisTimestamp = uint64(block.timestamp);
        s.feeBase = _feeBase;
        s.nextBlockId = 1;
        s.lastProposedAt = uint64(block.timestamp);
        s.l2Hashes[0] = _genesisBlockHash;

        emit BlockFinalized(0, _genesisBlockHash);
        emit HeaderSynced(block.number, 0, _genesisBlockHash);
    }

    function finalizeBlocks(
        LibData.State storage s,
        AddressResolver resolver,
        uint256 maxBlocks
    ) public {
        uint64 latestL2Height = s.latestFinalizedHeight;
        bytes32 latestL2Hash = s.l2Hashes[latestL2Height];
        uint64 processed = 0;
        TkoToken tkoToken;

        for (
            uint256 i = s.latestFinalizedId + 1;
            i < s.nextBlockId && processed <= maxBlocks;
            i++
        ) {
            LibData.ForkChoice storage fc = s.forkChoices[i][latestL2Hash];
            if (fc.blockHash == 0) {
                break;
            } else {
                if (fc.blockHash != LibConstants.K_BLOCK_DEADEND_HASH) {
                    latestL2Height += 1;
                    latestL2Hash = fc.blockHash;
                }

                (uint256 reward, uint256 premiumReward) = getProofReward(
                    s,
                    fc.provenAt,
                    fc.proposedAt
                );

                s.feeBase = V1Utils.movingAverage(s.feeBase, reward, 1024);

                s.avgProofTime = V1Utils
                    .movingAverage(
                        s.avgProofTime,
                        fc.provenAt - fc.proposedAt,
                        1024
                    )
                    .toUint64();

                if (address(tkoToken) == address(0)) {
                    tkoToken = TkoToken(resolver.resolve("tko_token"));
                }

                // TODO(daniel): reward all provers
                tkoToken.mint(fc.provers[0], premiumReward);

                emit BlockFinalized(i, fc.blockHash);
            }

            processed += 1;
        }

        if (processed > 0) {
            s.latestFinalizedId += processed;

            if (latestL2Height > s.latestFinalizedHeight) {
                s.latestFinalizedHeight = latestL2Height;
                s.l2Hashes[latestL2Height] = latestL2Hash;
                emit HeaderSynced(block.number, latestL2Height, latestL2Hash);
            }
        }
    }

    function getProofReward(
        LibData.State storage s,
        uint64 provenAt,
        uint64 proposedAt
    ) public view returns (uint256 reward, uint256 premiumReward) {
        uint256 alpha = V1Utils.feeScaleAlpha(
            uint64(block.timestamp),
            provenAt,
            proposedAt,
            LibConstants.K_PROOF_TIME_CAP
        );

        reward = (s.feeBase * alpha) / 10000;

        premiumReward = (reward * V1Utils.feeScaleBeta(s, true)) / 10000;
        premiumReward =
            (premiumReward * (10000 - LibConstants.K_REWARD_BURN_POINTS)) /
            10000;
    }
}
