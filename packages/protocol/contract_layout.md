## contracts/L1/TaikoL1.sol:TaikoL1
| Name           | Type                   | Slot | Offset | Bytes | Contract                         |
|----------------|------------------------|------|--------|-------|----------------------------------|
| _initialized   | uint8                  | 0    | 0      | 1     | contracts/L1/TaikoL1.sol:TaikoL1 |
| _initializing  | bool                   | 0    | 1      | 1     | contracts/L1/TaikoL1.sol:TaikoL1 |
| __gap          | uint256[50]            | 1    | 0      | 1600  | contracts/L1/TaikoL1.sol:TaikoL1 |
| _owner         | address                | 51   | 0      | 20    | contracts/L1/TaikoL1.sol:TaikoL1 |
| __gap          | uint256[49]            | 52   | 0      | 1568  | contracts/L1/TaikoL1.sol:TaikoL1 |
| _pendingOwner  | address                | 101  | 0      | 20    | contracts/L1/TaikoL1.sol:TaikoL1 |
| __gap          | uint256[49]            | 102  | 0      | 1568  | contracts/L1/TaikoL1.sol:TaikoL1 |
| addressManager | address                | 151  | 0      | 20    | contracts/L1/TaikoL1.sol:TaikoL1 |
| __gap          | uint256[49]            | 152  | 0      | 1568  | contracts/L1/TaikoL1.sol:TaikoL1 |
| __reentry      | uint8                  | 201  | 0      | 1     | contracts/L1/TaikoL1.sol:TaikoL1 |
| __paused       | uint8                  | 201  | 1      | 1     | contracts/L1/TaikoL1.sol:TaikoL1 |
| lastUnpausedAt | uint64                 | 201  | 2      | 8     | contracts/L1/TaikoL1.sol:TaikoL1 |
| __gap          | uint256[49]            | 202  | 0      | 1568  | contracts/L1/TaikoL1.sol:TaikoL1 |
| state          | struct TaikoData.State | 251  | 0      | 1600  | contracts/L1/TaikoL1.sol:TaikoL1 |
| __gap          | uint256[50]            | 301  | 0      | 1600  | contracts/L1/TaikoL1.sol:TaikoL1 |

## contracts/L2/TaikoL2.sol:TaikoL2
| Name            | Type                        | Slot | Offset | Bytes | Contract                         |
|-----------------|-----------------------------|------|--------|-------|----------------------------------|
| _initialized    | uint8                       | 0    | 0      | 1     | contracts/L2/TaikoL2.sol:TaikoL2 |
| _initializing   | bool                        | 0    | 1      | 1     | contracts/L2/TaikoL2.sol:TaikoL2 |
| __gap           | uint256[50]                 | 1    | 0      | 1600  | contracts/L2/TaikoL2.sol:TaikoL2 |
| _owner          | address                     | 51   | 0      | 20    | contracts/L2/TaikoL2.sol:TaikoL2 |
| __gap           | uint256[49]                 | 52   | 0      | 1568  | contracts/L2/TaikoL2.sol:TaikoL2 |
| _pendingOwner   | address                     | 101  | 0      | 20    | contracts/L2/TaikoL2.sol:TaikoL2 |
| __gap           | uint256[49]                 | 102  | 0      | 1568  | contracts/L2/TaikoL2.sol:TaikoL2 |
| addressManager  | address                     | 151  | 0      | 20    | contracts/L2/TaikoL2.sol:TaikoL2 |
| __gap           | uint256[49]                 | 152  | 0      | 1568  | contracts/L2/TaikoL2.sol:TaikoL2 |
| __reentry       | uint8                       | 201  | 0      | 1     | contracts/L2/TaikoL2.sol:TaikoL2 |
| __paused        | uint8                       | 201  | 1      | 1     | contracts/L2/TaikoL2.sol:TaikoL2 |
| lastUnpausedAt  | uint64                      | 201  | 2      | 8     | contracts/L2/TaikoL2.sol:TaikoL2 |
| __gap           | uint256[49]                 | 202  | 0      | 1568  | contracts/L2/TaikoL2.sol:TaikoL2 |
| l2Hashes        | mapping(uint256 => bytes32) | 251  | 0      | 32    | contracts/L2/TaikoL2.sol:TaikoL2 |
| publicInputHash | bytes32                     | 252  | 0      | 32    | contracts/L2/TaikoL2.sol:TaikoL2 |
| parentGasExcess | uint64                      | 253  | 0      | 8     | contracts/L2/TaikoL2.sol:TaikoL2 |
| lastSyncedBlock | uint64                      | 253  | 8      | 8     | contracts/L2/TaikoL2.sol:TaikoL2 |
| parentTimestamp | uint64                      | 253  | 16     | 8     | contracts/L2/TaikoL2.sol:TaikoL2 |
| parentGasTarget | uint64                      | 253  | 24     | 8     | contracts/L2/TaikoL2.sol:TaikoL2 |
| l1ChainId       | uint64                      | 254  | 0      | 8     | contracts/L2/TaikoL2.sol:TaikoL2 |
| __gap           | uint256[46]                 | 255  | 0      | 1472  | contracts/L2/TaikoL2.sol:TaikoL2 |

## contracts/signal/SignalService.sol:SignalService
| Name           | Type                                          | Slot | Offset | Bytes | Contract                                         |
|----------------|-----------------------------------------------|------|--------|-------|--------------------------------------------------|
| _initialized   | uint8                                         | 0    | 0      | 1     | contracts/signal/SignalService.sol:SignalService |
| _initializing  | bool                                          | 0    | 1      | 1     | contracts/signal/SignalService.sol:SignalService |
| __gap          | uint256[50]                                   | 1    | 0      | 1600  | contracts/signal/SignalService.sol:SignalService |
| _owner         | address                                       | 51   | 0      | 20    | contracts/signal/SignalService.sol:SignalService |
| __gap          | uint256[49]                                   | 52   | 0      | 1568  | contracts/signal/SignalService.sol:SignalService |
| _pendingOwner  | address                                       | 101  | 0      | 20    | contracts/signal/SignalService.sol:SignalService |
| __gap          | uint256[49]                                   | 102  | 0      | 1568  | contracts/signal/SignalService.sol:SignalService |
| addressManager | address                                       | 151  | 0      | 20    | contracts/signal/SignalService.sol:SignalService |
| __gap          | uint256[49]                                   | 152  | 0      | 1568  | contracts/signal/SignalService.sol:SignalService |
| __reentry      | uint8                                         | 201  | 0      | 1     | contracts/signal/SignalService.sol:SignalService |
| __paused       | uint8                                         | 201  | 1      | 1     | contracts/signal/SignalService.sol:SignalService |
| lastUnpausedAt | uint64                                        | 201  | 2      | 8     | contracts/signal/SignalService.sol:SignalService |
| __gap          | uint256[49]                                   | 202  | 0      | 1568  | contracts/signal/SignalService.sol:SignalService |
| topBlockId     | mapping(uint64 => mapping(bytes32 => uint64)) | 251  | 0      | 32    | contracts/signal/SignalService.sol:SignalService |
| isAuthorized   | mapping(address => bool)                      | 252  | 0      | 32    | contracts/signal/SignalService.sol:SignalService |
| __gap          | uint256[48]                                   | 253  | 0      | 1536  | contracts/signal/SignalService.sol:SignalService |

## contracts/bridge/Bridge.sol:Bridge
| Name           | Type                                    | Slot | Offset | Bytes | Contract                           |
|----------------|-----------------------------------------|------|--------|-------|------------------------------------|
| _initialized   | uint8                                   | 0    | 0      | 1     | contracts/bridge/Bridge.sol:Bridge |
| _initializing  | bool                                    | 0    | 1      | 1     | contracts/bridge/Bridge.sol:Bridge |
| __gap          | uint256[50]                             | 1    | 0      | 1600  | contracts/bridge/Bridge.sol:Bridge |
| _owner         | address                                 | 51   | 0      | 20    | contracts/bridge/Bridge.sol:Bridge |
| __gap          | uint256[49]                             | 52   | 0      | 1568  | contracts/bridge/Bridge.sol:Bridge |
| _pendingOwner  | address                                 | 101  | 0      | 20    | contracts/bridge/Bridge.sol:Bridge |
| __gap          | uint256[49]                             | 102  | 0      | 1568  | contracts/bridge/Bridge.sol:Bridge |
| addressManager | address                                 | 151  | 0      | 20    | contracts/bridge/Bridge.sol:Bridge |
| __gap          | uint256[49]                             | 152  | 0      | 1568  | contracts/bridge/Bridge.sol:Bridge |
| __reentry      | uint8                                   | 201  | 0      | 1     | contracts/bridge/Bridge.sol:Bridge |
| __paused       | uint8                                   | 201  | 1      | 1     | contracts/bridge/Bridge.sol:Bridge |
| lastUnpausedAt | uint64                                  | 201  | 2      | 8     | contracts/bridge/Bridge.sol:Bridge |
| __gap          | uint256[49]                             | 202  | 0      | 1568  | contracts/bridge/Bridge.sol:Bridge |
| __reserved1    | uint64                                  | 251  | 0      | 8     | contracts/bridge/Bridge.sol:Bridge |
| nextMessageId  | uint64                                  | 251  | 8      | 8     | contracts/bridge/Bridge.sol:Bridge |
| messageStatus  | mapping(bytes32 => enum IBridge.Status) | 252  | 0      | 32    | contracts/bridge/Bridge.sol:Bridge |
| __ctx          | struct IBridge.Context                  | 253  | 0      | 64    | contracts/bridge/Bridge.sol:Bridge |
| __reserved2    | uint256                                 | 255  | 0      | 32    | contracts/bridge/Bridge.sol:Bridge |
| __reserved3    | uint256                                 | 256  | 0      | 32    | contracts/bridge/Bridge.sol:Bridge |
| __gap          | uint256[44]                             | 257  | 0      | 1408  | contracts/bridge/Bridge.sol:Bridge |

## contracts/L2/DelegateOwner.sol:DelegateOwner
| Name           | Type        | Slot | Offset | Bytes | Contract                                     |
|----------------|-------------|------|--------|-------|----------------------------------------------|
| _initialized   | uint8       | 0    | 0      | 1     | contracts/L2/DelegateOwner.sol:DelegateOwner |
| _initializing  | bool        | 0    | 1      | 1     | contracts/L2/DelegateOwner.sol:DelegateOwner |
| __gap          | uint256[50] | 1    | 0      | 1600  | contracts/L2/DelegateOwner.sol:DelegateOwner |
| _owner         | address     | 51   | 0      | 20    | contracts/L2/DelegateOwner.sol:DelegateOwner |
| __gap          | uint256[49] | 52   | 0      | 1568  | contracts/L2/DelegateOwner.sol:DelegateOwner |
| _pendingOwner  | address     | 101  | 0      | 20    | contracts/L2/DelegateOwner.sol:DelegateOwner |
| __gap          | uint256[49] | 102  | 0      | 1568  | contracts/L2/DelegateOwner.sol:DelegateOwner |
| addressManager | address     | 151  | 0      | 20    | contracts/L2/DelegateOwner.sol:DelegateOwner |
| __gap          | uint256[49] | 152  | 0      | 1568  | contracts/L2/DelegateOwner.sol:DelegateOwner |
| __reentry      | uint8       | 201  | 0      | 1     | contracts/L2/DelegateOwner.sol:DelegateOwner |
| __paused       | uint8       | 201  | 1      | 1     | contracts/L2/DelegateOwner.sol:DelegateOwner |
| lastUnpausedAt | uint64      | 201  | 2      | 8     | contracts/L2/DelegateOwner.sol:DelegateOwner |
| __gap          | uint256[49] | 202  | 0      | 1568  | contracts/L2/DelegateOwner.sol:DelegateOwner |
| remoteChainId  | uint64      | 251  | 0      | 8     | contracts/L2/DelegateOwner.sol:DelegateOwner |
| admin          | address     | 251  | 8      | 20    | contracts/L2/DelegateOwner.sol:DelegateOwner |
| nextTxId       | uint64      | 252  | 0      | 8     | contracts/L2/DelegateOwner.sol:DelegateOwner |
| remoteOwner    | address     | 252  | 8      | 20    | contracts/L2/DelegateOwner.sol:DelegateOwner |
| __gap          | uint256[48] | 253  | 0      | 1536  | contracts/L2/DelegateOwner.sol:DelegateOwner |

## contracts/L1/provers/GuardianProver.sol:GuardianProver
| Name                    | Type                                            | Slot | Offset | Bytes | Contract                                               |
|-------------------------|-------------------------------------------------|------|--------|-------|--------------------------------------------------------|
| _initialized            | uint8                                           | 0    | 0      | 1     | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| _initializing           | bool                                            | 0    | 1      | 1     | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| __gap                   | uint256[50]                                     | 1    | 0      | 1600  | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| _owner                  | address                                         | 51   | 0      | 20    | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| __gap                   | uint256[49]                                     | 52   | 0      | 1568  | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| _pendingOwner           | address                                         | 101  | 0      | 20    | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| __gap                   | uint256[49]                                     | 102  | 0      | 1568  | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| addressManager          | address                                         | 151  | 0      | 20    | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| __gap                   | uint256[49]                                     | 152  | 0      | 1568  | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| __reentry               | uint8                                           | 201  | 0      | 1     | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| __paused                | uint8                                           | 201  | 1      | 1     | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| lastUnpausedAt          | uint64                                          | 201  | 2      | 8     | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| __gap                   | uint256[49]                                     | 202  | 0      | 1568  | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| guardianIds             | mapping(address => uint256)                     | 251  | 0      | 32    | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| approvals               | mapping(uint256 => mapping(bytes32 => uint256)) | 252  | 0      | 32    | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| guardians               | address[]                                       | 253  | 0      | 32    | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| version                 | uint32                                          | 254  | 0      | 4     | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| minGuardians            | uint32                                          | 254  | 4      | 4     | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| provingAutoPauseEnabled | bool                                            | 254  | 8      | 1     | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| latestProofHash         | mapping(uint256 => mapping(uint256 => bytes32)) | 255  | 0      | 32    | contracts/L1/provers/GuardianProver.sol:GuardianProver |
| __gap                   | uint256[45]                                     | 256  | 0      | 1440  | contracts/L1/provers/GuardianProver.sol:GuardianProver |

