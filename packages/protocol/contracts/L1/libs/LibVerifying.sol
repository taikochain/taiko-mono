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
import { LibMath } from "../../libs/LibMath.sol";
import { LibUtils } from "./LibUtils.sol";
import { TaikoData } from "../../L1/TaikoData.sol";
import { TaikoToken } from "../TaikoToken.sol";

library LibVerifying {
    using Address for address;
    using LibUtils for TaikoData.State;
    using LibMath for uint256;

    event BlockVerified(
        uint64 indexed blockId, bytes32 blockHash, address prover
    );
    event CrossChainSynced(
        uint64 indexed srcHeight, bytes32 blockHash, bytes32 signalRoot
    );

    error L1_INVALID_CONFIG();

    function init(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        bytes32 genesisBlockHash
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
                || config.proofWindow == 0 || config.proofBond == 0
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
        ) revert L1_INVALID_CONFIG();

        unchecked {
            uint64 timeNow = uint64(block.timestamp);

            // Init state
            state.slotA.genesisHeight = uint64(block.number);
            state.slotA.genesisTimestamp = timeNow;
            state.slotB.numBlocks = 1;
            state.slotB.lastVerifiedAt = uint64(block.timestamp);

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
            prover: address(1) // oracle prover
         });
    }

    function verifyBlocks(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        AddressResolver resolver,
        uint64 maxBlocks
    )
        internal
    {
        uint64 i = state.slotB.lastVerifiedBlockId;
        TaikoData.Block storage blk =
            state.blocks[i % config.blockRingBufferSize];

        uint16 fcId = blk.verifiedForkChoiceId;
        assert(fcId > 0);

        TaikoToken tt = TaikoToken(resolver.resolve("taiko_token", false));
        bytes32 blockHash = blk.forkChoices[fcId].blockHash;
        uint32 gasUsed = blk.forkChoices[fcId].gasUsed;

        bytes32 signalRoot;
        TaikoData.ForkChoice memory fc;

        uint64 processed;
        unchecked {
            ++i;
        }

        while (i < state.slotB.numBlocks && processed < maxBlocks) {
            blk = state.blocks[i % config.blockRingBufferSize];

            fcId = LibUtils.getForkChoiceId(state, blk, i, blockHash, gasUsed);
            if (fcId == 0) break;

            fc = blk.forkChoices[fcId];
            if (fc.prover == address(0)) break;

            uint256 proofRegularCooldown = fc.prover == address(1)
                ? config.proofOracleCooldown
                : config.proofRegularCooldown;
            if (block.timestamp <= fc.provenAt + proofRegularCooldown) break;

            blockHash = fc.blockHash;
            gasUsed = fc.gasUsed;
            signalRoot = fc.signalRoot;
            blk.verifiedForkChoiceId = fcId;

            _rewardProver(config, tt, blk, fc);
            emit BlockVerified(i, fc.blockHash, fc.prover);

            unchecked {
                ++i;
                ++processed;
            }
        }

        if (processed > 0) {
            unchecked {
                state.slotB.lastVerifiedAt = uint64(block.timestamp);
                state.slotB.lastVerifiedBlockId += processed;
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
                state.slotB.lastVerifiedBlockId, blockHash, signalRoot
            );
        }
    }

    function _rewardProver(
        TaikoData.Config memory config,
        TaikoToken tt,
        TaikoData.Block storage blk,
        TaikoData.ForkChoice memory fc
    )
        private
    {
        if (
            fc.prover == address(1)
                || fc.provenAt <= blk.proposedAt + config.proofWindow
        ) {
            // Refund all the bond
            tt.transfer(blk.prover, config.proofBond);
        } else {
            // Reward half of the bond to the actual prover
            tt.transfer(fc.prover, config.proofBond / 2);
        }
    }
}
