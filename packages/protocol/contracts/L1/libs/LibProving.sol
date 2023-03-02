// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import {AddressResolver} from "../../common/AddressResolver.sol";
import {BlockHeader, LibBlockHeader} from "../../libs/LibBlockHeader.sol";
import {LibRLPWriter} from "../../thirdparty/LibRLPWriter.sol";
import {LibUtils} from "./LibUtils.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {TaikoData} from "../../L1/TaikoData.sol";

library LibProving {
    using LibBlockHeader for BlockHeader;
    using LibUtils for bytes;
    using LibUtils for TaikoData.BlockMetadata;
    using LibUtils for TaikoData.State;

    event BlockProven(
        uint256 indexed id,
        bytes32 parentHash,
        bytes32 blockHash,
        address prover,
        uint64 provenAt
    );

    error L1_ALREADY_PROVEN();
    error L1_CANNOT_BE_FIRST_PROVER();
    error L1_CONFLICT_PROOF();
    error L1_ID();
    error L1_INPUT_SIZE();
    error L1_META_MISMATCH();
    error L1_NOT_ORACLE_PROVER();
    error L1_PROOF_LENGTH();
    error L1_PROVER();
    error L1_TX_LIST_PROOF();
    error L1_TX_LIST_PROOF_VERIFIED();
    error L1_ZKP();

    function proveBlock(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        AddressResolver resolver,
        uint256 blockId,
        bytes[] calldata inputs
    ) internal {
        // Check and decode inputs
        if (inputs.length != 1) revert L1_INPUT_SIZE();
        TaikoData.Evidence memory evidence = abi.decode(
            inputs[0],
            (TaikoData.Evidence)
        );

        _checkMetadata(state, config, evidence.meta, blockId);

        if (evidence.prover == address(0)) revert L1_PROVER();
        if (evidence.zkproof.data.length == 0) revert L1_PROOF_LENGTH();

        if (!config.skipValidatingHeaderForMetadata) {
            if (
                evidence.header.parentHash == 0 ||
                evidence.header.beneficiary != evidence.meta.beneficiary ||
                evidence.header.difficulty != 0 ||
                evidence.header.gasLimit !=
                evidence.meta.gasLimit + config.anchorTxGasLimit ||
                evidence.header.gasUsed == 0 ||
                evidence.header.timestamp != evidence.meta.timestamp ||
                evidence.header.extraData.length !=
                evidence.meta.extraData.length ||
                keccak256(evidence.header.extraData) !=
                keccak256(evidence.meta.extraData) ||
                evidence.header.mixHash != evidence.meta.mixHash
            ) revert L1_META_MISMATCH();
        }

        // For alpha-2 testnet, the network allows any address to submit ZKP,
        // but a special prover can skip ZKP verification if the ZKP is empty.

        bool oracleProving;

        TaikoData.ForkChoice storage fc = state.forkChoices[evidence.meta.id][
            evidence.header.parentHash
        ];

        bytes32 blockHash = evidence.header.hashBlockHeader();

        if (fc.blockHash == 0) {
            address oracleProver = resolver.resolve("oracle_prover", true);
            if (msg.sender == oracleProver) {
                oracleProving = true;
            } else {
                if (oracleProver != address(0)) revert L1_NOT_ORACLE_PROVER();
                fc.prover = evidence.prover;
                fc.provenAt = uint64(block.timestamp);
            }
            fc.blockHash = blockHash;
        } else {
            if (fc.blockHash != blockHash) revert L1_CONFLICT_PROOF();
            if (fc.prover != address(0)) revert L1_ALREADY_PROVEN();

            fc.prover = evidence.prover;
            fc.provenAt = uint64(block.timestamp);
        }

        if (!oracleProving && !config.skipZKPVerification) {
            bool verified = _verifyZKProof(
                resolver,
                evidence.zkproof,
                _getInstance(evidence)
            );
            if (!verified) revert L1_ZKP();
        }

        emit BlockProven({
            id: evidence.meta.id,
            parentHash: evidence.header.parentHash,
            blockHash: blockHash,
            prover: fc.prover,
            provenAt: fc.provenAt
        });
    }

    function proveBlockInvalid(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        AddressResolver resolver,
        uint256 blockId,
        bytes[] calldata inputs
    ) internal {
        // Check inputs
        if (inputs.length != 3) revert L1_INPUT_SIZE();
        bytes calldata metaBytes = inputs[0];
        bytes calldata txListProof = inputs[1];
        bytes32 parentHash = bytes32(inputs[2]);

        TaikoData.BlockMetadata memory meta = abi.decode(
            metaBytes,
            (TaikoData.BlockMetadata)
        );

        _checkMetadata(state, config, meta, blockId);

        if (txListProof.hashTxListProof() != meta.txListProofHash)
            revert L1_TX_LIST_PROOF();

        TaikoData.ZKProof memory zkproof = abi.decode(
            txListProof,
            (TaikoData.ZKProof)
        );

        bool verified = _verifyZKProof(resolver, zkproof, meta.txListHash);
        if (verified) revert L1_TX_LIST_PROOF_VERIFIED();

        TaikoData.ForkChoice storage fc = state.forkChoices[meta.id][
            parentHash
        ];

        fc.prover = msg.sender;
        fc.provenAt = uint64(block.timestamp);
        fc.blockHash = LibUtils.BLOCK_DEADEND_HASH;

        emit BlockProven({
            id: meta.id,
            parentHash: parentHash,
            blockHash: LibUtils.BLOCK_DEADEND_HASH,
            prover: msg.sender,
            provenAt: uint64(block.timestamp)
        });
    }

    function _checkMetadata(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        TaikoData.BlockMetadata memory meta,
        uint256 blockId
    ) private view {
        if (meta.id != blockId) revert L1_ID();

        if (config.skipCheckingMetadata) return;

        if (meta.id <= state.latestVerifiedId || meta.id >= state.nextBlockId)
            revert L1_ID();
        if (
            state.getProposedBlock(config.maxNumBlocks, meta.id).metaHash !=
            meta.hashMetadata()
        ) revert L1_META_MISMATCH();
    }

    function _verifyZKProof(
        AddressResolver resolver,
        TaikoData.ZKProof memory zkproof,
        bytes32 instance
    ) private view returns (bool verified) {
        address verifier = resolver.resolve(
            string.concat("verifier_", Strings.toString(zkproof.circuitId)),
            false
        );
        (verified, ) = verifier.staticcall(
            bytes.concat(
                bytes16(0),
                bytes16(instance), // left 16 bytes of the given instance
                bytes16(0),
                bytes16(uint128(uint256(instance))), // right 16 bytes of the given instance
                zkproof.data
            )
        );
    }

    function _getInstance(
        TaikoData.Evidence memory evidence
    ) private pure returns (bytes32) {
        bytes[] memory list = LibBlockHeader.getBlockHeaderRLPItemsList(
            evidence.header,
            5
        );

        uint256 i = list.length;
        list[--i] = LibRLPWriter.writeHash(evidence.meta.txListHash);
        list[--i] = LibRLPWriter.writeHash(evidence.meta.txListProofHash);
        list[--i] = LibRLPWriter.writeAddress(evidence.prover);
        list[--i] = LibRLPWriter.writeHash(evidence.meta.l1Hash);
        list[--i] = LibRLPWriter.writeHash(bytes32(evidence.meta.l1Height));
        return keccak256(LibRLPWriter.writeList(list));
    }
}