## contracts/tko/TaikoToken.sol:TaikoToken
| Name                                                | Type                                                          | Slot | Offset | Bytes | Contract                                |
|-----------------------------------------------------|---------------------------------------------------------------|------|--------|-------|-----------------------------------------|
| _initialized                                        | uint8                                                         | 0    | 0      | 1     | contracts/tko/TaikoToken.sol:TaikoToken |
| _initializing                                       | bool                                                          | 0    | 1      | 1     | contracts/tko/TaikoToken.sol:TaikoToken |
| __gap                                               | uint256[50]                                                   | 1    | 0      | 1600  | contracts/tko/TaikoToken.sol:TaikoToken |
| _owner                                              | address                                                       | 51   | 0      | 20    | contracts/tko/TaikoToken.sol:TaikoToken |
| __gap                                               | uint256[49]                                                   | 52   | 0      | 1568  | contracts/tko/TaikoToken.sol:TaikoToken |
| _pendingOwner                                       | address                                                       | 101  | 0      | 20    | contracts/tko/TaikoToken.sol:TaikoToken |
| __gap                                               | uint256[49]                                                   | 102  | 0      | 1568  | contracts/tko/TaikoToken.sol:TaikoToken |
| addressManager                                      | address                                                       | 151  | 0      | 20    | contracts/tko/TaikoToken.sol:TaikoToken |
| __gap                                               | uint256[49]                                                   | 152  | 0      | 1568  | contracts/tko/TaikoToken.sol:TaikoToken |
| __reentry                                           | uint8                                                         | 201  | 0      | 1     | contracts/tko/TaikoToken.sol:TaikoToken |
| __paused                                            | uint8                                                         | 201  | 1      | 1     | contracts/tko/TaikoToken.sol:TaikoToken |
| lastUnpausedAt                                      | uint64                                                        | 201  | 2      | 8     | contracts/tko/TaikoToken.sol:TaikoToken |
| __gap                                               | uint256[49]                                                   | 202  | 0      | 1568  | contracts/tko/TaikoToken.sol:TaikoToken |
| __slots_previously_used_by_ERC20SnapshotUpgradeable | uint256[50]                                                   | 251  | 0      | 1600  | contracts/tko/TaikoToken.sol:TaikoToken |
| _balances                                           | mapping(address => uint256)                                   | 301  | 0      | 32    | contracts/tko/TaikoToken.sol:TaikoToken |
| _allowances                                         | mapping(address => mapping(address => uint256))               | 302  | 0      | 32    | contracts/tko/TaikoToken.sol:TaikoToken |
| _totalSupply                                        | uint256                                                       | 303  | 0      | 32    | contracts/tko/TaikoToken.sol:TaikoToken |
| _name                                               | string                                                        | 304  | 0      | 32    | contracts/tko/TaikoToken.sol:TaikoToken |
| _symbol                                             | string                                                        | 305  | 0      | 32    | contracts/tko/TaikoToken.sol:TaikoToken |
| __gap                                               | uint256[45]                                                   | 306  | 0      | 1440  | contracts/tko/TaikoToken.sol:TaikoToken |
| _hashedName                                         | bytes32                                                       | 351  | 0      | 32    | contracts/tko/TaikoToken.sol:TaikoToken |
| _hashedVersion                                      | bytes32                                                       | 352  | 0      | 32    | contracts/tko/TaikoToken.sol:TaikoToken |
| _name                                               | string                                                        | 353  | 0      | 32    | contracts/tko/TaikoToken.sol:TaikoToken |
| _version                                            | string                                                        | 354  | 0      | 32    | contracts/tko/TaikoToken.sol:TaikoToken |
| __gap                                               | uint256[48]                                                   | 355  | 0      | 1536  | contracts/tko/TaikoToken.sol:TaikoToken |
| _nonces                                             | mapping(address => struct CountersUpgradeable.Counter)        | 403  | 0      | 32    | contracts/tko/TaikoToken.sol:TaikoToken |
| _PERMIT_TYPEHASH_DEPRECATED_SLOT                    | bytes32                                                       | 404  | 0      | 32    | contracts/tko/TaikoToken.sol:TaikoToken |
| __gap                                               | uint256[49]                                                   | 405  | 0      | 1568  | contracts/tko/TaikoToken.sol:TaikoToken |
| _delegates                                          | mapping(address => address)                                   | 454  | 0      | 32    | contracts/tko/TaikoToken.sol:TaikoToken |
| _checkpoints                                        | mapping(address => struct ERC20VotesUpgradeable.Checkpoint[]) | 455  | 0      | 32    | contracts/tko/TaikoToken.sol:TaikoToken |
| _totalSupplyCheckpoints                             | struct ERC20VotesUpgradeable.Checkpoint[]                     | 456  | 0      | 32    | contracts/tko/TaikoToken.sol:TaikoToken |
| __gap                                               | uint256[47]                                                   | 457  | 0      | 1504  | contracts/tko/TaikoToken.sol:TaikoToken |
| __gap                                               | uint256[50]                                                   | 504  | 0      | 1600  | contracts/tko/TaikoToken.sol:TaikoToken |

## contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken
| Name                                                | Type                                                          | Slot | Offset | Bytes | Contract                                              |
|-----------------------------------------------------|---------------------------------------------------------------|------|--------|-------|-------------------------------------------------------|
| _initialized                                        | uint8                                                         | 0    | 0      | 1     | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| _initializing                                       | bool                                                          | 0    | 1      | 1     | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| __gap                                               | uint256[50]                                                   | 1    | 0      | 1600  | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| _owner                                              | address                                                       | 51   | 0      | 20    | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| __gap                                               | uint256[49]                                                   | 52   | 0      | 1568  | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| _pendingOwner                                       | address                                                       | 101  | 0      | 20    | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| __gap                                               | uint256[49]                                                   | 102  | 0      | 1568  | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| addressManager                                      | address                                                       | 151  | 0      | 20    | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| __gap                                               | uint256[49]                                                   | 152  | 0      | 1568  | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| __reentry                                           | uint8                                                         | 201  | 0      | 1     | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| __paused                                            | uint8                                                         | 201  | 1      | 1     | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| lastUnpausedAt                                      | uint64                                                        | 201  | 2      | 8     | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| __gap                                               | uint256[49]                                                   | 202  | 0      | 1568  | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| __slots_previously_used_by_ERC20SnapshotUpgradeable | uint256[50]                                                   | 251  | 0      | 1600  | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| _balances                                           | mapping(address => uint256)                                   | 301  | 0      | 32    | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| _allowances                                         | mapping(address => mapping(address => uint256))               | 302  | 0      | 32    | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| _totalSupply                                        | uint256                                                       | 303  | 0      | 32    | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| _name                                               | string                                                        | 304  | 0      | 32    | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| _symbol                                             | string                                                        | 305  | 0      | 32    | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| __gap                                               | uint256[45]                                                   | 306  | 0      | 1440  | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| _hashedName                                         | bytes32                                                       | 351  | 0      | 32    | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| _hashedVersion                                      | bytes32                                                       | 352  | 0      | 32    | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| _name                                               | string                                                        | 353  | 0      | 32    | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| _version                                            | string                                                        | 354  | 0      | 32    | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| __gap                                               | uint256[48]                                                   | 355  | 0      | 1536  | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| _nonces                                             | mapping(address => struct CountersUpgradeable.Counter)        | 403  | 0      | 32    | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| _PERMIT_TYPEHASH_DEPRECATED_SLOT                    | bytes32                                                       | 404  | 0      | 32    | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| __gap                                               | uint256[49]                                                   | 405  | 0      | 1568  | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| _delegates                                          | mapping(address => address)                                   | 454  | 0      | 32    | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| _checkpoints                                        | mapping(address => struct ERC20VotesUpgradeable.Checkpoint[]) | 455  | 0      | 32    | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| _totalSupplyCheckpoints                             | struct ERC20VotesUpgradeable.Checkpoint[]                     | 456  | 0      | 32    | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| __gap                                               | uint256[47]                                                   | 457  | 0      | 1504  | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |
| __gap                                               | uint256[50]                                                   | 504  | 0      | 1600  | contracts/tko/BridgedTaikoToken.sol:BridgedTaikoToken |

## contracts/tokenvault/ERC20Vault.sol:ERC20Vault
| Name               | Type                                                 | Slot | Offset | Bytes | Contract                                       |
|--------------------|------------------------------------------------------|------|--------|-------|------------------------------------------------|
| _initialized       | uint8                                                | 0    | 0      | 1     | contracts/tokenvault/ERC20Vault.sol:ERC20Vault |
| _initializing      | bool                                                 | 0    | 1      | 1     | contracts/tokenvault/ERC20Vault.sol:ERC20Vault |
| __gap              | uint256[50]                                          | 1    | 0      | 1600  | contracts/tokenvault/ERC20Vault.sol:ERC20Vault |
| _owner             | address                                              | 51   | 0      | 20    | contracts/tokenvault/ERC20Vault.sol:ERC20Vault |
| __gap              | uint256[49]                                          | 52   | 0      | 1568  | contracts/tokenvault/ERC20Vault.sol:ERC20Vault |
| _pendingOwner      | address                                              | 101  | 0      | 20    | contracts/tokenvault/ERC20Vault.sol:ERC20Vault |
| __gap              | uint256[49]                                          | 102  | 0      | 1568  | contracts/tokenvault/ERC20Vault.sol:ERC20Vault |
| addressManager     | address                                              | 151  | 0      | 20    | contracts/tokenvault/ERC20Vault.sol:ERC20Vault |
| __gap              | uint256[49]                                          | 152  | 0      | 1568  | contracts/tokenvault/ERC20Vault.sol:ERC20Vault |
| __reentry          | uint8                                                | 201  | 0      | 1     | contracts/tokenvault/ERC20Vault.sol:ERC20Vault |
| __paused           | uint8                                                | 201  | 1      | 1     | contracts/tokenvault/ERC20Vault.sol:ERC20Vault |
| lastUnpausedAt     | uint64                                               | 201  | 2      | 8     | contracts/tokenvault/ERC20Vault.sol:ERC20Vault |
| __gap              | uint256[49]                                          | 202  | 0      | 1568  | contracts/tokenvault/ERC20Vault.sol:ERC20Vault |
| __gap              | uint256[50]                                          | 251  | 0      | 1600  | contracts/tokenvault/ERC20Vault.sol:ERC20Vault |
| bridgedToCanonical | mapping(address => struct ERC20Vault.CanonicalERC20) | 301  | 0      | 32    | contracts/tokenvault/ERC20Vault.sol:ERC20Vault |
| canonicalToBridged | mapping(uint256 => mapping(address => address))      | 302  | 0      | 32    | contracts/tokenvault/ERC20Vault.sol:ERC20Vault |
| btokenDenylist     | mapping(address => bool)                             | 303  | 0      | 32    | contracts/tokenvault/ERC20Vault.sol:ERC20Vault |
| lastMigrationStart | mapping(uint256 => mapping(address => uint256))      | 304  | 0      | 32    | contracts/tokenvault/ERC20Vault.sol:ERC20Vault |
| __gap              | uint256[46]                                          | 305  | 0      | 1472  | contracts/tokenvault/ERC20Vault.sol:ERC20Vault |

## contracts/tokenvault/ERC721Vault.sol:ERC721Vault
| Name               | Type                                                 | Slot | Offset | Bytes | Contract                                         |
|--------------------|------------------------------------------------------|------|--------|-------|--------------------------------------------------|
| _initialized       | uint8                                                | 0    | 0      | 1     | contracts/tokenvault/ERC721Vault.sol:ERC721Vault |
| _initializing      | bool                                                 | 0    | 1      | 1     | contracts/tokenvault/ERC721Vault.sol:ERC721Vault |
| __gap              | uint256[50]                                          | 1    | 0      | 1600  | contracts/tokenvault/ERC721Vault.sol:ERC721Vault |
| _owner             | address                                              | 51   | 0      | 20    | contracts/tokenvault/ERC721Vault.sol:ERC721Vault |
| __gap              | uint256[49]                                          | 52   | 0      | 1568  | contracts/tokenvault/ERC721Vault.sol:ERC721Vault |
| _pendingOwner      | address                                              | 101  | 0      | 20    | contracts/tokenvault/ERC721Vault.sol:ERC721Vault |
| __gap              | uint256[49]                                          | 102  | 0      | 1568  | contracts/tokenvault/ERC721Vault.sol:ERC721Vault |
| addressManager     | address                                              | 151  | 0      | 20    | contracts/tokenvault/ERC721Vault.sol:ERC721Vault |
| __gap              | uint256[49]                                          | 152  | 0      | 1568  | contracts/tokenvault/ERC721Vault.sol:ERC721Vault |
| __reentry          | uint8                                                | 201  | 0      | 1     | contracts/tokenvault/ERC721Vault.sol:ERC721Vault |
| __paused           | uint8                                                | 201  | 1      | 1     | contracts/tokenvault/ERC721Vault.sol:ERC721Vault |
| lastUnpausedAt     | uint64                                               | 201  | 2      | 8     | contracts/tokenvault/ERC721Vault.sol:ERC721Vault |
| __gap              | uint256[49]                                          | 202  | 0      | 1568  | contracts/tokenvault/ERC721Vault.sol:ERC721Vault |
| __gap              | uint256[50]                                          | 251  | 0      | 1600  | contracts/tokenvault/ERC721Vault.sol:ERC721Vault |
| bridgedToCanonical | mapping(address => struct BaseNFTVault.CanonicalNFT) | 301  | 0      | 32    | contracts/tokenvault/ERC721Vault.sol:ERC721Vault |
| canonicalToBridged | mapping(uint256 => mapping(address => address))      | 302  | 0      | 32    | contracts/tokenvault/ERC721Vault.sol:ERC721Vault |
| __gap              | uint256[48]                                          | 303  | 0      | 1536  | contracts/tokenvault/ERC721Vault.sol:ERC721Vault |
| __gap              | uint256[50]                                          | 351  | 0      | 1600  | contracts/tokenvault/ERC721Vault.sol:ERC721Vault |

## contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault
| Name               | Type                                                 | Slot | Offset | Bytes | Contract                                           |
|--------------------|------------------------------------------------------|------|--------|-------|----------------------------------------------------|
| _initialized       | uint8                                                | 0    | 0      | 1     | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |
| _initializing      | bool                                                 | 0    | 1      | 1     | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |
| __gap              | uint256[50]                                          | 1    | 0      | 1600  | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |
| _owner             | address                                              | 51   | 0      | 20    | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |
| __gap              | uint256[49]                                          | 52   | 0      | 1568  | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |
| _pendingOwner      | address                                              | 101  | 0      | 20    | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |
| __gap              | uint256[49]                                          | 102  | 0      | 1568  | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |
| addressManager     | address                                              | 151  | 0      | 20    | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |
| __gap              | uint256[49]                                          | 152  | 0      | 1568  | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |
| __reentry          | uint8                                                | 201  | 0      | 1     | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |
| __paused           | uint8                                                | 201  | 1      | 1     | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |
| lastUnpausedAt     | uint64                                               | 201  | 2      | 8     | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |
| __gap              | uint256[49]                                          | 202  | 0      | 1568  | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |
| __gap              | uint256[50]                                          | 251  | 0      | 1600  | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |
| bridgedToCanonical | mapping(address => struct BaseNFTVault.CanonicalNFT) | 301  | 0      | 32    | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |
| canonicalToBridged | mapping(uint256 => mapping(address => address))      | 302  | 0      | 32    | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |
| __gap              | uint256[48]                                          | 303  | 0      | 1536  | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |
| __gap              | uint256[50]                                          | 351  | 0      | 1600  | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |
| __gap              | uint256[50]                                          | 401  | 0      | 1600  | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |
| __gap              | uint256[50]                                          | 451  | 0      | 1600  | contracts/tokenvault/ERC1155Vault.sol:ERC1155Vault |

## contracts/tokenvault/BridgedERC20.sol:BridgedERC20
| Name             | Type                                            | Slot | Offset | Bytes | Contract                                           |
|------------------|-------------------------------------------------|------|--------|-------|----------------------------------------------------|
| _initialized     | uint8                                           | 0    | 0      | 1     | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| _initializing    | bool                                            | 0    | 1      | 1     | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| __gap            | uint256[50]                                     | 1    | 0      | 1600  | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| _owner           | address                                         | 51   | 0      | 20    | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| __gap            | uint256[49]                                     | 52   | 0      | 1568  | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| _pendingOwner    | address                                         | 101  | 0      | 20    | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| __gap            | uint256[49]                                     | 102  | 0      | 1568  | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| addressManager   | address                                         | 151  | 0      | 20    | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| __gap            | uint256[49]                                     | 152  | 0      | 1568  | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| __reentry        | uint8                                           | 201  | 0      | 1     | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| __paused         | uint8                                           | 201  | 1      | 1     | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| lastUnpausedAt   | uint64                                          | 201  | 2      | 8     | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| __gap            | uint256[49]                                     | 202  | 0      | 1568  | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| _balances        | mapping(address => uint256)                     | 251  | 0      | 32    | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| _allowances      | mapping(address => mapping(address => uint256)) | 252  | 0      | 32    | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| _totalSupply     | uint256                                         | 253  | 0      | 32    | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| _name            | string                                          | 254  | 0      | 32    | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| _symbol          | string                                          | 255  | 0      | 32    | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| __gap            | uint256[45]                                     | 256  | 0      | 1440  | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| srcToken         | address                                         | 301  | 0      | 20    | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| __srcDecimals    | uint8                                           | 301  | 20     | 1     | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| srcChainId       | uint256                                         | 302  | 0      | 32    | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| migratingAddress | address                                         | 303  | 0      | 20    | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| migratingInbound | bool                                            | 303  | 20     | 1     | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |
| __gap            | uint256[47]                                     | 304  | 0      | 1504  | contracts/tokenvault/BridgedERC20.sol:BridgedERC20 |

## contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2
| Name             | Type                                                   | Slot | Offset | Bytes | Contract                                               |
|------------------|--------------------------------------------------------|------|--------|-------|--------------------------------------------------------|
| _initialized     | uint8                                                  | 0    | 0      | 1     | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| _initializing    | bool                                                   | 0    | 1      | 1     | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| __gap            | uint256[50]                                            | 1    | 0      | 1600  | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| _owner           | address                                                | 51   | 0      | 20    | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| __gap            | uint256[49]                                            | 52   | 0      | 1568  | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| _pendingOwner    | address                                                | 101  | 0      | 20    | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| __gap            | uint256[49]                                            | 102  | 0      | 1568  | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| addressManager   | address                                                | 151  | 0      | 20    | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| __gap            | uint256[49]                                            | 152  | 0      | 1568  | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| __reentry        | uint8                                                  | 201  | 0      | 1     | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| __paused         | uint8                                                  | 201  | 1      | 1     | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| lastUnpausedAt   | uint64                                                 | 201  | 2      | 8     | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| __gap            | uint256[49]                                            | 202  | 0      | 1568  | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| _balances        | mapping(address => uint256)                            | 251  | 0      | 32    | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| _allowances      | mapping(address => mapping(address => uint256))        | 252  | 0      | 32    | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| _totalSupply     | uint256                                                | 253  | 0      | 32    | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| _name            | string                                                 | 254  | 0      | 32    | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| _symbol          | string                                                 | 255  | 0      | 32    | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| __gap            | uint256[45]                                            | 256  | 0      | 1440  | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| srcToken         | address                                                | 301  | 0      | 20    | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| __srcDecimals    | uint8                                                  | 301  | 20     | 1     | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| srcChainId       | uint256                                                | 302  | 0      | 32    | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| migratingAddress | address                                                | 303  | 0      | 20    | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| migratingInbound | bool                                                   | 303  | 20     | 1     | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| __gap            | uint256[47]                                            | 304  | 0      | 1504  | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| _hashedName      | bytes32                                                | 351  | 0      | 32    | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| _hashedVersion   | bytes32                                                | 352  | 0      | 32    | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| _name            | string                                                 | 353  | 0      | 32    | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| _version         | string                                                 | 354  | 0      | 32    | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| __gap            | uint256[48]                                            | 355  | 0      | 1536  | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| _nonces          | mapping(address => struct CountersUpgradeable.Counter) | 403  | 0      | 32    | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |
| __gap            | uint256[49]                                            | 404  | 0      | 1568  | contracts/tokenvault/BridgedERC20V2.sol:BridgedERC20V2 |

## contracts/tokenvault/BridgedERC721.sol:BridgedERC721
| Name               | Type                                         | Slot | Offset | Bytes | Contract                                             |
|--------------------|----------------------------------------------|------|--------|-------|------------------------------------------------------|
| _initialized       | uint8                                        | 0    | 0      | 1     | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| _initializing      | bool                                         | 0    | 1      | 1     | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| __gap              | uint256[50]                                  | 1    | 0      | 1600  | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| _owner             | address                                      | 51   | 0      | 20    | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| __gap              | uint256[49]                                  | 52   | 0      | 1568  | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| _pendingOwner      | address                                      | 101  | 0      | 20    | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| __gap              | uint256[49]                                  | 102  | 0      | 1568  | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| addressManager     | address                                      | 151  | 0      | 20    | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| __gap              | uint256[49]                                  | 152  | 0      | 1568  | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| __reentry          | uint8                                        | 201  | 0      | 1     | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| __paused           | uint8                                        | 201  | 1      | 1     | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| lastUnpausedAt     | uint64                                       | 201  | 2      | 8     | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| __gap              | uint256[49]                                  | 202  | 0      | 1568  | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| __gap              | uint256[50]                                  | 251  | 0      | 1600  | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| _name              | string                                       | 301  | 0      | 32    | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| _symbol            | string                                       | 302  | 0      | 32    | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| _owners            | mapping(uint256 => address)                  | 303  | 0      | 32    | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| _balances          | mapping(address => uint256)                  | 304  | 0      | 32    | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| _tokenApprovals    | mapping(uint256 => address)                  | 305  | 0      | 32    | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| _operatorApprovals | mapping(address => mapping(address => bool)) | 306  | 0      | 32    | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| __gap              | uint256[44]                                  | 307  | 0      | 1408  | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| srcToken           | address                                      | 351  | 0      | 20    | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| srcChainId         | uint256                                      | 352  | 0      | 32    | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |
| __gap              | uint256[48]                                  | 353  | 0      | 1536  | contracts/tokenvault/BridgedERC721.sol:BridgedERC721 |

## contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155
| Name               | Type                                            | Slot | Offset | Bytes | Contract                                               |
|--------------------|-------------------------------------------------|------|--------|-------|--------------------------------------------------------|
| _initialized       | uint8                                           | 0    | 0      | 1     | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| _initializing      | bool                                            | 0    | 1      | 1     | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| __gap              | uint256[50]                                     | 1    | 0      | 1600  | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| _owner             | address                                         | 51   | 0      | 20    | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| __gap              | uint256[49]                                     | 52   | 0      | 1568  | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| _pendingOwner      | address                                         | 101  | 0      | 20    | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| __gap              | uint256[49]                                     | 102  | 0      | 1568  | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| addressManager     | address                                         | 151  | 0      | 20    | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| __gap              | uint256[49]                                     | 152  | 0      | 1568  | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| __reentry          | uint8                                           | 201  | 0      | 1     | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| __paused           | uint8                                           | 201  | 1      | 1     | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| lastUnpausedAt     | uint64                                          | 201  | 2      | 8     | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| __gap              | uint256[49]                                     | 202  | 0      | 1568  | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| __gap              | uint256[50]                                     | 251  | 0      | 1600  | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| _balances          | mapping(uint256 => mapping(address => uint256)) | 301  | 0      | 32    | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| _operatorApprovals | mapping(address => mapping(address => bool))    | 302  | 0      | 32    | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| _uri               | string                                          | 303  | 0      | 32    | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| __gap              | uint256[47]                                     | 304  | 0      | 1504  | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| srcToken           | address                                         | 351  | 0      | 20    | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| srcChainId         | uint256                                         | 352  | 0      | 32    | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| symbol             | string                                          | 353  | 0      | 32    | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| name               | string                                          | 354  | 0      | 32    | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |
| __gap              | uint256[46]                                     | 355  | 0      | 1472  | contracts/tokenvault/BridgedERC1155.sol:BridgedERC1155 |

## contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation
| Name                    | Type                                            | Slot | Offset | Bytes | Contract                                                                               |
|-------------------------|-------------------------------------------------|------|--------|-------|----------------------------------------------------------------------------------------|
| _initialized            | uint8                                           | 0    | 0      | 1     | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| _initializing           | bool                                            | 0    | 1      | 1     | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| __gap                   | uint256[50]                                     | 1    | 0      | 1600  | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| _owner                  | address                                         | 51   | 0      | 20    | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| __gap                   | uint256[49]                                     | 52   | 0      | 1568  | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| _pendingOwner           | address                                         | 101  | 0      | 20    | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| __gap                   | uint256[49]                                     | 102  | 0      | 1568  | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| addressManager          | address                                         | 151  | 0      | 20    | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| __gap                   | uint256[49]                                     | 152  | 0      | 1568  | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| __reentry               | uint8                                           | 201  | 0      | 1     | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| __paused                | uint8                                           | 201  | 1      | 1     | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| lastUnpausedAt          | uint64                                          | 201  | 2      | 8     | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| __gap                   | uint256[49]                                     | 202  | 0      | 1568  | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| sigVerifyLib            | contract ISigVerifyLib                          | 251  | 0      | 20    | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| pemCertLib              | contract IPEMCertChainLib                       | 252  | 0      | 20    | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| checkLocalEnclaveReport | bool                                            | 252  | 20     | 1     | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| trustedUserMrEnclave    | mapping(bytes32 => bool)                        | 253  | 0      | 32    | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| trustedUserMrSigner     | mapping(bytes32 => bool)                        | 254  | 0      | 32    | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| serialNumIsRevoked      | mapping(uint256 => mapping(bytes => bool))      | 255  | 0      | 32    | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| tcbInfo                 | mapping(string => struct TCBInfoStruct.TCBInfo) | 256  | 0      | 32    | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| qeIdentity              | struct EnclaveIdStruct.EnclaveId                | 257  | 0      | 128   | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |
| __gap                   | uint256[39]                                     | 261  | 0      | 1248  | contracts/automata-attestation/AutomataDcapV3Attestation.sol:AutomataDcapV3Attestation |

