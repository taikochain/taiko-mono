---
title: TaikoData
---

## TaikoData

### Config

```solidity
struct Config {
  uint256 chainId;
  uint256 maxNumProposedBlocks;
  uint256 ringBufferSize;
  uint256 maxNumVerifiedBlocks;
  uint256 maxVerificationsPerTx;
  uint256 blockMaxGasLimit;
  uint256 maxTransactionsPerBlock;
  uint256 maxBytesPerTxList;
  uint256 minTxGasLimit;
  uint256 txListCacheExpiry;
  uint64 proofTimeTarget;
  uint8 adjustmentQuotient;
  bool enableSoloProposer;
  bool enableOracleProver;
  bool enableTokenomics;
  bool skipZKPVerification;
}
```

### StateVariables

```solidity
struct StateVariables {
  uint64 basefee;
  uint64 rewardPool;
  uint64 genesisHeight;
  uint64 genesisTimestamp;
  uint64 numBlocks;
  uint64 lastVerifiedBlockId;
  uint64 lastProposedAt;
}
```

### BlockMetadataInput

```solidity
struct BlockMetadataInput {
  bytes32 txListHash;
  address beneficiary;
  uint32 gasLimit;
  uint24 txListByteStart;
  uint24 txListByteEnd;
  uint8 cacheTxListInfo;
}
```

### BlockMetadata

```solidity
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
}
```

### ZKProof

```solidity
struct ZKProof {
  bytes data;
  uint16 verifierId;
}
```

### BlockEvidence

```solidity
struct BlockEvidence {
  struct TaikoData.BlockMetadata meta;
  struct TaikoData.ZKProof zkproof;
  bytes32 parentHash;
  bytes32 blockHash;
  bytes32 signalRoot;
  bytes32 graffiti;
  address prover;
  uint32 gasUsed;
}
```

### ForkChoice

```solidity
struct ForkChoice {
  bytes32 blockHash;
  bytes32 signalRoot;
  uint64 provenAt;
  uint32 gasUsed;
  address prover;
}
```

### Block

```solidity
struct Block {
  mapping(uint256 => struct TaikoData.ForkChoice) forkChoices;
  uint64 blockId;
  uint64 proposedAt;
  uint64 deposit;
  uint24 nextForkChoiceId;
  uint24 verifiedForkChoiceId;
  bytes32 metaHash;
  address proposer;
}
```

### TxListInfo

```solidity
struct TxListInfo {
  uint64 validSince;
  uint24 size;
}
```

### State

```solidity
struct State {
  mapping(uint256 => struct TaikoData.Block) blocks;
  mapping(uint256 => mapping(bytes32 => uint256)) forkChoiceIds;
  mapping(address => uint256) balances;
  mapping(bytes32 => struct TaikoData.TxListInfo) txListInfo;
  uint64 genesisHeight;
  uint64 genesisTimestamp;
  uint64 __reserved51;
  uint64 __reserved52;
  uint64 lastProposedAt;
  uint64 numBlocks;
  uint64 accProposedAt;
  uint64 rewardPool;
  uint64 basefee;
  uint64 proofTimeIssued;
  uint64 lastVerifiedBlockId;
  uint64 __reserved81;
  uint256[43] __gap;
}
```
