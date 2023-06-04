// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

library TaikoData {
    struct Config {
        uint256 chainId;
        uint256 maxNumProposedBlocks;
        uint256 blockRingBufferSize;
        uint256 auctionRingBufferSize;
        // This number is calculated from maxNumProposedBlocks to make
        // the 'the maximum value of the multiplier' close to 20.0
        uint256 maxVerificationsPerTx;
        uint64 blockMaxGasLimit;
        uint64 maxTransactionsPerBlock;
        uint64 maxBytesPerTxList;
        uint256 txListCacheExpiry;
        uint256 proofCooldownPeriod;
        uint256 systemProofCooldownPeriod;
        uint256 realProofSkipSize;
        uint256 ethDepositGas;
        uint256 ethDepositMaxFee;
        uint64 minEthDepositsPerBlock;
        uint64 maxEthDepositsPerBlock;
        uint96 maxEthDepositAmount;
        uint96 minEthDepositAmount;
        //How long auction window will be open after the first bid
        uint16 auctionWindowInSec;
        //How long proof window will be granted to winning bidder
        uint64 auctionProofWindowMultiplier;
        uint64 auctionDepositMultipler;
        uint64 auctionMaxFeePerGasMultipler;
        uint16 auctionBatchSize;
        uint16 maxFeePerGas; // in wei
        uint16 auctonMaxAheadOfProposals;
        uint16 auctionMaxProofWindow;
        bool relaySignalRoot;
    }

    struct StateVariables {
        uint64 feePerGas;
        uint64 maxBlockFee;
        uint64 genesisHeight;
        uint64 genesisTimestamp;
        uint64 numBlocks;
        uint64 lastVerifiedBlockId;
        uint64 nextEthDepositToProcess;
        uint64 numEthDeposits;
    }

    // 3 slots
    struct BlockMetadataInput {
        bytes32 txListHash;
        address beneficiary;
        uint32 gasLimit;
        uint24 txListByteStart; // byte-wise start index (inclusive)
        uint24 txListByteEnd; // byte-wise end index (exclusive)
        uint8 cacheTxListInfo; // non-zero = True
    }

    // Changing this struct requires changing LibUtils.hashMetadata accordingly.
    struct BlockMetadata {
        uint64 id;
        uint64 timestamp;
        uint64 l1Height;
        bytes32 l1Hash;
        bytes32 mixHash;
        bytes32 txListHash;
        uint24 txListByteStart;
        uint24 txListByteEnd;
        uint32 gasLimit;
        address beneficiary;
        address treasury;
        TaikoData.EthDeposit[] depositsProcessed;
    }

    struct BlockEvidence {
        bytes32 metaHash;
        bytes32 parentHash;
        bytes32 blockHash;
        bytes32 signalRoot;
        bytes32 graffiti;
        address prover;
        uint32 parentGasUsed;
        uint32 gasUsed;
        uint16 verifierId;
        bytes proof;
    }

    // 4 slots
    struct ForkChoice {
        // Key is only written/read for the 1st fork choice.
        bytes32 key;
        bytes32 blockHash;
        bytes32 signalRoot;
        uint64 provenAt;
        address prover;
        uint32 gasUsed;
    }

    // 4 slots
    struct Block {
        // ForkChoice storage are reusable
        mapping(uint256 forkChoiceId => ForkChoice) forkChoices;
        bytes32 metaHash;
        uint64 blockId;
        uint64 proposedAt;
        uint64 feePerGas;
        uint32 gasLimit;
        address proposer;
        uint24 nextForkChoiceId;
        uint24 verifiedForkChoiceId;
    }

    // This struct takes 9 slots.
    struct TxListInfo {
        uint64 validSince;
        uint24 size;
    }

    // 2 slot
    struct EthDeposit {
        address recipient;
        uint96 amount;
        uint64 id;
    }

    struct Bid {
        address prover;
        uint64 deposit;
        uint64 feePerGas;
        // In order to refund the diff betwen gasUsed vs. blockMaxGasLimit
        uint64 blockMaxGasLimit;
        // It is also part of the bidding - how fast some can submit proofs
        // according to his/her own commitment.
        // Can be zero and it will just signal that the proofs are coming
        // somewhere within config.auctionWindowInSec
        uint16 proofWindow;
    }

    struct Auction {
        Bid bid;
        uint64 batchId;
        uint64 startedAt;
    }

    struct State {
        // Ring buffer for proposed blocks and a some recent verified blocks.
        mapping(uint256 blockId_mode_blockRingBufferSize => Block) blocks;
        mapping(
            uint256 blockId
                => mapping(
                    bytes32 parentHash
                        => mapping(uint32 parentGasUsed => uint256 forkChoiceId)
                )
            ) forkChoiceIds;
        mapping(address account => uint256 balance) taikoTokenBalances;
        mapping(bytes32 txListHash => TxListInfo) txListInfo;
        mapping(uint256 batchId => Auction auction) auctions;
        EthDeposit[] ethDeposits;
        // Never or rarely changed
        // Slot 7: never or rarely changed
        uint64 genesisHeight;
        uint64 genesisTimestamp;
        uint16 __reserved70;
        uint48 __reserved71;
        uint64 numOfAuctions;
        // Slot 8
        uint64 __reserved80;
        uint64 __reserved81;
        uint64 numBlocks;
        uint64 nextEthDepositToProcess;
        // Slot 9
        uint64 __reserved90;
        uint64 feePerGas;
        uint64 lastVerifiedBlockId;
        uint64 avgProofWindow;
        // Reserved
        uint256[42] __gap;
    }
}
