---
title: TaikoData
---

## TaikoData

### Config

```solidity
struct Config {
  uint256 chainId;
  uint256 maxNumBlocks;
  uint256 blockHashHistory;
  uint256 maxVerificationsPerTx;
  uint256 blockMaxGasLimit;
  uint256 maxTransactionsPerBlock;
  uint256 maxBytesPerTxList;
  uint256 minTxGasLimit;
  uint256 anchorTxGasLimit;
  uint256 slotSmoothingFactor;
  uint256 rewardBurnBips;
  uint256 proposerDepositPctg;
  uint256 feeBaseMAF;
  uint256 blockTimeMAF;
  uint256 proofTimeMAF;
  uint64 rewardMultiplierPctg;
  uint64 feeGracePeriodPctg;
  uint64 feeMaxPeriodPctg;
  uint64 blockTimeCap;
  uint64 proofTimeCap;
  uint64 bootstrapDiscountHalvingPeriod;
  bool enableTokenomics;
  bool skipZKPVerification;
}
```

### BlockMetadata

```solidity
struct BlockMetadata {
  uint256 id;
  uint256 l1Height;
  bytes32 l1Hash;
  address beneficiary;
  bytes32 txListHash;
  bytes32 mixHash;
  bytes extraData;
  uint64 gasLimit;
  uint64 timestamp;
}
```

### ZKProof

```solidity
struct ZKProof {
  bytes data;
  uint256 circuitId;
}
```

### ValidBlockEvidence

```solidity
struct ValidBlockEvidence {
  struct TaikoData.BlockMetadata meta;
  struct TaikoData.ZKProof zkproof;
  struct BlockHeader header;
  bytes32 signalRoot;
  address prover;
}
```

### InvalidBlockEvidence

```solidity
struct InvalidBlockEvidence {
  struct TaikoData.BlockMetadata meta;
  struct TaikoData.ZKProof zkproof;
  bytes32 parentHash;
}
```

### ProposedBlock

```solidity
struct ProposedBlock {
  bytes32 metaHash;
  uint256 deposit;
  address proposer;
  uint64 proposedAt;
}
```

### ForkChoice

```solidity
struct ForkChoice {
  struct Snippet snippet;
  address prover;
  uint64 provenAt;
}
```

### State

```solidity
struct State {
  mapping(uint256 => struct TaikoData.ProposedBlock) proposedBlocks;
  mapping(uint256 => mapping(bytes32 => struct TaikoData.ForkChoice)) forkChoices;
  mapping(uint256 => struct Snippet) l2Snippets;
  mapping(address => uint256) balances;
  uint64 genesisHeight;
  uint64 genesisTimestamp;
  uint64 __reserved1;
  uint64 __reserved2;
  uint256 feeBase;
  uint64 nextBlockId;
  uint64 lastProposedAt;
  uint64 avgBlockTime;
  uint64 __reserved3;
  uint64 latestVerifiedHeight;
  uint64 latestVerifiedId;
  uint64 avgProofTime;
  uint64 __reserved4;
  uint256[42] __gap;
}
```
