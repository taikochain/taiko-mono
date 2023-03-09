// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {AddressResolver} from "../../common/AddressResolver.sol";
import {LibTokenomics} from "./LibTokenomics.sol";
import {LibUtils} from "./LibUtils.sol";
import {Snippet} from "../../common/IXchainSync.sol";
import {TaikoData} from "../../L1/TaikoData.sol";

library LibProving {
    using LibUtils for TaikoData.State;

    event BlockProven(uint256 indexed id, bytes32 parentHash);

    error L1_ALREADY_PROVEN();
    error L1_CONFLICT_PROOF();
    error L1_EVIDENCE_MISMATCH();
    error L1_ID();
    error L1_INVALID_PROOF();
    error L1_NONZERO_SIGNAL_ROOT();
    error L1_NOT_ORACLE_PROVER();

    function proveBlock(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        AddressResolver resolver,
        uint256 blockId,
        TaikoData.BlockEvidence calldata evidence
    ) internal {
        TaikoData.BlockMetadata calldata meta = evidence.meta;
        if (
            meta.id != blockId ||
            meta.id <= state.latestVerifiedId ||
            meta.id >= state.nextBlockId
        ) revert L1_ID();

        if (
            state.getProposedBlock(config.maxNumBlocks, meta.id).metaHash !=
            keccak256(abi.encode(meta))
        ) revert L1_EVIDENCE_MISMATCH();

        bool oracleProving;
        TaikoData.ForkChoice storage fc = state.forkChoices[blockId][
            evidence.parentHash
        ];

        if (fc.snippet.blockHash == 0) {
            if (config.enableOracleProver) {
                if (msg.sender != resolver.resolve("oracle_prover", false))
                    revert L1_NOT_ORACLE_PROVER();

                oracleProving = true;
            }

            fc.snippet = Snippet(evidence.blockHash, evidence.signalRoot);

            if (!oracleProving) {
                fc.prover = prover;
                fc.provenAt = uint64(block.timestamp);
            }
        } else {
            if (fc.prover != address(0)) revert L1_ALREADY_PROVEN();
            if (
                fc.snippet.blockHash != evidence.blockHash ||
                fc.snippet.signalRoot != evidence.signalRoot
            ) revert L1_CONFLICT_PROOF();

            fc.prover = evidence.prover;
            fc.provenAt = uint64(block.timestamp);
        }

        if (!oracleProving && !config.skipZKPVerification) {
            // Do not revert when circuitId is invalid.
            address verifier = resolver.resolve(
                 abi.encodePacked(
                    "plonk_verifier",
                    evidence.zkproof.circuitId
                ),
                true
            );
            if (verifier == address(0)) revert L1_INVALID_PROOF();

            bytes32 instance;
            if (evidence.blockHash == LibUtils.BLOCK_DEADEND_HASH) {
                if (evidence.signalRoot != 0) revert L1_NONZERO_SIGNAL_ROOT();
                instance = evidence.meta.txListHash;
            } else {
                address l1SignalService = resolver.resolve(
                    "signal_service",
                    false
                );
                address l2SignalService = resolver.resolve(
                    config.chainId,
                    "signal_service",
                    false
                );

                instance = keccak256(
                    bytes.concat(
                        // for checking anchor tx
                        bytes32(uint256(uint160(l1SignalService))),
                        // for checking signalRoot
                        bytes32(uint256(uint160(l2SignalService))),
                        evidence.blockHash,
                        evidence.signalRoot,
                        bytes32(uint256(uint160(evidence.prover))),
                        bytes32(uint256(evidence.meta.id)),
                        bytes32(evidence.meta.l1Height),
                        evidence.meta.l1Hash,
                        evidence.meta.txListHash
                    )
                );
            }

            (bool verified, ) = verifier.staticcall(
                bytes.concat(
                    bytes16(0),
                    bytes16(instance), // left 16 bytes of the given instance
                    bytes16(0),
                    bytes16(uint128(uint256(instance))), // right 16 bytes of the given instance
                    evidence.zkproof.data
                )
            );

            if (!verified) revert L1_INVALID_PROOF();
        }

        emit BlockProven({id: blockId, parentHash: parentHash});
    }
}