## contracts/verifiers/SgxVerifier.sol:SgxVerifier
| Name              | Type                                            | Slot | Offset | Bytes | Contract                                        |
|-------------------|-------------------------------------------------|------|--------|-------|-------------------------------------------------|
| _initialized      | uint8                                           | 0    | 0      | 1     | contracts/verifiers/SgxVerifier.sol:SgxVerifier |
| _initializing     | bool                                            | 0    | 1      | 1     | contracts/verifiers/SgxVerifier.sol:SgxVerifier |
| __gap             | uint256[50]                                     | 1    | 0      | 1600  | contracts/verifiers/SgxVerifier.sol:SgxVerifier |
| _owner            | address                                         | 51   | 0      | 20    | contracts/verifiers/SgxVerifier.sol:SgxVerifier |
| __gap             | uint256[49]                                     | 52   | 0      | 1568  | contracts/verifiers/SgxVerifier.sol:SgxVerifier |
| _pendingOwner     | address                                         | 101  | 0      | 20    | contracts/verifiers/SgxVerifier.sol:SgxVerifier |
| __gap             | uint256[49]                                     | 102  | 0      | 1568  | contracts/verifiers/SgxVerifier.sol:SgxVerifier |
| addressManager    | address                                         | 151  | 0      | 20    | contracts/verifiers/SgxVerifier.sol:SgxVerifier |
| __gap             | uint256[49]                                     | 152  | 0      | 1568  | contracts/verifiers/SgxVerifier.sol:SgxVerifier |
| __reentry         | uint8                                           | 201  | 0      | 1     | contracts/verifiers/SgxVerifier.sol:SgxVerifier |
| __paused          | uint8                                           | 201  | 1      | 1     | contracts/verifiers/SgxVerifier.sol:SgxVerifier |
| lastUnpausedAt    | uint64                                          | 201  | 2      | 8     | contracts/verifiers/SgxVerifier.sol:SgxVerifier |
| __gap             | uint256[49]                                     | 202  | 0      | 1568  | contracts/verifiers/SgxVerifier.sol:SgxVerifier |
| nextInstanceId    | uint256                                         | 251  | 0      | 32    | contracts/verifiers/SgxVerifier.sol:SgxVerifier |
| instances         | mapping(uint256 => struct SgxVerifier.Instance) | 252  | 0      | 32    | contracts/verifiers/SgxVerifier.sol:SgxVerifier |
| addressRegistered | mapping(address => bool)                        | 253  | 0      | 32    | contracts/verifiers/SgxVerifier.sol:SgxVerifier |
| __gap             | uint256[47]                                     | 254  | 0      | 1504  | contracts/verifiers/SgxVerifier.sol:SgxVerifier |

## contracts/verifiers/Risc0Verifier.sol:Risc0Verifier
| Name           | Type                     | Slot | Offset | Bytes | Contract                                            |
|----------------|--------------------------|------|--------|-------|-----------------------------------------------------|
| _initialized   | uint8                    | 0    | 0      | 1     | contracts/verifiers/Risc0Verifier.sol:Risc0Verifier |
| _initializing  | bool                     | 0    | 1      | 1     | contracts/verifiers/Risc0Verifier.sol:Risc0Verifier |
| __gap          | uint256[50]              | 1    | 0      | 1600  | contracts/verifiers/Risc0Verifier.sol:Risc0Verifier |
| _owner         | address                  | 51   | 0      | 20    | contracts/verifiers/Risc0Verifier.sol:Risc0Verifier |
| __gap          | uint256[49]              | 52   | 0      | 1568  | contracts/verifiers/Risc0Verifier.sol:Risc0Verifier |
| _pendingOwner  | address                  | 101  | 0      | 20    | contracts/verifiers/Risc0Verifier.sol:Risc0Verifier |
| __gap          | uint256[49]              | 102  | 0      | 1568  | contracts/verifiers/Risc0Verifier.sol:Risc0Verifier |
| addressManager | address                  | 151  | 0      | 20    | contracts/verifiers/Risc0Verifier.sol:Risc0Verifier |
| __gap          | uint256[49]              | 152  | 0      | 1568  | contracts/verifiers/Risc0Verifier.sol:Risc0Verifier |
| __reentry      | uint8                    | 201  | 0      | 1     | contracts/verifiers/Risc0Verifier.sol:Risc0Verifier |
| __paused       | uint8                    | 201  | 1      | 1     | contracts/verifiers/Risc0Verifier.sol:Risc0Verifier |
| lastUnpausedAt | uint64                   | 201  | 2      | 8     | contracts/verifiers/Risc0Verifier.sol:Risc0Verifier |
| __gap          | uint256[49]              | 202  | 0      | 1568  | contracts/verifiers/Risc0Verifier.sol:Risc0Verifier |
| isImageTrusted | mapping(bytes32 => bool) | 251  | 0      | 32    | contracts/verifiers/Risc0Verifier.sol:Risc0Verifier |
| __gap          | uint256[49]              | 252  | 0      | 1568  | contracts/verifiers/Risc0Verifier.sol:Risc0Verifier |

## contracts/verifiers/SP1Verifier.sol:SP1Verifier
| Name             | Type                     | Slot | Offset | Bytes | Contract                                        |
|------------------|--------------------------|------|--------|-------|-------------------------------------------------|
| _initialized     | uint8                    | 0    | 0      | 1     | contracts/verifiers/SP1Verifier.sol:SP1Verifier |
| _initializing    | bool                     | 0    | 1      | 1     | contracts/verifiers/SP1Verifier.sol:SP1Verifier |
| __gap            | uint256[50]              | 1    | 0      | 1600  | contracts/verifiers/SP1Verifier.sol:SP1Verifier |
| _owner           | address                  | 51   | 0      | 20    | contracts/verifiers/SP1Verifier.sol:SP1Verifier |
| __gap            | uint256[49]              | 52   | 0      | 1568  | contracts/verifiers/SP1Verifier.sol:SP1Verifier |
| _pendingOwner    | address                  | 101  | 0      | 20    | contracts/verifiers/SP1Verifier.sol:SP1Verifier |
| __gap            | uint256[49]              | 102  | 0      | 1568  | contracts/verifiers/SP1Verifier.sol:SP1Verifier |
| addressManager   | address                  | 151  | 0      | 20    | contracts/verifiers/SP1Verifier.sol:SP1Verifier |
| __gap            | uint256[49]              | 152  | 0      | 1568  | contracts/verifiers/SP1Verifier.sol:SP1Verifier |
| __reentry        | uint8                    | 201  | 0      | 1     | contracts/verifiers/SP1Verifier.sol:SP1Verifier |
| __paused         | uint8                    | 201  | 1      | 1     | contracts/verifiers/SP1Verifier.sol:SP1Verifier |
| lastUnpausedAt   | uint64                   | 201  | 2      | 8     | contracts/verifiers/SP1Verifier.sol:SP1Verifier |
| __gap            | uint256[49]              | 202  | 0      | 1568  | contracts/verifiers/SP1Verifier.sol:SP1Verifier |
| isProgramTrusted | mapping(bytes32 => bool) | 251  | 0      | 32    | contracts/verifiers/SP1Verifier.sol:SP1Verifier |
| __gap            | uint256[49]              | 252  | 0      | 1568  | contracts/verifiers/SP1Verifier.sol:SP1Verifier |

## contracts/bridge/QuotaManager.sol:QuotaManager
| Name           | Type                                          | Slot | Offset | Bytes | Contract                                       |
|----------------|-----------------------------------------------|------|--------|-------|------------------------------------------------|
| _initialized   | uint8                                         | 0    | 0      | 1     | contracts/bridge/QuotaManager.sol:QuotaManager |
| _initializing  | bool                                          | 0    | 1      | 1     | contracts/bridge/QuotaManager.sol:QuotaManager |
| __gap          | uint256[50]                                   | 1    | 0      | 1600  | contracts/bridge/QuotaManager.sol:QuotaManager |
| _owner         | address                                       | 51   | 0      | 20    | contracts/bridge/QuotaManager.sol:QuotaManager |
| __gap          | uint256[49]                                   | 52   | 0      | 1568  | contracts/bridge/QuotaManager.sol:QuotaManager |
| _pendingOwner  | address                                       | 101  | 0      | 20    | contracts/bridge/QuotaManager.sol:QuotaManager |
| __gap          | uint256[49]                                   | 102  | 0      | 1568  | contracts/bridge/QuotaManager.sol:QuotaManager |
| addressManager | address                                       | 151  | 0      | 20    | contracts/bridge/QuotaManager.sol:QuotaManager |
| __gap          | uint256[49]                                   | 152  | 0      | 1568  | contracts/bridge/QuotaManager.sol:QuotaManager |
| __reentry      | uint8                                         | 201  | 0      | 1     | contracts/bridge/QuotaManager.sol:QuotaManager |
| __paused       | uint8                                         | 201  | 1      | 1     | contracts/bridge/QuotaManager.sol:QuotaManager |
| lastUnpausedAt | uint64                                        | 201  | 2      | 8     | contracts/bridge/QuotaManager.sol:QuotaManager |
| __gap          | uint256[49]                                   | 202  | 0      | 1568  | contracts/bridge/QuotaManager.sol:QuotaManager |
| tokenQuota     | mapping(address => struct QuotaManager.Quota) | 251  | 0      | 32    | contracts/bridge/QuotaManager.sol:QuotaManager |
| quotaPeriod    | uint24                                        | 252  | 0      | 3     | contracts/bridge/QuotaManager.sol:QuotaManager |
| __gap          | uint256[48]                                   | 253  | 0      | 1536  | contracts/bridge/QuotaManager.sol:QuotaManager |

## contracts/team/proving/ProverSet.sol:ProverSet
| Name           | Type                     | Slot | Offset | Bytes | Contract                                       |
|----------------|--------------------------|------|--------|-------|------------------------------------------------|
| _initialized   | uint8                    | 0    | 0      | 1     | contracts/team/proving/ProverSet.sol:ProverSet |
| _initializing  | bool                     | 0    | 1      | 1     | contracts/team/proving/ProverSet.sol:ProverSet |
| __gap          | uint256[50]              | 1    | 0      | 1600  | contracts/team/proving/ProverSet.sol:ProverSet |
| _owner         | address                  | 51   | 0      | 20    | contracts/team/proving/ProverSet.sol:ProverSet |
| __gap          | uint256[49]              | 52   | 0      | 1568  | contracts/team/proving/ProverSet.sol:ProverSet |
| _pendingOwner  | address                  | 101  | 0      | 20    | contracts/team/proving/ProverSet.sol:ProverSet |
| __gap          | uint256[49]              | 102  | 0      | 1568  | contracts/team/proving/ProverSet.sol:ProverSet |
| addressManager | address                  | 151  | 0      | 20    | contracts/team/proving/ProverSet.sol:ProverSet |
| __gap          | uint256[49]              | 152  | 0      | 1568  | contracts/team/proving/ProverSet.sol:ProverSet |
| __reentry      | uint8                    | 201  | 0      | 1     | contracts/team/proving/ProverSet.sol:ProverSet |
| __paused       | uint8                    | 201  | 1      | 1     | contracts/team/proving/ProverSet.sol:ProverSet |
| lastUnpausedAt | uint64                   | 201  | 2      | 8     | contracts/team/proving/ProverSet.sol:ProverSet |
| __gap          | uint256[49]              | 202  | 0      | 1568  | contracts/team/proving/ProverSet.sol:ProverSet |
| isProver       | mapping(address => bool) | 251  | 0      | 32    | contracts/team/proving/ProverSet.sol:ProverSet |
| admin          | address                  | 252  | 0      | 20    | contracts/team/proving/ProverSet.sol:ProverSet |
| __gap          | uint256[48]              | 253  | 0      | 1536  | contracts/team/proving/ProverSet.sol:ProverSet |

## contracts/team/tokenunlock/TokenUnlock.sol:TokenUnlock
| Name           | Type                     | Slot | Offset | Bytes | Contract                                               |
|----------------|--------------------------|------|--------|-------|--------------------------------------------------------|
| _initialized   | uint8                    | 0    | 0      | 1     | contracts/team/tokenunlock/TokenUnlock.sol:TokenUnlock |
| _initializing  | bool                     | 0    | 1      | 1     | contracts/team/tokenunlock/TokenUnlock.sol:TokenUnlock |
| __gap          | uint256[50]              | 1    | 0      | 1600  | contracts/team/tokenunlock/TokenUnlock.sol:TokenUnlock |
| _owner         | address                  | 51   | 0      | 20    | contracts/team/tokenunlock/TokenUnlock.sol:TokenUnlock |
| __gap          | uint256[49]              | 52   | 0      | 1568  | contracts/team/tokenunlock/TokenUnlock.sol:TokenUnlock |
| _pendingOwner  | address                  | 101  | 0      | 20    | contracts/team/tokenunlock/TokenUnlock.sol:TokenUnlock |
| __gap          | uint256[49]              | 102  | 0      | 1568  | contracts/team/tokenunlock/TokenUnlock.sol:TokenUnlock |
| addressManager | address                  | 151  | 0      | 20    | contracts/team/tokenunlock/TokenUnlock.sol:TokenUnlock |
| __gap          | uint256[49]              | 152  | 0      | 1568  | contracts/team/tokenunlock/TokenUnlock.sol:TokenUnlock |
| __reentry      | uint8                    | 201  | 0      | 1     | contracts/team/tokenunlock/TokenUnlock.sol:TokenUnlock |
| __paused       | uint8                    | 201  | 1      | 1     | contracts/team/tokenunlock/TokenUnlock.sol:TokenUnlock |
| lastUnpausedAt | uint64                   | 201  | 2      | 8     | contracts/team/tokenunlock/TokenUnlock.sol:TokenUnlock |
| __gap          | uint256[49]              | 202  | 0      | 1568  | contracts/team/tokenunlock/TokenUnlock.sol:TokenUnlock |
| amountVested   | uint256                  | 251  | 0      | 32    | contracts/team/tokenunlock/TokenUnlock.sol:TokenUnlock |
| recipient      | address                  | 252  | 0      | 20    | contracts/team/tokenunlock/TokenUnlock.sol:TokenUnlock |
| tgeTimestamp   | uint64                   | 252  | 20     | 8     | contracts/team/tokenunlock/TokenUnlock.sol:TokenUnlock |
| isProverSet    | mapping(address => bool) | 253  | 0      | 32    | contracts/team/tokenunlock/TokenUnlock.sol:TokenUnlock |
| __gap          | uint256[47]              | 254  | 0      | 1504  | contracts/team/tokenunlock/TokenUnlock.sol:TokenUnlock |

