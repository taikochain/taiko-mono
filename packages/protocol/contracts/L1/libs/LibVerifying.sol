// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {AddressResolver} from "../../common/AddressResolver.sol";
import {LibTokenomics} from "./LibTokenomics.sol";
import {LibUtils} from "./LibUtils.sol";
import {
    SafeCastUpgradeable
} from "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";
import {Snippet} from "../../common/IXchainSync.sol";
import {TaikoData} from "../../L1/TaikoData.sol";
import {TaikoToken} from "../TaikoToken.sol";

library LibVerifying {
    using SafeCastUpgradeable for uint256;
    using LibUtils for TaikoData.State;

    event BlockVerified(uint256 indexed id, Snippet snippet);
    event XchainSynced(uint256 indexed srcHeight, Snippet snippet);

    function init(
        TaikoData.State storage state,
        bytes32 genesisBlockHash,
        uint64 feeBaseSzabo
    ) internal {
        state.genesisHeight = uint64(block.number);
        state.genesisTimestamp = uint64(block.timestamp);
        state.feeBaseSzabo = feeBaseSzabo;
        state.nextBlockId = 1;
        state.lastProposedAt = uint64(block.timestamp);

        Snippet memory snippet = Snippet(genesisBlockHash, 0);
        state.l2Snippets[0] = snippet;

        emit BlockVerified(0, snippet);
        emit XchainSynced(0, snippet);
    }

    function verifyBlocks(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        uint256 maxBlocks
    ) internal {
        uint64 latestL2Height = state.latestVerifiedHeight;
        Snippet memory latestL2Snippet = state.l2Snippets[
            latestL2Height % config.blockHashHistory
        ];

        uint64 processed;

        for (
            uint256 i = state.latestVerifiedId + 1;
            i < state.nextBlockId && processed < maxBlocks;
            ++i
        ) {
            TaikoData.ForkChoice storage fc = state.forkChoices[i][
                latestL2Snippet.blockHash
            ];
            TaikoData.ProposedBlock storage target = state.getProposedBlock(
                config.maxNumBlocks,
                i
            );

            if (fc.prover == address(0)) {
                break;
            } else {
                (latestL2Height, latestL2Snippet) = _markBlockVerified({
                    state: state,
                    config: config,
                    fc: fc,
                    target: target,
                    latestL2Height: latestL2Height,
                    latestL2Snippet: latestL2Snippet
                });
                processed += 1;
                emit BlockVerified(i, latestL2Snippet);
            }
        }

        if (processed > 0) {
            state.latestVerifiedId += processed;

            if (latestL2Height > state.latestVerifiedHeight) {
                state.latestVerifiedHeight = latestL2Height;

                // Note: Not all L2 hashes are stored on L1, only the last
                // verified one in a batch. This is sufficient because the last
                // verified hash is the only one needed checking the existence
                // of a cross-chain message with a merkle proof.
                state.l2Snippets[
                    latestL2Height % config.blockHashHistory
                ] = latestL2Snippet;

                emit XchainSynced(latestL2Height, latestL2Snippet);
            }
        }
    }

    function withdraw(
        TaikoData.State storage state,
        AddressResolver resolver
    ) internal {
        uint256 balance = state.balances[msg.sender];
        if (balance <= 1) return;

        state.balances[msg.sender] = 1;
        TaikoToken(resolver.resolve("tko_token", false)).mint(
            msg.sender,
            balance - 1
        );
    }

    function deposit(
        TaikoData.State storage state,
        AddressResolver resolver,
        uint256 amount
    ) internal {
        TaikoToken(resolver.resolve("tko_token", false)).burn(
            msg.sender,
            amount
        );
        state.balances[msg.sender] += amount;
    }

    function getProofReward(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        uint64 provenAt,
        uint64 proposedAt
    )
        internal
        view
        returns (uint256 newFeeBase, uint256 reward, uint256 tRelBp)
    {
        (newFeeBase, tRelBp) = LibTokenomics.getTimeAdjustedFee({
            config: config,
            feeBase: LibTokenomics.szaboToWei(state.feeBaseSzabo),
            isProposal: false,
            tNow: provenAt,
            tLast: proposedAt,
            tAvg: state.avgProofTime
        });
        reward = LibTokenomics.getSlotsAdjustedFee({
            state: state,
            config: config,
            isProposal: false,
            feeBase: newFeeBase
        });
        reward = (reward * (10000 - config.rewardBurnBips)) / 10000;
    }

    function _markBlockVerified(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        TaikoData.ForkChoice storage fc,
        TaikoData.ProposedBlock storage target,
        uint64 latestL2Height,
        Snippet memory latestL2Snippet
    )
        private
        returns (uint64 _latestL2Height, Snippet memory _latestL2Snippet)
    {
        if (config.enableTokenomics) {
            uint256 newFeeBase;
            {
                uint256 reward;
                uint256 tRelBp; // [0-10000], see the whitepaper
                (newFeeBase, reward, tRelBp) = getProofReward({
                    state: state,
                    config: config,
                    provenAt: fc.provenAt,
                    proposedAt: target.proposedAt
                });

                // reward the prover
                if (reward > 0) {
                    if (state.balances[fc.prover] == 0) {
                        // Reduce reward to 1 wei as a penalty if the prover
                        // has 0 TKO outstanding balance.
                        state.balances[fc.prover] = 1;
                    } else {
                        state.balances[fc.prover] += reward;
                    }
                }

                // refund proposer deposit
                if (fc.snippet.blockHash != LibUtils.BLOCK_DEADEND_HASH) {
                    uint256 refund = (target.deposit * (10000 - tRelBp)) /
                        10000;
                    if (refund > 0) {
                        if (state.balances[target.proposer] == 0) {
                            // Reduce refund to 1 wei as a penalty if the proposer
                            // has 0 TKO outstanding balance.
                            state.balances[target.proposer] = 1;
                        } else {
                            state.balances[target.proposer] += refund;
                        }
                    }
                }
            }
            // Update feeBase and avgProofTime
            state.feeBaseSzabo = LibTokenomics.weiToSzabo(
                LibUtils.movingAverage({
                    maValue: LibTokenomics.szaboToWei(state.feeBaseSzabo),
                    newValue: newFeeBase,
                    maf: config.feeBaseMAF
                })
            );
        }

        state.avgProofTime = LibUtils
            .movingAverage({
                maValue: state.avgProofTime,
                newValue: fc.provenAt - target.proposedAt,
                maf: config.proofTimeMAF
            })
            .toUint64();

        if (fc.snippet.blockHash != LibUtils.BLOCK_DEADEND_HASH) {
            _latestL2Height = latestL2Height + 1;
            _latestL2Snippet = fc.snippet;
        } else {
            _latestL2Height = latestL2Height;
            _latestL2Snippet = latestL2Snippet;
        }

        // clean up the fork choice
        // Even after https://eips.ethereum.org/EIPS/eip-3298 the cleanup
        // may still reduce the gas cost if the block is proven and
        // fianlized in the same L1 transaction.
        fc.snippet.blockHash = 0;
        fc.snippet.signalRoot = 0;
        fc.prover = address(0);
        fc.provenAt = 0;
    }
}
