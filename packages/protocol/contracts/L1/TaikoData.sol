// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.20;

library TaikoData {
    struct Config {
        uint256 chainId;
        uint256 maxNumProposedBlocks;
        uint256 blockRingBufferSize;
        // This number is calculated from maxNumProposedBlocks to make
        // the 'the maximum value of the multiplier' close to 20.0
        uint256 maxVerificationsPerTx;
        uint64 blockMaxGasLimit;
        uint64 blockFeeBaseGas;
        uint64 maxTransactionsPerBlock;
        uint64 maxBytesPerTxList;
        uint256 txListCacheExpiry;
        uint256 proofCooldownPeriod;
        uint256 systemProofCooldownPeriod;
        uint256 ethDepositRingBufferSize;
        uint64 ethDepositMinCountPerBlock;
        uint64 ethDepositMaxCountPerBlock;
        uint96 ethDepositMaxAmount;
        uint96 ethDepositMinAmount;
        uint256 ethDepositGas;
        uint256 ethDepositMaxFee;
        bool relaySignalRoot;
    }

    struct StateVariables {
        uint32 feePerGas;
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
        bool cacheTxListInfo;
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
        address prover;
        uint64 provenAt;
        uint32 gasUsed;
    }

    // 5 slots
    struct Block {
        // slot 1: ForkChoice storage are reusable
        mapping(uint256 forkChoiceId => ForkChoice) forkChoices;
        // slot 2
        bytes32 metaHash;
        // slot 3: (14 bytes available)
        uint64 blockId;
        uint32 gasLimit;
        uint24 nextForkChoiceId;
        uint24 verifiedForkChoiceId;
        // slot 4
        address proposer;
        uint32 feePerGas;
        uint64 proposedAt;
        // slot 5
        address prover;
        uint32 rewardPerGas;
        uint64 proofWindow;
    }

    struct TxListInfo {
        uint64 validSince;
        uint24 size;
    }

    struct EthDeposit {
        address recipient;
        uint96 amount;
        uint64 id;
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
        mapping(bytes32 txListHash => TxListInfo) txListInfo;
        mapping(uint256 depositId_mode_ethDepositRingBufferSize => uint256)
            ethDeposits;
        // Never or rarely changed
        // Slot 7: never or rarely changed
        uint64 genesisHeight;
        uint64 genesisTimestamp;
        uint64 __reserved70;
        uint64 __reserved71;
        // Slot 8
        uint64 __reserved80;
        uint64 numEthDeposits;
        uint64 numBlocks;
        uint64 nextEthDepositToProcess;
        // Slot 9
        uint64 lastVerifiedAt;
        uint64 lastVerifiedBlockId;
        uint32 feePerGas;
        uint16 avgProofDelay;
        uint64 __reserved90;
        // Reserved
        uint256[42] __gap; // TODO: update this
    }
}