## contracts/verifiers/compose/ComposeVerifier.sol:ComposeVerifier
| Name           | Type        | Slot | Offset | Bytes | Contract                                                        |
|----------------|-------------|------|--------|-------|-----------------------------------------------------------------|
| _initialized   | uint8       | 0    | 0      | 1     | contracts/verifiers/compose/ComposeVerifier.sol:ComposeVerifier |
| _initializing  | bool        | 0    | 1      | 1     | contracts/verifiers/compose/ComposeVerifier.sol:ComposeVerifier |
| __gap          | uint256[50] | 1    | 0      | 1600  | contracts/verifiers/compose/ComposeVerifier.sol:ComposeVerifier |
| _owner         | address     | 51   | 0      | 20    | contracts/verifiers/compose/ComposeVerifier.sol:ComposeVerifier |
| __gap          | uint256[49] | 52   | 0      | 1568  | contracts/verifiers/compose/ComposeVerifier.sol:ComposeVerifier |
| _pendingOwner  | address     | 101  | 0      | 20    | contracts/verifiers/compose/ComposeVerifier.sol:ComposeVerifier |
| __gap          | uint256[49] | 102  | 0      | 1568  | contracts/verifiers/compose/ComposeVerifier.sol:ComposeVerifier |
| addressManager | address     | 151  | 0      | 20    | contracts/verifiers/compose/ComposeVerifier.sol:ComposeVerifier |
| __gap          | uint256[49] | 152  | 0      | 1568  | contracts/verifiers/compose/ComposeVerifier.sol:ComposeVerifier |
| __reentry      | uint8       | 201  | 0      | 1     | contracts/verifiers/compose/ComposeVerifier.sol:ComposeVerifier |
| __paused       | uint8       | 201  | 1      | 1     | contracts/verifiers/compose/ComposeVerifier.sol:ComposeVerifier |
| lastUnpausedAt | uint64      | 201  | 2      | 8     | contracts/verifiers/compose/ComposeVerifier.sol:ComposeVerifier |
| __gap          | uint256[49] | 202  | 0      | 1568  | contracts/verifiers/compose/ComposeVerifier.sol:ComposeVerifier |
| __gap          | uint256[50] | 251  | 0      | 1600  | contracts/verifiers/compose/ComposeVerifier.sol:ComposeVerifier |

## contracts/verifiers/compose/TeeAnyVerifier.sol:TeeAnyVerifier
| Name           | Type        | Slot | Offset | Bytes | Contract                                                      |
|----------------|-------------|------|--------|-------|---------------------------------------------------------------|
| _initialized   | uint8       | 0    | 0      | 1     | contracts/verifiers/compose/TeeAnyVerifier.sol:TeeAnyVerifier |
| _initializing  | bool        | 0    | 1      | 1     | contracts/verifiers/compose/TeeAnyVerifier.sol:TeeAnyVerifier |
| __gap          | uint256[50] | 1    | 0      | 1600  | contracts/verifiers/compose/TeeAnyVerifier.sol:TeeAnyVerifier |
| _owner         | address     | 51   | 0      | 20    | contracts/verifiers/compose/TeeAnyVerifier.sol:TeeAnyVerifier |
| __gap          | uint256[49] | 52   | 0      | 1568  | contracts/verifiers/compose/TeeAnyVerifier.sol:TeeAnyVerifier |
| _pendingOwner  | address     | 101  | 0      | 20    | contracts/verifiers/compose/TeeAnyVerifier.sol:TeeAnyVerifier |
| __gap          | uint256[49] | 102  | 0      | 1568  | contracts/verifiers/compose/TeeAnyVerifier.sol:TeeAnyVerifier |
| addressManager | address     | 151  | 0      | 20    | contracts/verifiers/compose/TeeAnyVerifier.sol:TeeAnyVerifier |
| __gap          | uint256[49] | 152  | 0      | 1568  | contracts/verifiers/compose/TeeAnyVerifier.sol:TeeAnyVerifier |
| __reentry      | uint8       | 201  | 0      | 1     | contracts/verifiers/compose/TeeAnyVerifier.sol:TeeAnyVerifier |
| __paused       | uint8       | 201  | 1      | 1     | contracts/verifiers/compose/TeeAnyVerifier.sol:TeeAnyVerifier |
| lastUnpausedAt | uint64      | 201  | 2      | 8     | contracts/verifiers/compose/TeeAnyVerifier.sol:TeeAnyVerifier |
| __gap          | uint256[49] | 202  | 0      | 1568  | contracts/verifiers/compose/TeeAnyVerifier.sol:TeeAnyVerifier |
| __gap          | uint256[50] | 251  | 0      | 1600  | contracts/verifiers/compose/TeeAnyVerifier.sol:TeeAnyVerifier |
| __gap          | uint256[50] | 301  | 0      | 1600  | contracts/verifiers/compose/TeeAnyVerifier.sol:TeeAnyVerifier |

## contracts/verifiers/compose/ZkAnyVerifier.sol:ZkAnyVerifier
| Name           | Type        | Slot | Offset | Bytes | Contract                                                    |
|----------------|-------------|------|--------|-------|-------------------------------------------------------------|
| _initialized   | uint8       | 0    | 0      | 1     | contracts/verifiers/compose/ZkAnyVerifier.sol:ZkAnyVerifier |
| _initializing  | bool        | 0    | 1      | 1     | contracts/verifiers/compose/ZkAnyVerifier.sol:ZkAnyVerifier |
| __gap          | uint256[50] | 1    | 0      | 1600  | contracts/verifiers/compose/ZkAnyVerifier.sol:ZkAnyVerifier |
| _owner         | address     | 51   | 0      | 20    | contracts/verifiers/compose/ZkAnyVerifier.sol:ZkAnyVerifier |
| __gap          | uint256[49] | 52   | 0      | 1568  | contracts/verifiers/compose/ZkAnyVerifier.sol:ZkAnyVerifier |
| _pendingOwner  | address     | 101  | 0      | 20    | contracts/verifiers/compose/ZkAnyVerifier.sol:ZkAnyVerifier |
| __gap          | uint256[49] | 102  | 0      | 1568  | contracts/verifiers/compose/ZkAnyVerifier.sol:ZkAnyVerifier |
| addressManager | address     | 151  | 0      | 20    | contracts/verifiers/compose/ZkAnyVerifier.sol:ZkAnyVerifier |
| __gap          | uint256[49] | 152  | 0      | 1568  | contracts/verifiers/compose/ZkAnyVerifier.sol:ZkAnyVerifier |
| __reentry      | uint8       | 201  | 0      | 1     | contracts/verifiers/compose/ZkAnyVerifier.sol:ZkAnyVerifier |
| __paused       | uint8       | 201  | 1      | 1     | contracts/verifiers/compose/ZkAnyVerifier.sol:ZkAnyVerifier |
| lastUnpausedAt | uint64      | 201  | 2      | 8     | contracts/verifiers/compose/ZkAnyVerifier.sol:ZkAnyVerifier |
| __gap          | uint256[49] | 202  | 0      | 1568  | contracts/verifiers/compose/ZkAnyVerifier.sol:ZkAnyVerifier |
| __gap          | uint256[50] | 251  | 0      | 1600  | contracts/verifiers/compose/ZkAnyVerifier.sol:ZkAnyVerifier |
| __gap          | uint256[50] | 301  | 0      | 1600  | contracts/verifiers/compose/ZkAnyVerifier.sol:ZkAnyVerifier |

## contracts/verifiers/compose/ZkAndTeeVerifier.sol:ZkAndTeeVerifier
| Name           | Type        | Slot | Offset | Bytes | Contract                                                          |
|----------------|-------------|------|--------|-------|-------------------------------------------------------------------|
| _initialized   | uint8       | 0    | 0      | 1     | contracts/verifiers/compose/ZkAndTeeVerifier.sol:ZkAndTeeVerifier |
| _initializing  | bool        | 0    | 1      | 1     | contracts/verifiers/compose/ZkAndTeeVerifier.sol:ZkAndTeeVerifier |
| __gap          | uint256[50] | 1    | 0      | 1600  | contracts/verifiers/compose/ZkAndTeeVerifier.sol:ZkAndTeeVerifier |
| _owner         | address     | 51   | 0      | 20    | contracts/verifiers/compose/ZkAndTeeVerifier.sol:ZkAndTeeVerifier |
| __gap          | uint256[49] | 52   | 0      | 1568  | contracts/verifiers/compose/ZkAndTeeVerifier.sol:ZkAndTeeVerifier |
| _pendingOwner  | address     | 101  | 0      | 20    | contracts/verifiers/compose/ZkAndTeeVerifier.sol:ZkAndTeeVerifier |
| __gap          | uint256[49] | 102  | 0      | 1568  | contracts/verifiers/compose/ZkAndTeeVerifier.sol:ZkAndTeeVerifier |
| addressManager | address     | 151  | 0      | 20    | contracts/verifiers/compose/ZkAndTeeVerifier.sol:ZkAndTeeVerifier |
| __gap          | uint256[49] | 152  | 0      | 1568  | contracts/verifiers/compose/ZkAndTeeVerifier.sol:ZkAndTeeVerifier |
| __reentry      | uint8       | 201  | 0      | 1     | contracts/verifiers/compose/ZkAndTeeVerifier.sol:ZkAndTeeVerifier |
| __paused       | uint8       | 201  | 1      | 1     | contracts/verifiers/compose/ZkAndTeeVerifier.sol:ZkAndTeeVerifier |
| lastUnpausedAt | uint64      | 201  | 2      | 8     | contracts/verifiers/compose/ZkAndTeeVerifier.sol:ZkAndTeeVerifier |
| __gap          | uint256[49] | 202  | 0      | 1568  | contracts/verifiers/compose/ZkAndTeeVerifier.sol:ZkAndTeeVerifier |
| __gap          | uint256[50] | 251  | 0      | 1600  | contracts/verifiers/compose/ZkAndTeeVerifier.sol:ZkAndTeeVerifier |
| __gap          | uint256[50] | 301  | 0      | 1600  | contracts/verifiers/compose/ZkAndTeeVerifier.sol:ZkAndTeeVerifier |

## contracts/hekla/HeklaTaikoL1.sol:HeklaTaikoL1
| Name           | Type                   | Slot | Offset | Bytes | Contract                                      |
|----------------|------------------------|------|--------|-------|-----------------------------------------------|
| _initialized   | uint8                  | 0    | 0      | 1     | contracts/hekla/HeklaTaikoL1.sol:HeklaTaikoL1 |
| _initializing  | bool                   | 0    | 1      | 1     | contracts/hekla/HeklaTaikoL1.sol:HeklaTaikoL1 |
| __gap          | uint256[50]            | 1    | 0      | 1600  | contracts/hekla/HeklaTaikoL1.sol:HeklaTaikoL1 |
| _owner         | address                | 51   | 0      | 20    | contracts/hekla/HeklaTaikoL1.sol:HeklaTaikoL1 |
| __gap          | uint256[49]            | 52   | 0      | 1568  | contracts/hekla/HeklaTaikoL1.sol:HeklaTaikoL1 |
| _pendingOwner  | address                | 101  | 0      | 20    | contracts/hekla/HeklaTaikoL1.sol:HeklaTaikoL1 |
| __gap          | uint256[49]            | 102  | 0      | 1568  | contracts/hekla/HeklaTaikoL1.sol:HeklaTaikoL1 |
| addressManager | address                | 151  | 0      | 20    | contracts/hekla/HeklaTaikoL1.sol:HeklaTaikoL1 |
| __gap          | uint256[49]            | 152  | 0      | 1568  | contracts/hekla/HeklaTaikoL1.sol:HeklaTaikoL1 |
| __reentry      | uint8                  | 201  | 0      | 1     | contracts/hekla/HeklaTaikoL1.sol:HeklaTaikoL1 |
| __paused       | uint8                  | 201  | 1      | 1     | contracts/hekla/HeklaTaikoL1.sol:HeklaTaikoL1 |
| lastUnpausedAt | uint64                 | 201  | 2      | 8     | contracts/hekla/HeklaTaikoL1.sol:HeklaTaikoL1 |
| __gap          | uint256[49]            | 202  | 0      | 1568  | contracts/hekla/HeklaTaikoL1.sol:HeklaTaikoL1 |
| state          | struct TaikoData.State | 251  | 0      | 1600  | contracts/hekla/HeklaTaikoL1.sol:HeklaTaikoL1 |
| __gap          | uint256[50]            | 301  | 0      | 1600  | contracts/hekla/HeklaTaikoL1.sol:HeklaTaikoL1 |

## contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge
| Name           | Type                                    | Slot | Offset | Bytes | Contract                                                 |
|----------------|-----------------------------------------|------|--------|-------|----------------------------------------------------------|
| _initialized   | uint8                                   | 0    | 0      | 1     | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |
| _initializing  | bool                                    | 0    | 1      | 1     | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |
| __gap          | uint256[50]                             | 1    | 0      | 1600  | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |
| _owner         | address                                 | 51   | 0      | 20    | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |
| __gap          | uint256[49]                             | 52   | 0      | 1568  | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |
| _pendingOwner  | address                                 | 101  | 0      | 20    | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |
| __gap          | uint256[49]                             | 102  | 0      | 1568  | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |
| addressManager | address                                 | 151  | 0      | 20    | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |
| __gap          | uint256[49]                             | 152  | 0      | 1568  | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |
| __reentry      | uint8                                   | 201  | 0      | 1     | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |
| __paused       | uint8                                   | 201  | 1      | 1     | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |
| lastUnpausedAt | uint64                                  | 201  | 2      | 8     | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |
| __gap          | uint256[49]                             | 202  | 0      | 1568  | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |
| __reserved1    | uint64                                  | 251  | 0      | 8     | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |
| nextMessageId  | uint64                                  | 251  | 8      | 8     | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |
| messageStatus  | mapping(bytes32 => enum IBridge.Status) | 252  | 0      | 32    | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |
| __ctx          | struct IBridge.Context                  | 253  | 0      | 64    | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |
| __reserved2    | uint256                                 | 255  | 0      | 32    | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |
| __reserved3    | uint256                                 | 256  | 0      | 32    | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |
| __gap          | uint256[44]                             | 257  | 0      | 1408  | contracts/mainnet/shared/MainnetBridge.sol:MainnetBridge |

## contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault
| Name               | Type                                                 | Slot | Offset | Bytes | Contract                                                             |
|--------------------|------------------------------------------------------|------|--------|-------|----------------------------------------------------------------------|
| _initialized       | uint8                                                | 0    | 0      | 1     | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |
| _initializing      | bool                                                 | 0    | 1      | 1     | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |
| __gap              | uint256[50]                                          | 1    | 0      | 1600  | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |
| _owner             | address                                              | 51   | 0      | 20    | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |
| __gap              | uint256[49]                                          | 52   | 0      | 1568  | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |
| _pendingOwner      | address                                              | 101  | 0      | 20    | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |
| __gap              | uint256[49]                                          | 102  | 0      | 1568  | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |
| addressManager     | address                                              | 151  | 0      | 20    | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |
| __gap              | uint256[49]                                          | 152  | 0      | 1568  | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |
| __reentry          | uint8                                                | 201  | 0      | 1     | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |
| __paused           | uint8                                                | 201  | 1      | 1     | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |
| lastUnpausedAt     | uint64                                               | 201  | 2      | 8     | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |
| __gap              | uint256[49]                                          | 202  | 0      | 1568  | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |
| __gap              | uint256[50]                                          | 251  | 0      | 1600  | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |
| bridgedToCanonical | mapping(address => struct BaseNFTVault.CanonicalNFT) | 301  | 0      | 32    | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |
| canonicalToBridged | mapping(uint256 => mapping(address => address))      | 302  | 0      | 32    | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |
| __gap              | uint256[48]                                          | 303  | 0      | 1536  | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |
| __gap              | uint256[50]                                          | 351  | 0      | 1600  | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |
| __gap              | uint256[50]                                          | 401  | 0      | 1600  | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |
| __gap              | uint256[50]                                          | 451  | 0      | 1600  | contracts/mainnet/shared/MainnetERC1155Vault.sol:MainnetERC1155Vault |

## contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault
| Name               | Type                                                 | Slot | Offset | Bytes | Contract                                                         |
|--------------------|------------------------------------------------------|------|--------|-------|------------------------------------------------------------------|
| _initialized       | uint8                                                | 0    | 0      | 1     | contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault |
| _initializing      | bool                                                 | 0    | 1      | 1     | contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault |
| __gap              | uint256[50]                                          | 1    | 0      | 1600  | contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault |
| _owner             | address                                              | 51   | 0      | 20    | contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault |
| __gap              | uint256[49]                                          | 52   | 0      | 1568  | contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault |
| _pendingOwner      | address                                              | 101  | 0      | 20    | contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault |
| __gap              | uint256[49]                                          | 102  | 0      | 1568  | contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault |
| addressManager     | address                                              | 151  | 0      | 20    | contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault |
| __gap              | uint256[49]                                          | 152  | 0      | 1568  | contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault |
| __reentry          | uint8                                                | 201  | 0      | 1     | contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault |
| __paused           | uint8                                                | 201  | 1      | 1     | contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault |
| lastUnpausedAt     | uint64                                               | 201  | 2      | 8     | contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault |
| __gap              | uint256[49]                                          | 202  | 0      | 1568  | contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault |
| __gap              | uint256[50]                                          | 251  | 0      | 1600  | contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault |
| bridgedToCanonical | mapping(address => struct ERC20Vault.CanonicalERC20) | 301  | 0      | 32    | contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault |
| canonicalToBridged | mapping(uint256 => mapping(address => address))      | 302  | 0      | 32    | contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault |
| btokenDenylist     | mapping(address => bool)                             | 303  | 0      | 32    | contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault |
| lastMigrationStart | mapping(uint256 => mapping(address => uint256))      | 304  | 0      | 32    | contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault |
| __gap              | uint256[46]                                          | 305  | 0      | 1472  | contracts/mainnet/shared/MainnetERC20Vault.sol:MainnetERC20Vault |

## contracts/mainnet/shared/MainnetERC721Vault.sol:MainnetERC721Vault
| Name               | Type                                                 | Slot | Offset | Bytes | Contract                                                           |
|--------------------|------------------------------------------------------|------|--------|-------|--------------------------------------------------------------------|
| _initialized       | uint8                                                | 0    | 0      | 1     | contracts/mainnet/shared/MainnetERC721Vault.sol:MainnetERC721Vault |
| _initializing      | bool                                                 | 0    | 1      | 1     | contracts/mainnet/shared/MainnetERC721Vault.sol:MainnetERC721Vault |
| __gap              | uint256[50]                                          | 1    | 0      | 1600  | contracts/mainnet/shared/MainnetERC721Vault.sol:MainnetERC721Vault |
| _owner             | address                                              | 51   | 0      | 20    | contracts/mainnet/shared/MainnetERC721Vault.sol:MainnetERC721Vault |
| __gap              | uint256[49]                                          | 52   | 0      | 1568  | contracts/mainnet/shared/MainnetERC721Vault.sol:MainnetERC721Vault |
| _pendingOwner      | address                                              | 101  | 0      | 20    | contracts/mainnet/shared/MainnetERC721Vault.sol:MainnetERC721Vault |
| __gap              | uint256[49]                                          | 102  | 0      | 1568  | contracts/mainnet/shared/MainnetERC721Vault.sol:MainnetERC721Vault |
| addressManager     | address                                              | 151  | 0      | 20    | contracts/mainnet/shared/MainnetERC721Vault.sol:MainnetERC721Vault |
| __gap              | uint256[49]                                          | 152  | 0      | 1568  | contracts/mainnet/shared/MainnetERC721Vault.sol:MainnetERC721Vault |
| __reentry          | uint8                                                | 201  | 0      | 1     | contracts/mainnet/shared/MainnetERC721Vault.sol:MainnetERC721Vault |
| __paused           | uint8                                                | 201  | 1      | 1     | contracts/mainnet/shared/MainnetERC721Vault.sol:MainnetERC721Vault |
| lastUnpausedAt     | uint64                                               | 201  | 2      | 8     | contracts/mainnet/shared/MainnetERC721Vault.sol:MainnetERC721Vault |
| __gap              | uint256[49]                                          | 202  | 0      | 1568  | contracts/mainnet/shared/MainnetERC721Vault.sol:MainnetERC721Vault |
| __gap              | uint256[50]                                          | 251  | 0      | 1600  | contracts/mainnet/shared/MainnetERC721Vault.sol:MainnetERC721Vault |
| bridgedToCanonical | mapping(address => struct BaseNFTVault.CanonicalNFT) | 301  | 0      | 32    | contracts/mainnet/shared/MainnetERC721Vault.sol:MainnetERC721Vault |
| canonicalToBridged | mapping(uint256 => mapping(address => address))      | 302  | 0      | 32    | contracts/mainnet/shared/MainnetERC721Vault.sol:MainnetERC721Vault |
| __gap              | uint256[48]                                          | 303  | 0      | 1536  | contracts/mainnet/shared/MainnetERC721Vault.sol:MainnetERC721Vault |
| __gap              | uint256[50]                                          | 351  | 0      | 1600  | contracts/mainnet/shared/MainnetERC721Vault.sol:MainnetERC721Vault |

## contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver
| Name                    | Type                                            | Slot | Offset | Bytes | Contract                                                                 |
|-------------------------|-------------------------------------------------|------|--------|-------|--------------------------------------------------------------------------|
| _initialized            | uint8                                           | 0    | 0      | 1     | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| _initializing           | bool                                            | 0    | 1      | 1     | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| __gap                   | uint256[50]                                     | 1    | 0      | 1600  | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| _owner                  | address                                         | 51   | 0      | 20    | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| __gap                   | uint256[49]                                     | 52   | 0      | 1568  | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| _pendingOwner           | address                                         | 101  | 0      | 20    | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| __gap                   | uint256[49]                                     | 102  | 0      | 1568  | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| addressManager          | address                                         | 151  | 0      | 20    | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| __gap                   | uint256[49]                                     | 152  | 0      | 1568  | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| __reentry               | uint8                                           | 201  | 0      | 1     | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| __paused                | uint8                                           | 201  | 1      | 1     | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| lastUnpausedAt          | uint64                                          | 201  | 2      | 8     | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| __gap                   | uint256[49]                                     | 202  | 0      | 1568  | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| guardianIds             | mapping(address => uint256)                     | 251  | 0      | 32    | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| approvals               | mapping(uint256 => mapping(bytes32 => uint256)) | 252  | 0      | 32    | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| guardians               | address[]                                       | 253  | 0      | 32    | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| version                 | uint32                                          | 254  | 0      | 4     | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| minGuardians            | uint32                                          | 254  | 4      | 4     | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| provingAutoPauseEnabled | bool                                            | 254  | 8      | 1     | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| latestProofHash         | mapping(uint256 => mapping(uint256 => bytes32)) | 255  | 0      | 32    | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |
| __gap                   | uint256[45]                                     | 256  | 0      | 1440  | contracts/mainnet/rollup/MainnetGuardianProver.sol:MainnetGuardianProver |

## contracts/mainnet/rollup/MainnetProverSet.sol:MainnetProverSet
| Name           | Type                     | Slot | Offset | Bytes | Contract                                                       |
|----------------|--------------------------|------|--------|-------|----------------------------------------------------------------|
| _initialized   | uint8                    | 0    | 0      | 1     | contracts/mainnet/rollup/MainnetProverSet.sol:MainnetProverSet |
| _initializing  | bool                     | 0    | 1      | 1     | contracts/mainnet/rollup/MainnetProverSet.sol:MainnetProverSet |
| __gap          | uint256[50]              | 1    | 0      | 1600  | contracts/mainnet/rollup/MainnetProverSet.sol:MainnetProverSet |
| _owner         | address                  | 51   | 0      | 20    | contracts/mainnet/rollup/MainnetProverSet.sol:MainnetProverSet |
| __gap          | uint256[49]              | 52   | 0      | 1568  | contracts/mainnet/rollup/MainnetProverSet.sol:MainnetProverSet |
| _pendingOwner  | address                  | 101  | 0      | 20    | contracts/mainnet/rollup/MainnetProverSet.sol:MainnetProverSet |
| __gap          | uint256[49]              | 102  | 0      | 1568  | contracts/mainnet/rollup/MainnetProverSet.sol:MainnetProverSet |
| addressManager | address                  | 151  | 0      | 20    | contracts/mainnet/rollup/MainnetProverSet.sol:MainnetProverSet |
| __gap          | uint256[49]              | 152  | 0      | 1568  | contracts/mainnet/rollup/MainnetProverSet.sol:MainnetProverSet |
| __reentry      | uint8                    | 201  | 0      | 1     | contracts/mainnet/rollup/MainnetProverSet.sol:MainnetProverSet |
| __paused       | uint8                    | 201  | 1      | 1     | contracts/mainnet/rollup/MainnetProverSet.sol:MainnetProverSet |
| lastUnpausedAt | uint64                   | 201  | 2      | 8     | contracts/mainnet/rollup/MainnetProverSet.sol:MainnetProverSet |
| __gap          | uint256[49]              | 202  | 0      | 1568  | contracts/mainnet/rollup/MainnetProverSet.sol:MainnetProverSet |
| isProver       | mapping(address => bool) | 251  | 0      | 32    | contracts/mainnet/rollup/MainnetProverSet.sol:MainnetProverSet |
| admin          | address                  | 252  | 0      | 20    | contracts/mainnet/rollup/MainnetProverSet.sol:MainnetProverSet |
| __gap          | uint256[48]              | 253  | 0      | 1536  | contracts/mainnet/rollup/MainnetProverSet.sol:MainnetProverSet |

