// SPDX-License-Identifier: MIT
//
// ╭━━━━╮╱╱╭╮╱╱╱╱╱╭╮╱╱╱╱╱╭╮
// ┃╭╮╭╮┃╱╱┃┃╱╱╱╱╱┃┃╱╱╱╱╱┃┃
// ╰╯┃┃┣┻━┳┫┃╭┳━━╮┃┃╱╱╭━━┫╰━┳━━╮
// ╱╱┃┃┃╭╮┣┫╰╯┫╭╮┃┃┃╱╭┫╭╮┃╭╮┃━━┫
// ╱╱┃┃┃╭╮┃┃╭╮┫╰╯┃┃╰━╯┃╭╮┃╰╯┣━━┃
// ╱╱╰╯╰╯╰┻┻╯╰┻━━╯╰━━━┻╯╰┻━━┻━━╯
pragma solidity ^0.8.9;

import "../../common/ConfigManager.sol";
import "../../libs/LibConstants.sol";
import "../../libs/LibTxDecoder.sol";
import "../LibData.sol";
import "../TkoToken.sol";
import "./V1Utils.sol";

/// @author dantaik <dan@taiko.xyz>
library V1Proposing {
    using LibTxDecoder for bytes;
    using SafeCastUpgradeable for uint256;
    using LibData for LibData.State;

    event BlockCommitted(bytes32 hash, uint256 validSince);
    event BlockProposed(uint256 indexed id, LibData.BlockMetadata meta);

    function commitBlock(LibData.State storage s, bytes32 commitHash) public {
        require(commitHash != 0, "L1:hash");
        require(s.commits[commitHash] == 0, "L1:committed");
        s.commits[commitHash] = block.number;

        emit BlockCommitted(
            commitHash,
            block.number + LibConstants.TAIKO_COMMIT_DELAY_CONFIRMATIONS
        );
    }

    function proposeBlock(
        LibData.State storage s,
        AddressResolver resolver,
        bytes[] calldata inputs
    ) public {
        require(inputs.length == 2, "L1:inputs:size");
        LibData.BlockMetadata memory meta = abi.decode(
            inputs[0],
            (LibData.BlockMetadata)
        );
        bytes calldata txList = inputs[1];

        _validateMetadata(meta);

        s.lastProposedAt = meta.timestamp;

        bytes32 commitHash = _calculateCommitHash(
            meta.beneficiary,
            meta.txListHash
        );

        require(isCommitValid(s, commitHash), "L1:commit");
        delete s.commits[commitHash];

        require(
            txList.length > 0 &&
                txList.length <= LibConstants.TAIKO_TXLIST_MAX_BYTES &&
                meta.txListHash == txList.hashTxList(),
            "L1:txList"
        );
        require(
            s.nextBlockId <
                s.latestFinalizedId + LibConstants.TAIKO_BLOCK_BUFFER_SIZE,
            "L1:tooMany"
        );

        meta.id = s.nextBlockId;
        meta.l1Height = block.number - 1;
        meta.l1Hash = blockhash(block.number - 1);
        meta.timestamp = uint64(block.timestamp);

        // if multiple L2 blocks included in the same L1 block,
        // their block.mixHash fields for randomness will be the same.
        meta.mixHash = bytes32(block.difficulty);

        s.saveProposedBlock(
            s.nextBlockId,
            LibData.ProposedBlock({
                metaHash: LibData.hashMetadata(meta),
                proposer: msg.sender,
                gasLimit: meta.gasLimit
            })
        );

        uint64 blockTime = meta.timestamp - s.lastProposedAt;
        (uint256 fee, uint256 premiumFee) = getBlockFee(s);
        s.avgFee = V1Utils.movingAverage(s.avgFee, fee, 1024);

        s.avgBlockTime = V1Utils
            .movingAverage(s.avgBlockTime, blockTime, 1024)
            .toUint64();

        s.avgGasLimit = V1Utils
            .movingAverage(s.avgGasLimit, meta.gasLimit, 1024)
            .toUint64();

        s.lastProposedAt = meta.timestamp;

        uint256 proposerBootstrapReward = _calcProposerBootstrapReward(s);
        TkoToken tkoToken = TkoToken(resolver.resolve("tko_token"));
        if (proposerBootstrapReward > premiumFee) {
            tkoToken.mint(msg.sender, proposerBootstrapReward - premiumFee);
        } else {
            tkoToken.burn(msg.sender, premiumFee - proposerBootstrapReward);
        }

        emit BlockProposed(s.nextBlockId++, meta);
    }

    function getBlockFee(LibData.State storage s)
        public
        view
        returns (uint256 fee, uint256 premiumFee)
    {
        uint256 scale = V1Utils.feeScale(
            uint64(block.timestamp),
            s.lastProposedAt,
            s.avgProofTime
        );
        fee = (s.avgFee * 10000) / scale;
        premiumFee = V1Utils.applyOversellPremium(s, fee, false);
    }

    function isCommitValid(LibData.State storage s, bytes32 hash)
        public
        view
        returns (bool)
    {
        return
            hash != 0 &&
            s.commits[hash] != 0 &&
            block.number >=
            s.commits[hash] + LibConstants.TAIKO_COMMIT_DELAY_CONFIRMATIONS;
    }

    function _updateAvgBlockTime(LibData.State storage s, uint64 blockTime)
        private
    {
        if (s.avgBlockTime == 0) {
            s.avgBlockTime = blockTime;
        } else {
            s.avgBlockTime = (1023 * s.avgBlockTime + blockTime) / 1024;
        }
    }

    function _calcProposerBootstrapReward(LibData.State storage s)
        private
        view
        returns (uint256 proposerReward)
    {
        uint256 e = block.timestamp - s.genesisTimestamp;
        uint256 d = LibConstants.TAIKO_REWARD_BOOTSTRAP_DURATION;

        if (e >= d) {
            return 0;
        } else {
            uint256 a = LibConstants.TAIKO_REWARD_BOOTSTRAP_AMOUNT;
            uint256 b = block.timestamp - s.lastProposedAt;
            return (2 * a * b * (d - e + b / 2)) / d / d;
        }
    }

    function _validateMetadata(LibData.BlockMetadata memory meta) private pure {
        require(
            meta.id == 0 &&
                meta.l1Height == 0 &&
                meta.l1Hash == 0 &&
                meta.mixHash == 0 &&
                meta.timestamp == 0 &&
                meta.beneficiary != address(0) &&
                meta.txListHash != 0,
            "L1:placeholder"
        );

        require(
            meta.gasLimit <= LibConstants.TAIKO_BLOCK_MAX_GAS_LIMIT,
            "L1:gasLimit"
        );
        require(meta.extraData.length <= 32, "L1:extraData");
    }

    function _calculateCommitHash(address beneficiary, bytes32 txListHash)
        private
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(beneficiary, txListHash));
    }
}
