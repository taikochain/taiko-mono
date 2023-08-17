// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.20;

import { Address } from "@openzeppelin/contracts/utils/Address.sol";
import { AddressResolver } from "../../common/AddressResolver.sol";
import { IMintableERC20 } from "../../common/IMintableERC20.sol";
import { IProver } from "../IProver.sol";
import { ISignalService } from "../../signal/ISignalService.sol";
import { LibL2Consts } from "../../L2/LibL2Consts.sol";
import { LibMath } from "../../libs/LibMath.sol";
import { LibUtils } from "./LibUtils.sol";
import { TaikoData } from "../../L1/TaikoData.sol";
import { TaikoToken } from "../TaikoToken.sol";

library LibVerifying {
    using Address for address;
    using LibUtils for TaikoData.State;
    using LibMath for uint256;

    event BlockVerified(
        uint256 indexed blockId,
        bytes32 blockHash,
        address prover,
        uint64 proverFee
    );
    event CrossChainSynced(
        uint256 indexed srcHeight, bytes32 blockHash, bytes32 signalRoot
    );

    error L1_INVALID_CONFIG();

    function init(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        bytes32 genesisBlockHash,
        uint16 initAvgProofDelay
    )
        internal
    {
        if (
            config.chainId <= 1 //
                || config.blockMaxProposals == 1
                || config.blockRingBufferSize <= config.blockMaxProposals + 1
                || config.blockMaxGasLimit == 0 || config.blockMaxTransactions == 0
                || config.blockMaxTxListBytes == 0
                || config.blockTxListExpiry > 30 * 24 hours
                || config.blockMaxTxListBytes > 128 * 1024 //blob up to 128K
                || config.proofRegularCooldown < config.proofOracleCooldown
                || config.proofMinWindow == 0
                || config.proofMaxWindow < config.proofMinWindow
                || config.proofWindowMultiplier <= 100
                || config.ethDepositRingBufferSize <= 1
                || config.ethDepositMinCountPerBlock == 0
                || config.ethDepositMaxCountPerBlock
                    < config.ethDepositMinCountPerBlock
                || config.ethDepositMinAmount == 0
                || config.ethDepositMaxAmount <= config.ethDepositMinAmount
                || config.ethDepositMaxAmount >= type(uint96).max
                || config.ethDepositGas == 0 || config.ethDepositMaxFee == 0
                || config.ethDepositMaxFee >= type(uint96).max
                || config.ethDepositMaxFee
                    >= type(uint96).max / config.ethDepositMaxCountPerBlock
                || config.rewardMaxDelayPenalty >= 10_000
        ) revert L1_INVALID_CONFIG();

        unchecked {
            uint64 timeNow = uint64(block.timestamp);

            // Init state
            state.slotA.genesisHeight = uint64(block.number);
            state.slotA.genesisTimestamp = timeNow;
            state.slotB.numBlocks = 1;
            state.slotC.lastVerifiedAt = uint64(block.timestamp);
            state.slotC.avgProofDelay = initAvgProofDelay;

            // Init the genesis block
            TaikoData.Block storage blk = state.blocks[0];
            blk.nextForkChoiceId = 2;
            blk.verifiedForkChoiceId = 1;
            blk.proposedAt = timeNow;

            // Init the first fork choice
            TaikoData.ForkChoice storage fc = state.blocks[0].forkChoices[1];
            fc.blockHash = genesisBlockHash;
            fc.provenAt = timeNow;
        }

        emit BlockVerified({
            blockId: 0,
            blockHash: genesisBlockHash,
            prover: address(1), // oracle prover
            proverFee: 0
        });
    }

    function verifyBlocks(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        AddressResolver resolver,
        uint256 maxBlocks
    )
        internal
    {
        uint256 i = state.slotC.lastVerifiedBlockId;
        TaikoData.Block storage blk =
            state.blocks[i % config.blockRingBufferSize];

        uint24 fcId = blk.verifiedForkChoiceId;
        assert(fcId > 0);

        bytes32 blockHash = blk.forkChoices[fcId].blockHash;
        uint32 gasUsed = blk.forkChoices[fcId].gasUsed;
        bytes32 signalRoot;

        uint64 processed;
        unchecked {
            ++i;
        }

        while (i < state.slotB.numBlocks && processed < maxBlocks) {
            blk = state.blocks[i % config.blockRingBufferSize];
            assert(blk.blockId == i);

            fcId = LibUtils.getForkChoiceId(state, blk, blockHash, gasUsed);
            if (fcId == 0) break;

            TaikoData.ForkChoice memory fc = blk.forkChoices[fcId];
            if (fc.prover == address(0)) break;

            uint256 proofRegularCooldown = fc.prover == address(1)
                ? config.proofOracleCooldown
                : config.proofRegularCooldown;

            if (block.timestamp <= fc.provenAt + proofRegularCooldown) break;

            blockHash = fc.blockHash;
            gasUsed = fc.gasUsed;
            signalRoot = fc.signalRoot;

            _verifyBlock({
                state: state,
                config: config,
                resolver: resolver,
                blk: blk,
                fcId: fcId,
                fc: fc
            });

            unchecked {
                ++i;
                ++processed;
            }
        }

        if (processed > 0) {
            unchecked {
                state.slotC.lastVerifiedAt = uint64(block.timestamp);
                state.slotC.lastVerifiedBlockId += processed;
            }

            if (config.relaySignalRoot) {
                // Send the L2's signal root to the signal service so other
                // TaikoL1  deployments, if they share the same signal
                // service, can relay the signal to their corresponding
                // TaikoL2 contract.
                ISignalService(resolver.resolve("signal_service", false))
                    .sendSignal(signalRoot);
            }
            emit CrossChainSynced(
                state.slotC.lastVerifiedBlockId, blockHash, signalRoot
            );
        }
    }

    function _verifyBlock(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        AddressResolver resolver,
        TaikoData.Block storage blk,
        TaikoData.ForkChoice memory fc,
        uint24 fcId
    )
        private
    {
        blk.verifiedForkChoiceId = fcId;

        bool inProofWindow = blk.prover == address(0)
            || fc.provenAt <= blk.proposedAt + blk.proofWindow;

        // Calculate the block fee
        uint64 proverFee = inProofWindow ? blk.proverFee : 16e8; // TODO(daniel):

        // Update protocol level stats
        if (inProofWindow && fc.prover != address(1)) {
            uint64 proofDelay;
            unchecked {
                proofDelay = fc.provenAt - blk.proposedAt;
            }

            if (config.rewardMaxDelayPenalty > 0) {
                // Give the reward a penalty up to a small percentage.
                // This will encourage prover to submit proof ASAP.
                proverFee -= uint64(
                    uint256(proverFee) * proofDelay
                        * config.rewardMaxDelayPenalty / 10_000 / blk.proofWindow
                );
            }

            // The selected prover managed to prove the block in time
            state.slotC.avgProofDelay = uint16(
                LibUtils.movingAverage({
                    maValue: state.slotC.avgProofDelay,
                    newValue: proofDelay,
                    maf: 7200
                })
            );
        }

        TaikoToken tt = TaikoToken(resolver.resolve("taiko_token", false));

        // Mint token to the assigned prover
        uint64 mintAmount = proverFee;
        if (inProofWindow || fc.prover == address(1)) {
            mintAmount += 32e8; // TODO(daniel)
        }
        tt.mint(fc.prover, mintAmount);

        // Emit the event
        emit BlockVerified({
            blockId: blk.blockId,
            blockHash: fc.blockHash,
            prover: fc.prover,
            proverFee: proverFee
        });
    }
}