## contracts/mainnet/rollup/verifiers/MainnetRisc0Verifier.sol:MainnetRisc0Verifier
| Name           | Type                     | Slot | Offset | Bytes | Contract                                                                         |
|----------------|--------------------------|------|--------|-------|----------------------------------------------------------------------------------|
| _initialized   | uint8                    | 0    | 0      | 1     | contracts/mainnet/rollup/verifiers/MainnetRisc0Verifier.sol:MainnetRisc0Verifier |
| _initializing  | bool                     | 0    | 1      | 1     | contracts/mainnet/rollup/verifiers/MainnetRisc0Verifier.sol:MainnetRisc0Verifier |
| __gap          | uint256[50]              | 1    | 0      | 1600  | contracts/mainnet/rollup/verifiers/MainnetRisc0Verifier.sol:MainnetRisc0Verifier |
| _owner         | address                  | 51   | 0      | 20    | contracts/mainnet/rollup/verifiers/MainnetRisc0Verifier.sol:MainnetRisc0Verifier |
| __gap          | uint256[49]              | 52   | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetRisc0Verifier.sol:MainnetRisc0Verifier |
| _pendingOwner  | address                  | 101  | 0      | 20    | contracts/mainnet/rollup/verifiers/MainnetRisc0Verifier.sol:MainnetRisc0Verifier |
| __gap          | uint256[49]              | 102  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetRisc0Verifier.sol:MainnetRisc0Verifier |
| addressManager | address                  | 151  | 0      | 20    | contracts/mainnet/rollup/verifiers/MainnetRisc0Verifier.sol:MainnetRisc0Verifier |
| __gap          | uint256[49]              | 152  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetRisc0Verifier.sol:MainnetRisc0Verifier |
| __reentry      | uint8                    | 201  | 0      | 1     | contracts/mainnet/rollup/verifiers/MainnetRisc0Verifier.sol:MainnetRisc0Verifier |
| __paused       | uint8                    | 201  | 1      | 1     | contracts/mainnet/rollup/verifiers/MainnetRisc0Verifier.sol:MainnetRisc0Verifier |
| lastUnpausedAt | uint64                   | 201  | 2      | 8     | contracts/mainnet/rollup/verifiers/MainnetRisc0Verifier.sol:MainnetRisc0Verifier |
| __gap          | uint256[49]              | 202  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetRisc0Verifier.sol:MainnetRisc0Verifier |
| isImageTrusted | mapping(bytes32 => bool) | 251  | 0      | 32    | contracts/mainnet/rollup/verifiers/MainnetRisc0Verifier.sol:MainnetRisc0Verifier |
| __gap          | uint256[49]              | 252  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetRisc0Verifier.sol:MainnetRisc0Verifier |

## contracts/mainnet/rollup/verifiers/MainnetSP1Verifier.sol:MainnetSP1Verifier
| Name             | Type                     | Slot | Offset | Bytes | Contract                                                                     |
|------------------|--------------------------|------|--------|-------|------------------------------------------------------------------------------|
| _initialized     | uint8                    | 0    | 0      | 1     | contracts/mainnet/rollup/verifiers/MainnetSP1Verifier.sol:MainnetSP1Verifier |
| _initializing    | bool                     | 0    | 1      | 1     | contracts/mainnet/rollup/verifiers/MainnetSP1Verifier.sol:MainnetSP1Verifier |
| __gap            | uint256[50]              | 1    | 0      | 1600  | contracts/mainnet/rollup/verifiers/MainnetSP1Verifier.sol:MainnetSP1Verifier |
| _owner           | address                  | 51   | 0      | 20    | contracts/mainnet/rollup/verifiers/MainnetSP1Verifier.sol:MainnetSP1Verifier |
| __gap            | uint256[49]              | 52   | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetSP1Verifier.sol:MainnetSP1Verifier |
| _pendingOwner    | address                  | 101  | 0      | 20    | contracts/mainnet/rollup/verifiers/MainnetSP1Verifier.sol:MainnetSP1Verifier |
| __gap            | uint256[49]              | 102  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetSP1Verifier.sol:MainnetSP1Verifier |
| addressManager   | address                  | 151  | 0      | 20    | contracts/mainnet/rollup/verifiers/MainnetSP1Verifier.sol:MainnetSP1Verifier |
| __gap            | uint256[49]              | 152  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetSP1Verifier.sol:MainnetSP1Verifier |
| __reentry        | uint8                    | 201  | 0      | 1     | contracts/mainnet/rollup/verifiers/MainnetSP1Verifier.sol:MainnetSP1Verifier |
| __paused         | uint8                    | 201  | 1      | 1     | contracts/mainnet/rollup/verifiers/MainnetSP1Verifier.sol:MainnetSP1Verifier |
| lastUnpausedAt   | uint64                   | 201  | 2      | 8     | contracts/mainnet/rollup/verifiers/MainnetSP1Verifier.sol:MainnetSP1Verifier |
| __gap            | uint256[49]              | 202  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetSP1Verifier.sol:MainnetSP1Verifier |
| isProgramTrusted | mapping(bytes32 => bool) | 251  | 0      | 32    | contracts/mainnet/rollup/verifiers/MainnetSP1Verifier.sol:MainnetSP1Verifier |
| __gap            | uint256[49]              | 252  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetSP1Verifier.sol:MainnetSP1Verifier |

## contracts/mainnet/rollup/MainnetRollupAddressManager.sol:MainnetRollupAddressManager
| Name           | Type                                            | Slot | Offset | Bytes | Contract                                                                             |
|----------------|-------------------------------------------------|------|--------|-------|--------------------------------------------------------------------------------------|
| _initialized   | uint8                                           | 0    | 0      | 1     | contracts/mainnet/rollup/MainnetRollupAddressManager.sol:MainnetRollupAddressManager |
| _initializing  | bool                                            | 0    | 1      | 1     | contracts/mainnet/rollup/MainnetRollupAddressManager.sol:MainnetRollupAddressManager |
| __gap          | uint256[50]                                     | 1    | 0      | 1600  | contracts/mainnet/rollup/MainnetRollupAddressManager.sol:MainnetRollupAddressManager |
| _owner         | address                                         | 51   | 0      | 20    | contracts/mainnet/rollup/MainnetRollupAddressManager.sol:MainnetRollupAddressManager |
| __gap          | uint256[49]                                     | 52   | 0      | 1568  | contracts/mainnet/rollup/MainnetRollupAddressManager.sol:MainnetRollupAddressManager |
| _pendingOwner  | address                                         | 101  | 0      | 20    | contracts/mainnet/rollup/MainnetRollupAddressManager.sol:MainnetRollupAddressManager |
| __gap          | uint256[49]                                     | 102  | 0      | 1568  | contracts/mainnet/rollup/MainnetRollupAddressManager.sol:MainnetRollupAddressManager |
| addressManager | address                                         | 151  | 0      | 20    | contracts/mainnet/rollup/MainnetRollupAddressManager.sol:MainnetRollupAddressManager |
| __gap          | uint256[49]                                     | 152  | 0      | 1568  | contracts/mainnet/rollup/MainnetRollupAddressManager.sol:MainnetRollupAddressManager |
| __reentry      | uint8                                           | 201  | 0      | 1     | contracts/mainnet/rollup/MainnetRollupAddressManager.sol:MainnetRollupAddressManager |
| __paused       | uint8                                           | 201  | 1      | 1     | contracts/mainnet/rollup/MainnetRollupAddressManager.sol:MainnetRollupAddressManager |
| lastUnpausedAt | uint64                                          | 201  | 2      | 8     | contracts/mainnet/rollup/MainnetRollupAddressManager.sol:MainnetRollupAddressManager |
| __gap          | uint256[49]                                     | 202  | 0      | 1568  | contracts/mainnet/rollup/MainnetRollupAddressManager.sol:MainnetRollupAddressManager |
| __addresses    | mapping(uint256 => mapping(bytes32 => address)) | 251  | 0      | 32    | contracts/mainnet/rollup/MainnetRollupAddressManager.sol:MainnetRollupAddressManager |
| __gap          | uint256[49]                                     | 252  | 0      | 1568  | contracts/mainnet/rollup/MainnetRollupAddressManager.sol:MainnetRollupAddressManager |

## contracts/mainnet/rollup/verifiers/MainnetSgxVerifier.sol:MainnetSgxVerifier
| Name              | Type                                            | Slot | Offset | Bytes | Contract                                                                     |
|-------------------|-------------------------------------------------|------|--------|-------|------------------------------------------------------------------------------|
| _initialized      | uint8                                           | 0    | 0      | 1     | contracts/mainnet/rollup/verifiers/MainnetSgxVerifier.sol:MainnetSgxVerifier |
| _initializing     | bool                                            | 0    | 1      | 1     | contracts/mainnet/rollup/verifiers/MainnetSgxVerifier.sol:MainnetSgxVerifier |
| __gap             | uint256[50]                                     | 1    | 0      | 1600  | contracts/mainnet/rollup/verifiers/MainnetSgxVerifier.sol:MainnetSgxVerifier |
| _owner            | address                                         | 51   | 0      | 20    | contracts/mainnet/rollup/verifiers/MainnetSgxVerifier.sol:MainnetSgxVerifier |
| __gap             | uint256[49]                                     | 52   | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetSgxVerifier.sol:MainnetSgxVerifier |
| _pendingOwner     | address                                         | 101  | 0      | 20    | contracts/mainnet/rollup/verifiers/MainnetSgxVerifier.sol:MainnetSgxVerifier |
| __gap             | uint256[49]                                     | 102  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetSgxVerifier.sol:MainnetSgxVerifier |
| addressManager    | address                                         | 151  | 0      | 20    | contracts/mainnet/rollup/verifiers/MainnetSgxVerifier.sol:MainnetSgxVerifier |
| __gap             | uint256[49]                                     | 152  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetSgxVerifier.sol:MainnetSgxVerifier |
| __reentry         | uint8                                           | 201  | 0      | 1     | contracts/mainnet/rollup/verifiers/MainnetSgxVerifier.sol:MainnetSgxVerifier |
| __paused          | uint8                                           | 201  | 1      | 1     | contracts/mainnet/rollup/verifiers/MainnetSgxVerifier.sol:MainnetSgxVerifier |
| lastUnpausedAt    | uint64                                          | 201  | 2      | 8     | contracts/mainnet/rollup/verifiers/MainnetSgxVerifier.sol:MainnetSgxVerifier |
| __gap             | uint256[49]                                     | 202  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetSgxVerifier.sol:MainnetSgxVerifier |
| nextInstanceId    | uint256                                         | 251  | 0      | 32    | contracts/mainnet/rollup/verifiers/MainnetSgxVerifier.sol:MainnetSgxVerifier |
| instances         | mapping(uint256 => struct SgxVerifier.Instance) | 252  | 0      | 32    | contracts/mainnet/rollup/verifiers/MainnetSgxVerifier.sol:MainnetSgxVerifier |
| addressRegistered | mapping(address => bool)                        | 253  | 0      | 32    | contracts/mainnet/rollup/verifiers/MainnetSgxVerifier.sol:MainnetSgxVerifier |
| __gap             | uint256[47]                                     | 254  | 0      | 1504  | contracts/mainnet/rollup/verifiers/MainnetSgxVerifier.sol:MainnetSgxVerifier |

## contracts/mainnet/rollup/verifiers/MainnetTeeAnyVerifier.sol:MainnetTeeAnyVerifier
| Name           | Type        | Slot | Offset | Bytes | Contract                                                                           |
|----------------|-------------|------|--------|-------|------------------------------------------------------------------------------------|
| _initialized   | uint8       | 0    | 0      | 1     | contracts/mainnet/rollup/verifiers/MainnetTeeAnyVerifier.sol:MainnetTeeAnyVerifier |
| _initializing  | bool        | 0    | 1      | 1     | contracts/mainnet/rollup/verifiers/MainnetTeeAnyVerifier.sol:MainnetTeeAnyVerifier |
| __gap          | uint256[50] | 1    | 0      | 1600  | contracts/mainnet/rollup/verifiers/MainnetTeeAnyVerifier.sol:MainnetTeeAnyVerifier |
| _owner         | address     | 51   | 0      | 20    | contracts/mainnet/rollup/verifiers/MainnetTeeAnyVerifier.sol:MainnetTeeAnyVerifier |
| __gap          | uint256[49] | 52   | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetTeeAnyVerifier.sol:MainnetTeeAnyVerifier |
| _pendingOwner  | address     | 101  | 0      | 20    | contracts/mainnet/rollup/verifiers/MainnetTeeAnyVerifier.sol:MainnetTeeAnyVerifier |
| __gap          | uint256[49] | 102  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetTeeAnyVerifier.sol:MainnetTeeAnyVerifier |
| addressManager | address     | 151  | 0      | 20    | contracts/mainnet/rollup/verifiers/MainnetTeeAnyVerifier.sol:MainnetTeeAnyVerifier |
| __gap          | uint256[49] | 152  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetTeeAnyVerifier.sol:MainnetTeeAnyVerifier |
| __reentry      | uint8       | 201  | 0      | 1     | contracts/mainnet/rollup/verifiers/MainnetTeeAnyVerifier.sol:MainnetTeeAnyVerifier |
| __paused       | uint8       | 201  | 1      | 1     | contracts/mainnet/rollup/verifiers/MainnetTeeAnyVerifier.sol:MainnetTeeAnyVerifier |
| lastUnpausedAt | uint64      | 201  | 2      | 8     | contracts/mainnet/rollup/verifiers/MainnetTeeAnyVerifier.sol:MainnetTeeAnyVerifier |
| __gap          | uint256[49] | 202  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetTeeAnyVerifier.sol:MainnetTeeAnyVerifier |
| __gap          | uint256[50] | 251  | 0      | 1600  | contracts/mainnet/rollup/verifiers/MainnetTeeAnyVerifier.sol:MainnetTeeAnyVerifier |
| __gap          | uint256[50] | 301  | 0      | 1600  | contracts/mainnet/rollup/verifiers/MainnetTeeAnyVerifier.sol:MainnetTeeAnyVerifier |

