---
title: ProverPool2
---

## ProverPool2

### NUM_SLOTS

```solidity
uint256 NUM_SLOTS
```

### EXIT_PERIOD

```solidity
uint256 EXIT_PERIOD
```

### totalStaked

```solidity
uint256 totalStaked
```

### totalWeight

```solidity
uint256 totalWeight
```

### Staker

```solidity
struct Staker {
  uint256 amount;
  uint256 numSlots;
  uint256 maxNumSlots;
  uint256 unstakedAt;
  uint16 rewardPerGas;
}
```

### slots

```solidity
mapping(uint256 => address) slots
```

### stakers

```solidity
mapping(address => struct ProverPool2.Staker) stakers
```

### init

```solidity
function init(address _addressManager) external
```

### assignProver

```solidity
function assignProver(uint64 blockId, uint32 feePerGas) external view returns (address prover, uint32 rewardPerGas)
```

### stake

```solidity
function stake(uint256 amount, uint16 rewardPerGas) external
```

### unstake

```solidity
function unstake() external
```

### setRewardPerGas

```solidity
function setRewardPerGas(uint16 rewardPerGas) external
```

### setMaxNumSlots

```solidity
function setMaxNumSlots(address staker, uint16 maxNumSlots) external
```

### claimSlot

```solidity
function claimSlot(address staker, uint256 slotIdx) external
```

### slashProver

```solidity
function slashProver(address staker) external
```

### withdraw

```solidity
function withdraw(address staker) public
```

### getWeight

```solidity
function getWeight(address staker) public view returns (uint256)
```

### getNumClaimableSlots

```solidity
function getNumClaimableSlots(address staker) public view returns (uint256)
```

### isSlotClaimable

```solidity
function isSlotClaimable(uint256 slotIdx) public view returns (bool)
```

### getClaimableSlots

```solidity
function getClaimableSlots() public view returns (uint256[])
```

---

## title: ProxiedProverPool2

## ProxiedProverPool2