## contracts/mainnet/rollup/verifiers/MainnetZkAnyVerifier.sol:MainnetZkAnyVerifier
| Name           | Type        | Slot | Offset | Bytes | Contract                                                                         |
|----------------|-------------|------|--------|-------|----------------------------------------------------------------------------------|
| _initialized   | uint8       | 0    | 0      | 1     | contracts/mainnet/rollup/verifiers/MainnetZkAnyVerifier.sol:MainnetZkAnyVerifier |
| _initializing  | bool        | 0    | 1      | 1     | contracts/mainnet/rollup/verifiers/MainnetZkAnyVerifier.sol:MainnetZkAnyVerifier |
| __gap          | uint256[50] | 1    | 0      | 1600  | contracts/mainnet/rollup/verifiers/MainnetZkAnyVerifier.sol:MainnetZkAnyVerifier |
| _owner         | address     | 51   | 0      | 20    | contracts/mainnet/rollup/verifiers/MainnetZkAnyVerifier.sol:MainnetZkAnyVerifier |
| __gap          | uint256[49] | 52   | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetZkAnyVerifier.sol:MainnetZkAnyVerifier |
| _pendingOwner  | address     | 101  | 0      | 20    | contracts/mainnet/rollup/verifiers/MainnetZkAnyVerifier.sol:MainnetZkAnyVerifier |
| __gap          | uint256[49] | 102  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetZkAnyVerifier.sol:MainnetZkAnyVerifier |
| addressManager | address     | 151  | 0      | 20    | contracts/mainnet/rollup/verifiers/MainnetZkAnyVerifier.sol:MainnetZkAnyVerifier |
| __gap          | uint256[49] | 152  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetZkAnyVerifier.sol:MainnetZkAnyVerifier |
| __reentry      | uint8       | 201  | 0      | 1     | contracts/mainnet/rollup/verifiers/MainnetZkAnyVerifier.sol:MainnetZkAnyVerifier |
| __paused       | uint8       | 201  | 1      | 1     | contracts/mainnet/rollup/verifiers/MainnetZkAnyVerifier.sol:MainnetZkAnyVerifier |
| lastUnpausedAt | uint64      | 201  | 2      | 8     | contracts/mainnet/rollup/verifiers/MainnetZkAnyVerifier.sol:MainnetZkAnyVerifier |
| __gap          | uint256[49] | 202  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetZkAnyVerifier.sol:MainnetZkAnyVerifier |
| __gap          | uint256[50] | 251  | 0      | 1600  | contracts/mainnet/rollup/verifiers/MainnetZkAnyVerifier.sol:MainnetZkAnyVerifier |
| __gap          | uint256[50] | 301  | 0      | 1600  | contracts/mainnet/rollup/verifiers/MainnetZkAnyVerifier.sol:MainnetZkAnyVerifier |

## contracts/mainnet/rollup/verifiers/MainnetZkAndTeeVerifier.sol:MainnetZkAndTeeVerifier
| Name           | Type        | Slot | Offset | Bytes | Contract                                                                               |
|----------------|-------------|------|--------|-------|----------------------------------------------------------------------------------------|
| _initialized   | uint8       | 0    | 0      | 1     | contracts/mainnet/rollup/verifiers/MainnetZkAndTeeVerifier.sol:MainnetZkAndTeeVerifier |
| _initializing  | bool        | 0    | 1      | 1     | contracts/mainnet/rollup/verifiers/MainnetZkAndTeeVerifier.sol:MainnetZkAndTeeVerifier |
| __gap          | uint256[50] | 1    | 0      | 1600  | contracts/mainnet/rollup/verifiers/MainnetZkAndTeeVerifier.sol:MainnetZkAndTeeVerifier |
| _owner         | address     | 51   | 0      | 20    | contracts/mainnet/rollup/verifiers/MainnetZkAndTeeVerifier.sol:MainnetZkAndTeeVerifier |
| __gap          | uint256[49] | 52   | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetZkAndTeeVerifier.sol:MainnetZkAndTeeVerifier |
| _pendingOwner  | address     | 101  | 0      | 20    | contracts/mainnet/rollup/verifiers/MainnetZkAndTeeVerifier.sol:MainnetZkAndTeeVerifier |
| __gap          | uint256[49] | 102  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetZkAndTeeVerifier.sol:MainnetZkAndTeeVerifier |
| addressManager | address     | 151  | 0      | 20    | contracts/mainnet/rollup/verifiers/MainnetZkAndTeeVerifier.sol:MainnetZkAndTeeVerifier |
| __gap          | uint256[49] | 152  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetZkAndTeeVerifier.sol:MainnetZkAndTeeVerifier |
| __reentry      | uint8       | 201  | 0      | 1     | contracts/mainnet/rollup/verifiers/MainnetZkAndTeeVerifier.sol:MainnetZkAndTeeVerifier |
| __paused       | uint8       | 201  | 1      | 1     | contracts/mainnet/rollup/verifiers/MainnetZkAndTeeVerifier.sol:MainnetZkAndTeeVerifier |
| lastUnpausedAt | uint64      | 201  | 2      | 8     | contracts/mainnet/rollup/verifiers/MainnetZkAndTeeVerifier.sol:MainnetZkAndTeeVerifier |
| __gap          | uint256[49] | 202  | 0      | 1568  | contracts/mainnet/rollup/verifiers/MainnetZkAndTeeVerifier.sol:MainnetZkAndTeeVerifier |
| __gap          | uint256[50] | 251  | 0      | 1600  | contracts/mainnet/rollup/verifiers/MainnetZkAndTeeVerifier.sol:MainnetZkAndTeeVerifier |
| __gap          | uint256[50] | 301  | 0      | 1600  | contracts/mainnet/rollup/verifiers/MainnetZkAndTeeVerifier.sol:MainnetZkAndTeeVerifier |

## contracts/mainnet/shared/MainnetSharedAddressManager.sol:MainnetSharedAddressManager
| Name           | Type                                            | Slot | Offset | Bytes | Contract                                                                             |
|----------------|-------------------------------------------------|------|--------|-------|--------------------------------------------------------------------------------------|
| _initialized   | uint8                                           | 0    | 0      | 1     | contracts/mainnet/shared/MainnetSharedAddressManager.sol:MainnetSharedAddressManager |
| _initializing  | bool                                            | 0    | 1      | 1     | contracts/mainnet/shared/MainnetSharedAddressManager.sol:MainnetSharedAddressManager |
| __gap          | uint256[50]                                     | 1    | 0      | 1600  | contracts/mainnet/shared/MainnetSharedAddressManager.sol:MainnetSharedAddressManager |
| _owner         | address                                         | 51   | 0      | 20    | contracts/mainnet/shared/MainnetSharedAddressManager.sol:MainnetSharedAddressManager |
| __gap          | uint256[49]                                     | 52   | 0      | 1568  | contracts/mainnet/shared/MainnetSharedAddressManager.sol:MainnetSharedAddressManager |
| _pendingOwner  | address                                         | 101  | 0      | 20    | contracts/mainnet/shared/MainnetSharedAddressManager.sol:MainnetSharedAddressManager |
| __gap          | uint256[49]                                     | 102  | 0      | 1568  | contracts/mainnet/shared/MainnetSharedAddressManager.sol:MainnetSharedAddressManager |
| addressManager | address                                         | 151  | 0      | 20    | contracts/mainnet/shared/MainnetSharedAddressManager.sol:MainnetSharedAddressManager |
| __gap          | uint256[49]                                     | 152  | 0      | 1568  | contracts/mainnet/shared/MainnetSharedAddressManager.sol:MainnetSharedAddressManager |
| __reentry      | uint8                                           | 201  | 0      | 1     | contracts/mainnet/shared/MainnetSharedAddressManager.sol:MainnetSharedAddressManager |
| __paused       | uint8                                           | 201  | 1      | 1     | contracts/mainnet/shared/MainnetSharedAddressManager.sol:MainnetSharedAddressManager |
| lastUnpausedAt | uint64                                          | 201  | 2      | 8     | contracts/mainnet/shared/MainnetSharedAddressManager.sol:MainnetSharedAddressManager |
| __gap          | uint256[49]                                     | 202  | 0      | 1568  | contracts/mainnet/shared/MainnetSharedAddressManager.sol:MainnetSharedAddressManager |
| __addresses    | mapping(uint256 => mapping(bytes32 => address)) | 251  | 0      | 32    | contracts/mainnet/shared/MainnetSharedAddressManager.sol:MainnetSharedAddressManager |
| __gap          | uint256[49]                                     | 252  | 0      | 1568  | contracts/mainnet/shared/MainnetSharedAddressManager.sol:MainnetSharedAddressManager |

## contracts/mainnet/shared/MainnetSignalService.sol:MainnetSignalService
| Name           | Type                                          | Slot | Offset | Bytes | Contract                                                               |
|----------------|-----------------------------------------------|------|--------|-------|------------------------------------------------------------------------|
| _initialized   | uint8                                         | 0    | 0      | 1     | contracts/mainnet/shared/MainnetSignalService.sol:MainnetSignalService |
| _initializing  | bool                                          | 0    | 1      | 1     | contracts/mainnet/shared/MainnetSignalService.sol:MainnetSignalService |
| __gap          | uint256[50]                                   | 1    | 0      | 1600  | contracts/mainnet/shared/MainnetSignalService.sol:MainnetSignalService |
| _owner         | address                                       | 51   | 0      | 20    | contracts/mainnet/shared/MainnetSignalService.sol:MainnetSignalService |
| __gap          | uint256[49]                                   | 52   | 0      | 1568  | contracts/mainnet/shared/MainnetSignalService.sol:MainnetSignalService |
| _pendingOwner  | address                                       | 101  | 0      | 20    | contracts/mainnet/shared/MainnetSignalService.sol:MainnetSignalService |
| __gap          | uint256[49]                                   | 102  | 0      | 1568  | contracts/mainnet/shared/MainnetSignalService.sol:MainnetSignalService |
| addressManager | address                                       | 151  | 0      | 20    | contracts/mainnet/shared/MainnetSignalService.sol:MainnetSignalService |
| __gap          | uint256[49]                                   | 152  | 0      | 1568  | contracts/mainnet/shared/MainnetSignalService.sol:MainnetSignalService |
| __reentry      | uint8                                         | 201  | 0      | 1     | contracts/mainnet/shared/MainnetSignalService.sol:MainnetSignalService |
| __paused       | uint8                                         | 201  | 1      | 1     | contracts/mainnet/shared/MainnetSignalService.sol:MainnetSignalService |
| lastUnpausedAt | uint64                                        | 201  | 2      | 8     | contracts/mainnet/shared/MainnetSignalService.sol:MainnetSignalService |
| __gap          | uint256[49]                                   | 202  | 0      | 1568  | contracts/mainnet/shared/MainnetSignalService.sol:MainnetSignalService |
| topBlockId     | mapping(uint64 => mapping(bytes32 => uint64)) | 251  | 0      | 32    | contracts/mainnet/shared/MainnetSignalService.sol:MainnetSignalService |
| isAuthorized   | mapping(address => bool)                      | 252  | 0      | 32    | contracts/mainnet/shared/MainnetSignalService.sol:MainnetSignalService |
| __gap          | uint256[48]                                   | 253  | 0      | 1536  | contracts/mainnet/shared/MainnetSignalService.sol:MainnetSignalService |

## contracts/mainnet/rollup/MainnetTaikoL1.sol:MainnetTaikoL1
| Name           | Type                   | Slot | Offset | Bytes | Contract                                                   |
|----------------|------------------------|------|--------|-------|------------------------------------------------------------|
| _initialized   | uint8                  | 0    | 0      | 1     | contracts/mainnet/rollup/MainnetTaikoL1.sol:MainnetTaikoL1 |
| _initializing  | bool                   | 0    | 1      | 1     | contracts/mainnet/rollup/MainnetTaikoL1.sol:MainnetTaikoL1 |
| __gap          | uint256[50]            | 1    | 0      | 1600  | contracts/mainnet/rollup/MainnetTaikoL1.sol:MainnetTaikoL1 |
| _owner         | address                | 51   | 0      | 20    | contracts/mainnet/rollup/MainnetTaikoL1.sol:MainnetTaikoL1 |
| __gap          | uint256[49]            | 52   | 0      | 1568  | contracts/mainnet/rollup/MainnetTaikoL1.sol:MainnetTaikoL1 |
| _pendingOwner  | address                | 101  | 0      | 20    | contracts/mainnet/rollup/MainnetTaikoL1.sol:MainnetTaikoL1 |
| __gap          | uint256[49]            | 102  | 0      | 1568  | contracts/mainnet/rollup/MainnetTaikoL1.sol:MainnetTaikoL1 |
| addressManager | address                | 151  | 0      | 20    | contracts/mainnet/rollup/MainnetTaikoL1.sol:MainnetTaikoL1 |
| __gap          | uint256[49]            | 152  | 0      | 1568  | contracts/mainnet/rollup/MainnetTaikoL1.sol:MainnetTaikoL1 |
| __reentry      | uint8                  | 201  | 0      | 1     | contracts/mainnet/rollup/MainnetTaikoL1.sol:MainnetTaikoL1 |
| __paused       | uint8                  | 201  | 1      | 1     | contracts/mainnet/rollup/MainnetTaikoL1.sol:MainnetTaikoL1 |
| lastUnpausedAt | uint64                 | 201  | 2      | 8     | contracts/mainnet/rollup/MainnetTaikoL1.sol:MainnetTaikoL1 |
| __gap          | uint256[49]            | 202  | 0      | 1568  | contracts/mainnet/rollup/MainnetTaikoL1.sol:MainnetTaikoL1 |
| state          | struct TaikoData.State | 251  | 0      | 1600  | contracts/mainnet/rollup/MainnetTaikoL1.sol:MainnetTaikoL1 |
| __gap          | uint256[50]            | 301  | 0      | 1600  | contracts/mainnet/rollup/MainnetTaikoL1.sol:MainnetTaikoL1 |

## contracts/mainnet/rollup/MainnetTierRouter.sol:MainnetTierRouter
| Name | Type | Slot | Offset | Bytes | Contract |
|------|------|------|--------|-------|----------|

