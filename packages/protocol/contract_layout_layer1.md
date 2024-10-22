## ERC1155Vault
| Name               | Type                                                 | Slot | Offset | Bytes | Contract                                                  |
|--------------------|------------------------------------------------------|------|--------|-------|-----------------------------------------------------------|
| _initialized       | uint8                                                | 0    | 0      | 1     | ERC1155Vault |
| _initializing      | bool                                                 | 0    | 1      | 1     | ERC1155Vault |
| __gap              | uint256[50]                                          | 1    | 0      | 1600  | ERC1155Vault |
| _owner             | address                                              | 51   | 0      | 20    | ERC1155Vault |
| __gap              | uint256[49]                                          | 52   | 0      | 1568  | ERC1155Vault |
| _pendingOwner      | address                                              | 101  | 0      | 20    | ERC1155Vault |
| __gap              | uint256[49]                                          | 102  | 0      | 1568  | ERC1155Vault |
| addressManager     | address                                              | 151  | 0      | 20    | ERC1155Vault |
| __gap              | uint256[49]                                          | 152  | 0      | 1568  | ERC1155Vault |
| __reentry          | uint8                                                | 201  | 0      | 1     | ERC1155Vault |
| __paused           | uint8                                                | 201  | 1      | 1     | ERC1155Vault |
| __lastUnpausedAt   | uint64                                               | 201  | 2      | 8     | ERC1155Vault |
| __gap              | uint256[49]                                          | 202  | 0      | 1568  | ERC1155Vault |
| __gap              | uint256[50]                                          | 251  | 0      | 1600  | ERC1155Vault |
| bridgedToCanonical | mapping(address => struct BaseNFTVault.CanonicalNFT) | 301  | 0      | 32    | ERC1155Vault |
| canonicalToBridged | mapping(uint256 => mapping(address => address))      | 302  | 0      | 32    | ERC1155Vault |
| __gap              | uint256[48]                                          | 303  | 0      | 1536  | ERC1155Vault |
| __gap              | uint256[50]                                          | 351  | 0      | 1600  | ERC1155Vault |
| __gap              | uint256[50]                                          | 401  | 0      | 1600  | ERC1155Vault |
| __gap              | uint256[50]                                          | 451  | 0      | 1600  | ERC1155Vault |

## ERC20Vault
| Name               | Type                                                 | Slot | Offset | Bytes | Contract                                              |
|--------------------|------------------------------------------------------|------|--------|-------|-------------------------------------------------------|
| _initialized       | uint8                                                | 0    | 0      | 1     | ERC20Vault |
| _initializing      | bool                                                 | 0    | 1      | 1     | ERC20Vault |
| __gap              | uint256[50]                                          | 1    | 0      | 1600  | ERC20Vault |
| _owner             | address                                              | 51   | 0      | 20    | ERC20Vault |
| __gap              | uint256[49]                                          | 52   | 0      | 1568  | ERC20Vault |
| _pendingOwner      | address                                              | 101  | 0      | 20    | ERC20Vault |
| __gap              | uint256[49]                                          | 102  | 0      | 1568  | ERC20Vault |
| addressManager     | address                                              | 151  | 0      | 20    | ERC20Vault |
| __gap              | uint256[49]                                          | 152  | 0      | 1568  | ERC20Vault |
| __reentry          | uint8                                                | 201  | 0      | 1     | ERC20Vault |
| __paused           | uint8                                                | 201  | 1      | 1     | ERC20Vault |
| __lastUnpausedAt   | uint64                                               | 201  | 2      | 8     | ERC20Vault |
| __gap              | uint256[49]                                          | 202  | 0      | 1568  | ERC20Vault |
| __gap              | uint256[50]                                          | 251  | 0      | 1600  | ERC20Vault |
| bridgedToCanonical | mapping(address => struct ERC20Vault.CanonicalERC20) | 301  | 0      | 32    | ERC20Vault |
| canonicalToBridged | mapping(uint256 => mapping(address => address))      | 302  | 0      | 32    | ERC20Vault |
| btokenDenylist     | mapping(address => bool)                             | 303  | 0      | 32    | ERC20Vault |
| lastMigrationStart | mapping(uint256 => mapping(address => uint256))      | 304  | 0      | 32    | ERC20Vault |
| __gap              | uint256[46]                                          | 305  | 0      | 1472  | ERC20Vault |

## ERC721Vault
| Name               | Type                                                 | Slot | Offset | Bytes | Contract                                                |
|--------------------|------------------------------------------------------|------|--------|-------|---------------------------------------------------------|
| _initialized       | uint8                                                | 0    | 0      | 1     | ERC721Vault |
| _initializing      | bool                                                 | 0    | 1      | 1     | ERC721Vault |
| __gap              | uint256[50]                                          | 1    | 0      | 1600  | ERC721Vault |
| _owner             | address                                              | 51   | 0      | 20    | ERC721Vault |
| __gap              | uint256[49]                                          | 52   | 0      | 1568  | ERC721Vault |
| _pendingOwner      | address                                              | 101  | 0      | 20    | ERC721Vault |
| __gap              | uint256[49]                                          | 102  | 0      | 1568  | ERC721Vault |
| addressManager     | address                                              | 151  | 0      | 20    | ERC721Vault |
| __gap              | uint256[49]                                          | 152  | 0      | 1568  | ERC721Vault |
| __reentry          | uint8                                                | 201  | 0      | 1     | ERC721Vault |
| __paused           | uint8                                                | 201  | 1      | 1     | ERC721Vault |
| __lastUnpausedAt   | uint64                                               | 201  | 2      | 8     | ERC721Vault |
| __gap              | uint256[49]                                          | 202  | 0      | 1568  | ERC721Vault |
| __gap              | uint256[50]                                          | 251  | 0      | 1600  | ERC721Vault |
| bridgedToCanonical | mapping(address => struct BaseNFTVault.CanonicalNFT) | 301  | 0      | 32    | ERC721Vault |
| canonicalToBridged | mapping(uint256 => mapping(address => address))      | 302  | 0      | 32    | ERC721Vault |
| __gap              | uint256[48]                                          | 303  | 0      | 1536  | ERC721Vault |
| __gap              | uint256[50]                                          | 351  | 0      | 1600  | ERC721Vault |

## BridgedERC20
| Name             | Type                                            | Slot | Offset | Bytes | Contract                                                  |
|------------------|-------------------------------------------------|------|--------|-------|-----------------------------------------------------------|
| _initialized     | uint8                                           | 0    | 0      | 1     | BridgedERC20 |
| _initializing    | bool                                            | 0    | 1      | 1     | BridgedERC20 |
| __gap            | uint256[50]                                     | 1    | 0      | 1600  | BridgedERC20 |
| _owner           | address                                         | 51   | 0      | 20    | BridgedERC20 |
| __gap            | uint256[49]                                     | 52   | 0      | 1568  | BridgedERC20 |
| _pendingOwner    | address                                         | 101  | 0      | 20    | BridgedERC20 |
| __gap            | uint256[49]                                     | 102  | 0      | 1568  | BridgedERC20 |
| addressManager   | address                                         | 151  | 0      | 20    | BridgedERC20 |
| __gap            | uint256[49]                                     | 152  | 0      | 1568  | BridgedERC20 |
| __reentry        | uint8                                           | 201  | 0      | 1     | BridgedERC20 |
| __paused         | uint8                                           | 201  | 1      | 1     | BridgedERC20 |
| __lastUnpausedAt | uint64                                          | 201  | 2      | 8     | BridgedERC20 |
| __gap            | uint256[49]                                     | 202  | 0      | 1568  | BridgedERC20 |
| _balances        | mapping(address => uint256)                     | 251  | 0      | 32    | BridgedERC20 |
| _allowances      | mapping(address => mapping(address => uint256)) | 252  | 0      | 32    | BridgedERC20 |
| _totalSupply     | uint256                                         | 253  | 0      | 32    | BridgedERC20 |
| _name            | string                                          | 254  | 0      | 32    | BridgedERC20 |
| _symbol          | string                                          | 255  | 0      | 32    | BridgedERC20 |
| __gap            | uint256[45]                                     | 256  | 0      | 1440  | BridgedERC20 |
| srcToken         | address                                         | 301  | 0      | 20    | BridgedERC20 |
| __srcDecimals    | uint8                                           | 301  | 20     | 1     | BridgedERC20 |
| srcChainId       | uint256                                         | 302  | 0      | 32    | BridgedERC20 |
| migratingAddress | address                                         | 303  | 0      | 20    | BridgedERC20 |
| migratingInbound | bool                                            | 303  | 20     | 1     | BridgedERC20 |
| __gap            | uint256[47]                                     | 304  | 0      | 1504  | BridgedERC20 |

## BridgedERC20V2
| Name             | Type                                                   | Slot | Offset | Bytes | Contract                                                      |
|------------------|--------------------------------------------------------|------|--------|-------|---------------------------------------------------------------|
| _initialized     | uint8                                                  | 0    | 0      | 1     | BridgedERC20V2 |
| _initializing    | bool                                                   | 0    | 1      | 1     | BridgedERC20V2 |
| __gap            | uint256[50]                                            | 1    | 0      | 1600  | BridgedERC20V2 |
| _owner           | address                                                | 51   | 0      | 20    | BridgedERC20V2 |
| __gap            | uint256[49]                                            | 52   | 0      | 1568  | BridgedERC20V2 |
| _pendingOwner    | address                                                | 101  | 0      | 20    | BridgedERC20V2 |
| __gap            | uint256[49]                                            | 102  | 0      | 1568  | BridgedERC20V2 |
| addressManager   | address                                                | 151  | 0      | 20    | BridgedERC20V2 |
| __gap            | uint256[49]                                            | 152  | 0      | 1568  | BridgedERC20V2 |
| __reentry        | uint8                                                  | 201  | 0      | 1     | BridgedERC20V2 |
| __paused         | uint8                                                  | 201  | 1      | 1     | BridgedERC20V2 |
| __lastUnpausedAt | uint64                                                 | 201  | 2      | 8     | BridgedERC20V2 |
| __gap            | uint256[49]                                            | 202  | 0      | 1568  | BridgedERC20V2 |
| _balances        | mapping(address => uint256)                            | 251  | 0      | 32    | BridgedERC20V2 |
| _allowances      | mapping(address => mapping(address => uint256))        | 252  | 0      | 32    | BridgedERC20V2 |
| _totalSupply     | uint256                                                | 253  | 0      | 32    | BridgedERC20V2 |
| _name            | string                                                 | 254  | 0      | 32    | BridgedERC20V2 |
| _symbol          | string                                                 | 255  | 0      | 32    | BridgedERC20V2 |
| __gap            | uint256[45]                                            | 256  | 0      | 1440  | BridgedERC20V2 |
| srcToken         | address                                                | 301  | 0      | 20    | BridgedERC20V2 |
| __srcDecimals    | uint8                                                  | 301  | 20     | 1     | BridgedERC20V2 |
| srcChainId       | uint256                                                | 302  | 0      | 32    | BridgedERC20V2 |
| migratingAddress | address                                                | 303  | 0      | 20    | BridgedERC20V2 |
| migratingInbound | bool                                                   | 303  | 20     | 1     | BridgedERC20V2 |
| __gap            | uint256[47]                                            | 304  | 0      | 1504  | BridgedERC20V2 |
| _hashedName      | bytes32                                                | 351  | 0      | 32    | BridgedERC20V2 |
| _hashedVersion   | bytes32                                                | 352  | 0      | 32    | BridgedERC20V2 |
| _name            | string                                                 | 353  | 0      | 32    | BridgedERC20V2 |
| _version         | string                                                 | 354  | 0      | 32    | BridgedERC20V2 |
| __gap            | uint256[48]                                            | 355  | 0      | 1536  | BridgedERC20V2 |
| _nonces          | mapping(address => struct CountersUpgradeable.Counter) | 403  | 0      | 32    | BridgedERC20V2 |
| __gap            | uint256[49]                                            | 404  | 0      | 1568  | BridgedERC20V2 |

## BridgedERC721
| Name               | Type                                         | Slot | Offset | Bytes | Contract                                                    |
|--------------------|----------------------------------------------|------|--------|-------|-------------------------------------------------------------|
| _initialized       | uint8                                        | 0    | 0      | 1     | BridgedERC721 |
| _initializing      | bool                                         | 0    | 1      | 1     | BridgedERC721 |
| __gap              | uint256[50]                                  | 1    | 0      | 1600  | BridgedERC721 |
| _owner             | address                                      | 51   | 0      | 20    | BridgedERC721 |
| __gap              | uint256[49]                                  | 52   | 0      | 1568  | BridgedERC721 |
| _pendingOwner      | address                                      | 101  | 0      | 20    | BridgedERC721 |
| __gap              | uint256[49]                                  | 102  | 0      | 1568  | BridgedERC721 |
| addressManager     | address                                      | 151  | 0      | 20    | BridgedERC721 |
| __gap              | uint256[49]                                  | 152  | 0      | 1568  | BridgedERC721 |
| __reentry          | uint8                                        | 201  | 0      | 1     | BridgedERC721 |
| __paused           | uint8                                        | 201  | 1      | 1     | BridgedERC721 |
| __lastUnpausedAt   | uint64                                       | 201  | 2      | 8     | BridgedERC721 |
| __gap              | uint256[49]                                  | 202  | 0      | 1568  | BridgedERC721 |
| __gap              | uint256[50]                                  | 251  | 0      | 1600  | BridgedERC721 |
| _name              | string                                       | 301  | 0      | 32    | BridgedERC721 |
| _symbol            | string                                       | 302  | 0      | 32    | BridgedERC721 |
| _owners            | mapping(uint256 => address)                  | 303  | 0      | 32    | BridgedERC721 |
| _balances          | mapping(address => uint256)                  | 304  | 0      | 32    | BridgedERC721 |
| _tokenApprovals    | mapping(uint256 => address)                  | 305  | 0      | 32    | BridgedERC721 |
| _operatorApprovals | mapping(address => mapping(address => bool)) | 306  | 0      | 32    | BridgedERC721 |
| __gap              | uint256[44]                                  | 307  | 0      | 1408  | BridgedERC721 |
| srcToken           | address                                      | 351  | 0      | 20    | BridgedERC721 |
| srcChainId         | uint256                                      | 352  | 0      | 32    | BridgedERC721 |
| __gap              | uint256[48]                                  | 353  | 0      | 1536  | BridgedERC721 |

## BridgedERC1155
| Name               | Type                                            | Slot | Offset | Bytes | Contract                                                      |
|--------------------|-------------------------------------------------|------|--------|-------|---------------------------------------------------------------|
| _initialized       | uint8                                           | 0    | 0      | 1     | BridgedERC1155 |
| _initializing      | bool                                            | 0    | 1      | 1     | BridgedERC1155 |
| __gap              | uint256[50]                                     | 1    | 0      | 1600  | BridgedERC1155 |
| _owner             | address                                         | 51   | 0      | 20    | BridgedERC1155 |
| __gap              | uint256[49]                                     | 52   | 0      | 1568  | BridgedERC1155 |
| _pendingOwner      | address                                         | 101  | 0      | 20    | BridgedERC1155 |
| __gap              | uint256[49]                                     | 102  | 0      | 1568  | BridgedERC1155 |
| addressManager     | address                                         | 151  | 0      | 20    | BridgedERC1155 |
| __gap              | uint256[49]                                     | 152  | 0      | 1568  | BridgedERC1155 |
| __reentry          | uint8                                           | 201  | 0      | 1     | BridgedERC1155 |
| __paused           | uint8                                           | 201  | 1      | 1     | BridgedERC1155 |
| __lastUnpausedAt   | uint64                                          | 201  | 2      | 8     | BridgedERC1155 |
| __gap              | uint256[49]                                     | 202  | 0      | 1568  | BridgedERC1155 |
| __gap              | uint256[50]                                     | 251  | 0      | 1600  | BridgedERC1155 |
| _balances          | mapping(uint256 => mapping(address => uint256)) | 301  | 0      | 32    | BridgedERC1155 |
| _operatorApprovals | mapping(address => mapping(address => bool))    | 302  | 0      | 32    | BridgedERC1155 |
| _uri               | string                                          | 303  | 0      | 32    | BridgedERC1155 |
| __gap              | uint256[47]                                     | 304  | 0      | 1504  | BridgedERC1155 |
| srcToken           | address                                         | 351  | 0      | 20    | BridgedERC1155 |
| srcChainId         | uint256                                         | 352  | 0      | 32    | BridgedERC1155 |
| symbol             | string                                          | 353  | 0      | 32    | BridgedERC1155 |
| name               | string                                          | 354  | 0      | 32    | BridgedERC1155 |
| __gap              | uint256[46]                                     | 355  | 0      | 1472  | BridgedERC1155 |

## Bridge
| Name             | Type                                    | Slot | Offset | Bytes | Contract                                  |
|------------------|-----------------------------------------|------|--------|-------|-------------------------------------------|
| _initialized     | uint8                                   | 0    | 0      | 1     | Bridge |
| _initializing    | bool                                    | 0    | 1      | 1     | Bridge |
| __gap            | uint256[50]                             | 1    | 0      | 1600  | Bridge |
| _owner           | address                                 | 51   | 0      | 20    | Bridge |
| __gap            | uint256[49]                             | 52   | 0      | 1568  | Bridge |
| _pendingOwner    | address                                 | 101  | 0      | 20    | Bridge |
| __gap            | uint256[49]                             | 102  | 0      | 1568  | Bridge |
| addressManager   | address                                 | 151  | 0      | 20    | Bridge |
| __gap            | uint256[49]                             | 152  | 0      | 1568  | Bridge |
| __reentry        | uint8                                   | 201  | 0      | 1     | Bridge |
| __paused         | uint8                                   | 201  | 1      | 1     | Bridge |
| __lastUnpausedAt | uint64                                  | 201  | 2      | 8     | Bridge |
| __gap            | uint256[49]                             | 202  | 0      | 1568  | Bridge |
| __reserved1      | uint64                                  | 251  | 0      | 8     | Bridge |
| nextMessageId    | uint64                                  | 251  | 8      | 8     | Bridge |
| messageStatus    | mapping(bytes32 => enum IBridge.Status) | 252  | 0      | 32    | Bridge |
| __ctx            | struct IBridge.Context                  | 253  | 0      | 64    | Bridge |
| __reserved2      | uint256                                 | 255  | 0      | 32    | Bridge |
| __reserved3      | uint256                                 | 256  | 0      | 32    | Bridge |
| __gap            | uint256[44]                             | 257  | 0      | 1408  | Bridge |

## QuotaManager
| Name             | Type                                          | Slot | Offset | Bytes | Contract                                              |
|------------------|-----------------------------------------------|------|--------|-------|-------------------------------------------------------|
| _initialized     | uint8                                         | 0    | 0      | 1     | QuotaManager |
| _initializing    | bool                                          | 0    | 1      | 1     | QuotaManager |
| __gap            | uint256[50]                                   | 1    | 0      | 1600  | QuotaManager |
| _owner           | address                                       | 51   | 0      | 20    | QuotaManager |
| __gap            | uint256[49]                                   | 52   | 0      | 1568  | QuotaManager |
| _pendingOwner    | address                                       | 101  | 0      | 20    | QuotaManager |
| __gap            | uint256[49]                                   | 102  | 0      | 1568  | QuotaManager |
| addressManager   | address                                       | 151  | 0      | 20    | QuotaManager |
| __gap            | uint256[49]                                   | 152  | 0      | 1568  | QuotaManager |
| __reentry        | uint8                                         | 201  | 0      | 1     | QuotaManager |
| __paused         | uint8                                         | 201  | 1      | 1     | QuotaManager |
| __lastUnpausedAt | uint64                                        | 201  | 2      | 8     | QuotaManager |
| __gap            | uint256[49]                                   | 202  | 0      | 1568  | QuotaManager |
| tokenQuota       | mapping(address => struct QuotaManager.Quota) | 251  | 0      | 32    | QuotaManager |
| quotaPeriod      | uint24                                        | 252  | 0      | 3     | QuotaManager |
| __gap            | uint256[48]                                   | 253  | 0      | 1536  | QuotaManager |

## AddressManager
| Name             | Type                                            | Slot | Offset | Bytes | Contract                                                  |
|------------------|-------------------------------------------------|------|--------|-------|-----------------------------------------------------------|
| _initialized     | uint8                                           | 0    | 0      | 1     | AddressManager |
| _initializing    | bool                                            | 0    | 1      | 1     | AddressManager |
| __gap            | uint256[50]                                     | 1    | 0      | 1600  | AddressManager |
| _owner           | address                                         | 51   | 0      | 20    | AddressManager |
| __gap            | uint256[49]                                     | 52   | 0      | 1568  | AddressManager |
| _pendingOwner    | address                                         | 101  | 0      | 20    | AddressManager |
| __gap            | uint256[49]                                     | 102  | 0      | 1568  | AddressManager |
| addressManager   | address                                         | 151  | 0      | 20    | AddressManager |
| __gap            | uint256[49]                                     | 152  | 0      | 1568  | AddressManager |
| __reentry        | uint8                                           | 201  | 0      | 1     | AddressManager |
| __paused         | uint8                                           | 201  | 1      | 1     | AddressManager |
| __lastUnpausedAt | uint64                                          | 201  | 2      | 8     | AddressManager |
| __gap            | uint256[49]                                     | 202  | 0      | 1568  | AddressManager |
| __addresses      | mapping(uint256 => mapping(bytes32 => address)) | 251  | 0      | 32    | AddressManager |
| __gap            | uint256[49]                                     | 252  | 0      | 1568  | AddressManager |

## AddressResolver
| Name           | Type        | Slot | Offset | Bytes | Contract                                                    |
|----------------|-------------|------|--------|-------|-------------------------------------------------------------|
| _initialized   | uint8       | 0    | 0      | 1     | AddressResolver |
| _initializing  | bool        | 0    | 1      | 1     | AddressResolver |
| addressManager | address     | 0    | 2      | 20    | AddressResolver |
| __gap          | uint256[49] | 1    | 0      | 1568  | AddressResolver |

## EssentialContract
| Name             | Type        | Slot | Offset | Bytes | Contract                                                        |
|------------------|-------------|------|--------|-------|-----------------------------------------------------------------|
| _initialized     | uint8       | 0    | 0      | 1     | EssentialContract |
| _initializing    | bool        | 0    | 1      | 1     | EssentialContract |
| __gap            | uint256[50] | 1    | 0      | 1600  | EssentialContract |
| _owner           | address     | 51   | 0      | 20    | EssentialContract |
| __gap            | uint256[49] | 52   | 0      | 1568  | EssentialContract |
| _pendingOwner    | address     | 101  | 0      | 20    | EssentialContract |
| __gap            | uint256[49] | 102  | 0      | 1568  | EssentialContract |
| addressManager   | address     | 151  | 0      | 20    | EssentialContract |
| __gap            | uint256[49] | 152  | 0      | 1568  | EssentialContract |
| __reentry        | uint8       | 201  | 0      | 1     | EssentialContract |
| __paused         | uint8       | 201  | 1      | 1     | EssentialContract |
| __lastUnpausedAt | uint64      | 201  | 2      | 8     | EssentialContract |
| __gap            | uint256[49] | 202  | 0      | 1568  | EssentialContract |

## SignalService
| Name             | Type                                          | Slot | Offset | Bytes | Contract                                                |
|------------------|-----------------------------------------------|------|--------|-------|---------------------------------------------------------|
| _initialized     | uint8                                         | 0    | 0      | 1     | SignalService |
| _initializing    | bool                                          | 0    | 1      | 1     | SignalService |
| __gap            | uint256[50]                                   | 1    | 0      | 1600  | SignalService |
| _owner           | address                                       | 51   | 0      | 20    | SignalService |
| __gap            | uint256[49]                                   | 52   | 0      | 1568  | SignalService |
| _pendingOwner    | address                                       | 101  | 0      | 20    | SignalService |
| __gap            | uint256[49]                                   | 102  | 0      | 1568  | SignalService |
| addressManager   | address                                       | 151  | 0      | 20    | SignalService |
| __gap            | uint256[49]                                   | 152  | 0      | 1568  | SignalService |
| __reentry        | uint8                                         | 201  | 0      | 1     | SignalService |
| __paused         | uint8                                         | 201  | 1      | 1     | SignalService |
| __lastUnpausedAt | uint64                                        | 201  | 2      | 8     | SignalService |
| __gap            | uint256[49]                                   | 202  | 0      | 1568  | SignalService |
| topBlockId       | mapping(uint64 => mapping(bytes32 => uint64)) | 251  | 0      | 32    | SignalService |
| isAuthorized     | mapping(address => bool)                      | 252  | 0      | 32    | SignalService |
| __gap            | uint256[48]                                   | 253  | 0      | 1536  | SignalService |

## TaikoToken
| Name                                                | Type                                                          | Slot | Offset | Bytes | Contract                                         |
|-----------------------------------------------------|---------------------------------------------------------------|------|--------|-------|--------------------------------------------------|
| _initialized                                        | uint8                                                         | 0    | 0      | 1     | TaikoToken |
| _initializing                                       | bool                                                          | 0    | 1      | 1     | TaikoToken |
| __gap                                               | uint256[50]                                                   | 1    | 0      | 1600  | TaikoToken |
| _owner                                              | address                                                       | 51   | 0      | 20    | TaikoToken |
| __gap                                               | uint256[49]                                                   | 52   | 0      | 1568  | TaikoToken |
| _pendingOwner                                       | address                                                       | 101  | 0      | 20    | TaikoToken |
| __gap                                               | uint256[49]                                                   | 102  | 0      | 1568  | TaikoToken |
| addressManager                                      | address                                                       | 151  | 0      | 20    | TaikoToken |
| __gap                                               | uint256[49]                                                   | 152  | 0      | 1568  | TaikoToken |
| __reentry                                           | uint8                                                         | 201  | 0      | 1     | TaikoToken |
| __paused                                            | uint8                                                         | 201  | 1      | 1     | TaikoToken |
| __lastUnpausedAt                                    | uint64                                                        | 201  | 2      | 8     | TaikoToken |
| __gap                                               | uint256[49]                                                   | 202  | 0      | 1568  | TaikoToken |
| __slots_previously_used_by_ERC20SnapshotUpgradeable | uint256[50]                                                   | 251  | 0      | 1600  | TaikoToken |
| _balances                                           | mapping(address => uint256)                                   | 301  | 0      | 32    | TaikoToken |
| _allowances                                         | mapping(address => mapping(address => uint256))               | 302  | 0      | 32    | TaikoToken |
| _totalSupply                                        | uint256                                                       | 303  | 0      | 32    | TaikoToken |
| _name                                               | string                                                        | 304  | 0      | 32    | TaikoToken |
| _symbol                                             | string                                                        | 305  | 0      | 32    | TaikoToken |
| __gap                                               | uint256[45]                                                   | 306  | 0      | 1440  | TaikoToken |
| _hashedName                                         | bytes32                                                       | 351  | 0      | 32    | TaikoToken |
| _hashedVersion                                      | bytes32                                                       | 352  | 0      | 32    | TaikoToken |
| _name                                               | string                                                        | 353  | 0      | 32    | TaikoToken |
| _version                                            | string                                                        | 354  | 0      | 32    | TaikoToken |
| __gap                                               | uint256[48]                                                   | 355  | 0      | 1536  | TaikoToken |
| _nonces                                             | mapping(address => struct CountersUpgradeable.Counter)        | 403  | 0      | 32    | TaikoToken |
| _PERMIT_TYPEHASH_DEPRECATED_SLOT                    | bytes32                                                       | 404  | 0      | 32    | TaikoToken |
| __gap                                               | uint256[49]                                                   | 405  | 0      | 1568  | TaikoToken |
| _delegates                                          | mapping(address => address)                                   | 454  | 0      | 32    | TaikoToken |
| _checkpoints                                        | mapping(address => struct ERC20VotesUpgradeable.Checkpoint[]) | 455  | 0      | 32    | TaikoToken |
| _totalSupplyCheckpoints                             | struct ERC20VotesUpgradeable.Checkpoint[]                     | 456  | 0      | 32    | TaikoToken |
| __gap                                               | uint256[47]                                                   | 457  | 0      | 1504  | TaikoToken |
| __gap                                               | uint256[50]                                                   | 504  | 0      | 1600  | TaikoToken |

## ComposeVerifier
| Name             | Type        | Slot | Offset | Bytes | Contract                                                               |
|------------------|-------------|------|--------|-------|------------------------------------------------------------------------|
| _initialized     | uint8       | 0    | 0      | 1     | ComposeVerifier |
| _initializing    | bool        | 0    | 1      | 1     | ComposeVerifier |
| __gap            | uint256[50] | 1    | 0      | 1600  | ComposeVerifier |
| _owner           | address     | 51   | 0      | 20    | ComposeVerifier |
| __gap            | uint256[49] | 52   | 0      | 1568  | ComposeVerifier |
| _pendingOwner    | address     | 101  | 0      | 20    | ComposeVerifier |
| __gap            | uint256[49] | 102  | 0      | 1568  | ComposeVerifier |
| addressManager   | address     | 151  | 0      | 20    | ComposeVerifier |
| __gap            | uint256[49] | 152  | 0      | 1568  | ComposeVerifier |
| __reentry        | uint8       | 201  | 0      | 1     | ComposeVerifier |
| __paused         | uint8       | 201  | 1      | 1     | ComposeVerifier |
| __lastUnpausedAt | uint64      | 201  | 2      | 8     | ComposeVerifier |
| __gap            | uint256[49] | 202  | 0      | 1568  | ComposeVerifier |
| __gap            | uint256[50] | 251  | 0      | 1600  | ComposeVerifier |

## TeeAnyVerifier
| Name             | Type        | Slot | Offset | Bytes | Contract                                                             |
|------------------|-------------|------|--------|-------|----------------------------------------------------------------------|
| _initialized     | uint8       | 0    | 0      | 1     | TeeAnyVerifier |
| _initializing    | bool        | 0    | 1      | 1     | TeeAnyVerifier |
| __gap            | uint256[50] | 1    | 0      | 1600  | TeeAnyVerifier |
| _owner           | address     | 51   | 0      | 20    | TeeAnyVerifier |
| __gap            | uint256[49] | 52   | 0      | 1568  | TeeAnyVerifier |
| _pendingOwner    | address     | 101  | 0      | 20    | TeeAnyVerifier |
| __gap            | uint256[49] | 102  | 0      | 1568  | TeeAnyVerifier |
| addressManager   | address     | 151  | 0      | 20    | TeeAnyVerifier |
| __gap            | uint256[49] | 152  | 0      | 1568  | TeeAnyVerifier |
| __reentry        | uint8       | 201  | 0      | 1     | TeeAnyVerifier |
| __paused         | uint8       | 201  | 1      | 1     | TeeAnyVerifier |
| __lastUnpausedAt | uint64      | 201  | 2      | 8     | TeeAnyVerifier |
| __gap            | uint256[49] | 202  | 0      | 1568  | TeeAnyVerifier |
| __gap            | uint256[50] | 251  | 0      | 1600  | TeeAnyVerifier |
| __gap            | uint256[50] | 301  | 0      | 1600  | TeeAnyVerifier |

## ZkAndTeeVerifier
| Name             | Type        | Slot | Offset | Bytes | Contract                                                                 |
|------------------|-------------|------|--------|-------|--------------------------------------------------------------------------|
| _initialized     | uint8       | 0    | 0      | 1     | ZkAndTeeVerifier |
| _initializing    | bool        | 0    | 1      | 1     | ZkAndTeeVerifier |
| __gap            | uint256[50] | 1    | 0      | 1600  | ZkAndTeeVerifier |
| _owner           | address     | 51   | 0      | 20    | ZkAndTeeVerifier |
| __gap            | uint256[49] | 52   | 0      | 1568  | ZkAndTeeVerifier |
| _pendingOwner    | address     | 101  | 0      | 20    | ZkAndTeeVerifier |
| __gap            | uint256[49] | 102  | 0      | 1568  | ZkAndTeeVerifier |
| addressManager   | address     | 151  | 0      | 20    | ZkAndTeeVerifier |
| __gap            | uint256[49] | 152  | 0      | 1568  | ZkAndTeeVerifier |
| __reentry        | uint8       | 201  | 0      | 1     | ZkAndTeeVerifier |
| __paused         | uint8       | 201  | 1      | 1     | ZkAndTeeVerifier |
| __lastUnpausedAt | uint64      | 201  | 2      | 8     | ZkAndTeeVerifier |
| __gap            | uint256[49] | 202  | 0      | 1568  | ZkAndTeeVerifier |
| __gap            | uint256[50] | 251  | 0      | 1600  | ZkAndTeeVerifier |
| __gap            | uint256[50] | 301  | 0      | 1600  | ZkAndTeeVerifier |

## ZkAnyVerifier
| Name             | Type        | Slot | Offset | Bytes | Contract                                                           |
|------------------|-------------|------|--------|-------|--------------------------------------------------------------------|
| _initialized     | uint8       | 0    | 0      | 1     | ZkAnyVerifier |
| _initializing    | bool        | 0    | 1      | 1     | ZkAnyVerifier |
| __gap            | uint256[50] | 1    | 0      | 1600  | ZkAnyVerifier |
| _owner           | address     | 51   | 0      | 20    | ZkAnyVerifier |
| __gap            | uint256[49] | 52   | 0      | 1568  | ZkAnyVerifier |
| _pendingOwner    | address     | 101  | 0      | 20    | ZkAnyVerifier |
| __gap            | uint256[49] | 102  | 0      | 1568  | ZkAnyVerifier |
| addressManager   | address     | 151  | 0      | 20    | ZkAnyVerifier |
| __gap            | uint256[49] | 152  | 0      | 1568  | ZkAnyVerifier |
| __reentry        | uint8       | 201  | 0      | 1     | ZkAnyVerifier |
| __paused         | uint8       | 201  | 1      | 1     | ZkAnyVerifier |
| __lastUnpausedAt | uint64      | 201  | 2      | 8     | ZkAnyVerifier |
| __gap            | uint256[49] | 202  | 0      | 1568  | ZkAnyVerifier |
| __gap            | uint256[50] | 251  | 0      | 1600  | ZkAnyVerifier |
| __gap            | uint256[50] | 301  | 0      | 1600  | ZkAnyVerifier |

## Risc0Verifier
| Name             | Type                     | Slot | Offset | Bytes | Contract                                                   |
|------------------|--------------------------|------|--------|-------|------------------------------------------------------------|
| _initialized     | uint8                    | 0    | 0      | 1     | Risc0Verifier |
| _initializing    | bool                     | 0    | 1      | 1     | Risc0Verifier |
| __gap            | uint256[50]              | 1    | 0      | 1600  | Risc0Verifier |
| _owner           | address                  | 51   | 0      | 20    | Risc0Verifier |
| __gap            | uint256[49]              | 52   | 0      | 1568  | Risc0Verifier |
| _pendingOwner    | address                  | 101  | 0      | 20    | Risc0Verifier |
| __gap            | uint256[49]              | 102  | 0      | 1568  | Risc0Verifier |
| addressManager   | address                  | 151  | 0      | 20    | Risc0Verifier |
| __gap            | uint256[49]              | 152  | 0      | 1568  | Risc0Verifier |
| __reentry        | uint8                    | 201  | 0      | 1     | Risc0Verifier |
| __paused         | uint8                    | 201  | 1      | 1     | Risc0Verifier |
| __lastUnpausedAt | uint64                   | 201  | 2      | 8     | Risc0Verifier |
| __gap            | uint256[49]              | 202  | 0      | 1568  | Risc0Verifier |
| isImageTrusted   | mapping(bytes32 => bool) | 251  | 0      | 32    | Risc0Verifier |
| __gap            | uint256[49]              | 252  | 0      | 1568  | Risc0Verifier |

## SP1Verifier
| Name             | Type                     | Slot | Offset | Bytes | Contract                                               |
|------------------|--------------------------|------|--------|-------|--------------------------------------------------------|
| _initialized     | uint8                    | 0    | 0      | 1     | SP1Verifier |
| _initializing    | bool                     | 0    | 1      | 1     | SP1Verifier |
| __gap            | uint256[50]              | 1    | 0      | 1600  | SP1Verifier |
| _owner           | address                  | 51   | 0      | 20    | SP1Verifier |
| __gap            | uint256[49]              | 52   | 0      | 1568  | SP1Verifier |
| _pendingOwner    | address                  | 101  | 0      | 20    | SP1Verifier |
| __gap            | uint256[49]              | 102  | 0      | 1568  | SP1Verifier |
| addressManager   | address                  | 151  | 0      | 20    | SP1Verifier |
| __gap            | uint256[49]              | 152  | 0      | 1568  | SP1Verifier |
| __reentry        | uint8                    | 201  | 0      | 1     | SP1Verifier |
| __paused         | uint8                    | 201  | 1      | 1     | SP1Verifier |
| __lastUnpausedAt | uint64                   | 201  | 2      | 8     | SP1Verifier |
| __gap            | uint256[49]              | 202  | 0      | 1568  | SP1Verifier |
| isProgramTrusted | mapping(bytes32 => bool) | 251  | 0      | 32    | SP1Verifier |
| __gap            | uint256[49]              | 252  | 0      | 1568  | SP1Verifier |

## SgxVerifier
| Name              | Type                                            | Slot | Offset | Bytes | Contract                                               |
|-------------------|-------------------------------------------------|------|--------|-------|--------------------------------------------------------|
| _initialized      | uint8                                           | 0    | 0      | 1     | SgxVerifier |
| _initializing     | bool                                            | 0    | 1      | 1     | SgxVerifier |
| __gap             | uint256[50]                                     | 1    | 0      | 1600  | SgxVerifier |
| _owner            | address                                         | 51   | 0      | 20    | SgxVerifier |
| __gap             | uint256[49]                                     | 52   | 0      | 1568  | SgxVerifier |
| _pendingOwner     | address                                         | 101  | 0      | 20    | SgxVerifier |
| __gap             | uint256[49]                                     | 102  | 0      | 1568  | SgxVerifier |
| addressManager    | address                                         | 151  | 0      | 20    | SgxVerifier |
| __gap             | uint256[49]                                     | 152  | 0      | 1568  | SgxVerifier |
| __reentry         | uint8                                           | 201  | 0      | 1     | SgxVerifier |
| __paused          | uint8                                           | 201  | 1      | 1     | SgxVerifier |
| __lastUnpausedAt  | uint64                                          | 201  | 2      | 8     | SgxVerifier |
| __gap             | uint256[49]                                     | 202  | 0      | 1568  | SgxVerifier |
| nextInstanceId    | uint256                                         | 251  | 0      | 32    | SgxVerifier |
| instances         | mapping(uint256 => struct SgxVerifier.Instance) | 252  | 0      | 32    | SgxVerifier |
| addressRegistered | mapping(address => bool)                        | 253  | 0      | 32    | SgxVerifier |
| __gap             | uint256[47]                                     | 254  | 0      | 1504  | SgxVerifier |

## AutomataDcapV3Attestation
| Name                    | Type                                            | Slot | Offset | Bytes | Contract                                                                                      |
|-------------------------|-------------------------------------------------|------|--------|-------|-----------------------------------------------------------------------------------------------|
| _initialized            | uint8                                           | 0    | 0      | 1     | AutomataDcapV3Attestation |
| _initializing           | bool                                            | 0    | 1      | 1     | AutomataDcapV3Attestation |
| __gap                   | uint256[50]                                     | 1    | 0      | 1600  | AutomataDcapV3Attestation |
| _owner                  | address                                         | 51   | 0      | 20    | AutomataDcapV3Attestation |
| __gap                   | uint256[49]                                     | 52   | 0      | 1568  | AutomataDcapV3Attestation |
| _pendingOwner           | address                                         | 101  | 0      | 20    | AutomataDcapV3Attestation |
| __gap                   | uint256[49]                                     | 102  | 0      | 1568  | AutomataDcapV3Attestation |
| addressManager          | address                                         | 151  | 0      | 20    | AutomataDcapV3Attestation |
| __gap                   | uint256[49]                                     | 152  | 0      | 1568  | AutomataDcapV3Attestation |
| __reentry               | uint8                                           | 201  | 0      | 1     | AutomataDcapV3Attestation |
| __paused                | uint8                                           | 201  | 1      | 1     | AutomataDcapV3Attestation |
| __lastUnpausedAt        | uint64                                          | 201  | 2      | 8     | AutomataDcapV3Attestation |
| __gap                   | uint256[49]                                     | 202  | 0      | 1568  | AutomataDcapV3Attestation |
| sigVerifyLib            | contract ISigVerifyLib                          | 251  | 0      | 20    | AutomataDcapV3Attestation |
| pemCertLib              | contract IPEMCertChainLib                       | 252  | 0      | 20    | AutomataDcapV3Attestation |
| checkLocalEnclaveReport | bool                                            | 252  | 20     | 1     | AutomataDcapV3Attestation |
| trustedUserMrEnclave    | mapping(bytes32 => bool)                        | 253  | 0      | 32    | AutomataDcapV3Attestation |
| trustedUserMrSigner     | mapping(bytes32 => bool)                        | 254  | 0      | 32    | AutomataDcapV3Attestation |
| serialNumIsRevoked      | mapping(uint256 => mapping(bytes => bool))      | 255  | 0      | 32    | AutomataDcapV3Attestation |
| tcbInfo                 | mapping(string => struct TCBInfoStruct.TCBInfo) | 256  | 0      | 32    | AutomataDcapV3Attestation |
| qeIdentity              | struct EnclaveIdStruct.EnclaveId                | 257  | 0      | 128   | AutomataDcapV3Attestation |
| __gap                   | uint256[39]                                     | 261  | 0      | 1248  | AutomataDcapV3Attestation |

## TaikoL1
| Name             | Type                   | Slot | Offset | Bytes | Contract                                   |
|------------------|------------------------|------|--------|-------|--------------------------------------------|
| _initialized     | uint8                  | 0    | 0      | 1     | TaikoL1 |
| _initializing    | bool                   | 0    | 1      | 1     | TaikoL1 |
| __gap            | uint256[50]            | 1    | 0      | 1600  | TaikoL1 |
| _owner           | address                | 51   | 0      | 20    | TaikoL1 |
| __gap            | uint256[49]            | 52   | 0      | 1568  | TaikoL1 |
| _pendingOwner    | address                | 101  | 0      | 20    | TaikoL1 |
| __gap            | uint256[49]            | 102  | 0      | 1568  | TaikoL1 |
| addressManager   | address                | 151  | 0      | 20    | TaikoL1 |
| __gap            | uint256[49]            | 152  | 0      | 1568  | TaikoL1 |
| __reentry        | uint8                  | 201  | 0      | 1     | TaikoL1 |
| __paused         | uint8                  | 201  | 1      | 1     | TaikoL1 |
| __lastUnpausedAt | uint64                 | 201  | 2      | 8     | TaikoL1 |
| __gap            | uint256[49]            | 202  | 0      | 1568  | TaikoL1 |
| state            | struct TaikoData.State | 251  | 0      | 1600  | TaikoL1 |
| __gap            | uint256[50]            | 301  | 0      | 1600  | TaikoL1 |

## TierProviderV2
| Name | Type | Slot | Offset | Bytes | Contract |
|------|------|------|--------|-------|----------|

## HeklaTaikoL1
| Name             | Type                   | Slot | Offset | Bytes | Contract                                             |
|------------------|------------------------|------|--------|-------|------------------------------------------------------|
| _initialized     | uint8                  | 0    | 0      | 1     | HeklaTaikoL1 |
| _initializing    | bool                   | 0    | 1      | 1     | HeklaTaikoL1 |
| __gap            | uint256[50]            | 1    | 0      | 1600  | HeklaTaikoL1 |
| _owner           | address                | 51   | 0      | 20    | HeklaTaikoL1 |
| __gap            | uint256[49]            | 52   | 0      | 1568  | HeklaTaikoL1 |
| _pendingOwner    | address                | 101  | 0      | 20    | HeklaTaikoL1 |
| __gap            | uint256[49]            | 102  | 0      | 1568  | HeklaTaikoL1 |
| addressManager   | address                | 151  | 0      | 20    | HeklaTaikoL1 |
| __gap            | uint256[49]            | 152  | 0      | 1568  | HeklaTaikoL1 |
| __reentry        | uint8                  | 201  | 0      | 1     | HeklaTaikoL1 |
| __paused         | uint8                  | 201  | 1      | 1     | HeklaTaikoL1 |
| __lastUnpausedAt | uint64                 | 201  | 2      | 8     | HeklaTaikoL1 |
| __gap            | uint256[49]            | 202  | 0      | 1568  | HeklaTaikoL1 |
| state            | struct TaikoData.State | 251  | 0      | 1600  | HeklaTaikoL1 |
| __gap            | uint256[50]            | 301  | 0      | 1600  | HeklaTaikoL1 |

## HeklaTierProvider
| Name | Type | Slot | Offset | Bytes | Contract |
|------|------|------|--------|-------|----------|

## MainnetBridge
| Name             | Type                                    | Slot | Offset | Bytes | Contract                                                             |
|------------------|-----------------------------------------|------|--------|-------|----------------------------------------------------------------------|
| _initialized     | uint8                                   | 0    | 0      | 1     | MainnetBridge |
| _initializing    | bool                                    | 0    | 1      | 1     | MainnetBridge |
| __gap            | uint256[50]                             | 1    | 0      | 1600  | MainnetBridge |
| _owner           | address                                 | 51   | 0      | 20    | MainnetBridge |
| __gap            | uint256[49]                             | 52   | 0      | 1568  | MainnetBridge |
| _pendingOwner    | address                                 | 101  | 0      | 20    | MainnetBridge |
| __gap            | uint256[49]                             | 102  | 0      | 1568  | MainnetBridge |
| addressManager   | address                                 | 151  | 0      | 20    | MainnetBridge |
| __gap            | uint256[49]                             | 152  | 0      | 1568  | MainnetBridge |
| __reentry        | uint8                                   | 201  | 0      | 1     | MainnetBridge |
| __paused         | uint8                                   | 201  | 1      | 1     | MainnetBridge |
| __lastUnpausedAt | uint64                                  | 201  | 2      | 8     | MainnetBridge |
| __gap            | uint256[49]                             | 202  | 0      | 1568  | MainnetBridge |
| __reserved1      | uint64                                  | 251  | 0      | 8     | MainnetBridge |
| nextMessageId    | uint64                                  | 251  | 8      | 8     | MainnetBridge |
| messageStatus    | mapping(bytes32 => enum IBridge.Status) | 252  | 0      | 32    | MainnetBridge |
| __ctx            | struct IBridge.Context                  | 253  | 0      | 64    | MainnetBridge |
| __reserved2      | uint256                                 | 255  | 0      | 32    | MainnetBridge |
| __reserved3      | uint256                                 | 256  | 0      | 32    | MainnetBridge |
| __gap            | uint256[44]                             | 257  | 0      | 1408  | MainnetBridge |

## MainnetSignalService
| Name             | Type                                          | Slot | Offset | Bytes | Contract                                                                           |
|------------------|-----------------------------------------------|------|--------|-------|------------------------------------------------------------------------------------|
| _initialized     | uint8                                         | 0    | 0      | 1     | MainnetSignalService |
| _initializing    | bool                                          | 0    | 1      | 1     | MainnetSignalService |
| __gap            | uint256[50]                                   | 1    | 0      | 1600  | MainnetSignalService |
| _owner           | address                                       | 51   | 0      | 20    | MainnetSignalService |
| __gap            | uint256[49]                                   | 52   | 0      | 1568  | MainnetSignalService |
| _pendingOwner    | address                                       | 101  | 0      | 20    | MainnetSignalService |
| __gap            | uint256[49]                                   | 102  | 0      | 1568  | MainnetSignalService |
| addressManager   | address                                       | 151  | 0      | 20    | MainnetSignalService |
| __gap            | uint256[49]                                   | 152  | 0      | 1568  | MainnetSignalService |
| __reentry        | uint8                                         | 201  | 0      | 1     | MainnetSignalService |
| __paused         | uint8                                         | 201  | 1      | 1     | MainnetSignalService |
| __lastUnpausedAt | uint64                                        | 201  | 2      | 8     | MainnetSignalService |
| __gap            | uint256[49]                                   | 202  | 0      | 1568  | MainnetSignalService |
| topBlockId       | mapping(uint64 => mapping(bytes32 => uint64)) | 251  | 0      | 32    | MainnetSignalService |
| isAuthorized     | mapping(address => bool)                      | 252  | 0      | 32    | MainnetSignalService |
| __gap            | uint256[48]                                   | 253  | 0      | 1536  | MainnetSignalService |

## MainnetERC20Vault
| Name               | Type                                                 | Slot | Offset | Bytes | Contract                                                                     |
|--------------------|------------------------------------------------------|------|--------|-------|------------------------------------------------------------------------------|
| _initialized       | uint8                                                | 0    | 0      | 1     | MainnetERC20Vault |
| _initializing      | bool                                                 | 0    | 1      | 1     | MainnetERC20Vault |
| __gap              | uint256[50]                                          | 1    | 0      | 1600  | MainnetERC20Vault |
| _owner             | address                                              | 51   | 0      | 20    | MainnetERC20Vault |
| __gap              | uint256[49]                                          | 52   | 0      | 1568  | MainnetERC20Vault |
| _pendingOwner      | address                                              | 101  | 0      | 20    | MainnetERC20Vault |
| __gap              | uint256[49]                                          | 102  | 0      | 1568  | MainnetERC20Vault |
| addressManager     | address                                              | 151  | 0      | 20    | MainnetERC20Vault |
| __gap              | uint256[49]                                          | 152  | 0      | 1568  | MainnetERC20Vault |
| __reentry          | uint8                                                | 201  | 0      | 1     | MainnetERC20Vault |
| __paused           | uint8                                                | 201  | 1      | 1     | MainnetERC20Vault |
| __lastUnpausedAt   | uint64                                               | 201  | 2      | 8     | MainnetERC20Vault |
| __gap              | uint256[49]                                          | 202  | 0      | 1568  | MainnetERC20Vault |
| __gap              | uint256[50]                                          | 251  | 0      | 1600  | MainnetERC20Vault |
| bridgedToCanonical | mapping(address => struct ERC20Vault.CanonicalERC20) | 301  | 0      | 32    | MainnetERC20Vault |
| canonicalToBridged | mapping(uint256 => mapping(address => address))      | 302  | 0      | 32    | MainnetERC20Vault |
| btokenDenylist     | mapping(address => bool)                             | 303  | 0      | 32    | MainnetERC20Vault |
| lastMigrationStart | mapping(uint256 => mapping(address => uint256))      | 304  | 0      | 32    | MainnetERC20Vault |
| __gap              | uint256[46]                                          | 305  | 0      | 1472  | MainnetERC20Vault |

## MainnetERC1155Vault
| Name               | Type                                                 | Slot | Offset | Bytes | Contract                                                                         |
|--------------------|------------------------------------------------------|------|--------|-------|----------------------------------------------------------------------------------|
| _initialized       | uint8                                                | 0    | 0      | 1     | MainnetERC1155Vault |
| _initializing      | bool                                                 | 0    | 1      | 1     | MainnetERC1155Vault |
| __gap              | uint256[50]                                          | 1    | 0      | 1600  | MainnetERC1155Vault |
| _owner             | address                                              | 51   | 0      | 20    | MainnetERC1155Vault |
| __gap              | uint256[49]                                          | 52   | 0      | 1568  | MainnetERC1155Vault |
| _pendingOwner      | address                                              | 101  | 0      | 20    | MainnetERC1155Vault |
| __gap              | uint256[49]                                          | 102  | 0      | 1568  | MainnetERC1155Vault |
| addressManager     | address                                              | 151  | 0      | 20    | MainnetERC1155Vault |
| __gap              | uint256[49]                                          | 152  | 0      | 1568  | MainnetERC1155Vault |
| __reentry          | uint8                                                | 201  | 0      | 1     | MainnetERC1155Vault |
| __paused           | uint8                                                | 201  | 1      | 1     | MainnetERC1155Vault |
| __lastUnpausedAt   | uint64                                               | 201  | 2      | 8     | MainnetERC1155Vault |
| __gap              | uint256[49]                                          | 202  | 0      | 1568  | MainnetERC1155Vault |
| __gap              | uint256[50]                                          | 251  | 0      | 1600  | MainnetERC1155Vault |
| bridgedToCanonical | mapping(address => struct BaseNFTVault.CanonicalNFT) | 301  | 0      | 32    | MainnetERC1155Vault |
| canonicalToBridged | mapping(uint256 => mapping(address => address))      | 302  | 0      | 32    | MainnetERC1155Vault |
| __gap              | uint256[48]                                          | 303  | 0      | 1536  | MainnetERC1155Vault |
| __gap              | uint256[50]                                          | 351  | 0      | 1600  | MainnetERC1155Vault |
| __gap              | uint256[50]                                          | 401  | 0      | 1600  | MainnetERC1155Vault |
| __gap              | uint256[50]                                          | 451  | 0      | 1600  | MainnetERC1155Vault |

## MainnetERC721Vault
| Name               | Type                                                 | Slot | Offset | Bytes | Contract                                                                       |
|--------------------|------------------------------------------------------|------|--------|-------|--------------------------------------------------------------------------------|
| _initialized       | uint8                                                | 0    | 0      | 1     | MainnetERC721Vault |
| _initializing      | bool                                                 | 0    | 1      | 1     | MainnetERC721Vault |
| __gap              | uint256[50]                                          | 1    | 0      | 1600  | MainnetERC721Vault |
| _owner             | address                                              | 51   | 0      | 20    | MainnetERC721Vault |
| __gap              | uint256[49]                                          | 52   | 0      | 1568  | MainnetERC721Vault |
| _pendingOwner      | address                                              | 101  | 0      | 20    | MainnetERC721Vault |
| __gap              | uint256[49]                                          | 102  | 0      | 1568  | MainnetERC721Vault |
| addressManager     | address                                              | 151  | 0      | 20    | MainnetERC721Vault |
| __gap              | uint256[49]                                          | 152  | 0      | 1568  | MainnetERC721Vault |
| __reentry          | uint8                                                | 201  | 0      | 1     | MainnetERC721Vault |
| __paused           | uint8                                                | 201  | 1      | 1     | MainnetERC721Vault |
| __lastUnpausedAt   | uint64                                               | 201  | 2      | 8     | MainnetERC721Vault |
| __gap              | uint256[49]                                          | 202  | 0      | 1568  | MainnetERC721Vault |
| __gap              | uint256[50]                                          | 251  | 0      | 1600  | MainnetERC721Vault |
| bridgedToCanonical | mapping(address => struct BaseNFTVault.CanonicalNFT) | 301  | 0      | 32    | MainnetERC721Vault |
| canonicalToBridged | mapping(uint256 => mapping(address => address))      | 302  | 0      | 32    | MainnetERC721Vault |
| __gap              | uint256[48]                                          | 303  | 0      | 1536  | MainnetERC721Vault |
| __gap              | uint256[50]                                          | 351  | 0      | 1600  | MainnetERC721Vault |

## MainnetSharedAddressManager
| Name             | Type                                            | Slot | Offset | Bytes | Contract                                                                                         |
|------------------|-------------------------------------------------|------|--------|-------|--------------------------------------------------------------------------------------------------|
| _initialized     | uint8                                           | 0    | 0      | 1     | MainnetSharedAddressManager |
| _initializing    | bool                                            | 0    | 1      | 1     | MainnetSharedAddressManager |
| __gap            | uint256[50]                                     | 1    | 0      | 1600  | MainnetSharedAddressManager |
| _owner           | address                                         | 51   | 0      | 20    | MainnetSharedAddressManager |
| __gap            | uint256[49]                                     | 52   | 0      | 1568  | MainnetSharedAddressManager |
| _pendingOwner    | address                                         | 101  | 0      | 20    | MainnetSharedAddressManager |
| __gap            | uint256[49]                                     | 102  | 0      | 1568  | MainnetSharedAddressManager |
| addressManager   | address                                         | 151  | 0      | 20    | MainnetSharedAddressManager |
| __gap            | uint256[49]                                     | 152  | 0      | 1568  | MainnetSharedAddressManager |
| __reentry        | uint8                                           | 201  | 0      | 1     | MainnetSharedAddressManager |
| __paused         | uint8                                           | 201  | 1      | 1     | MainnetSharedAddressManager |
| __lastUnpausedAt | uint64                                          | 201  | 2      | 8     | MainnetSharedAddressManager |
| __gap            | uint256[49]                                     | 202  | 0      | 1568  | MainnetSharedAddressManager |
| __addresses      | mapping(uint256 => mapping(bytes32 => address)) | 251  | 0      | 32    | MainnetSharedAddressManager |
| __gap            | uint256[49]                                     | 252  | 0      | 1568  | MainnetSharedAddressManager |

## RollupAddressCache
| Name | Type | Slot | Offset | Bytes | Contract |
|------|------|------|--------|-------|----------|

## SharedAddressCache
| Name | Type | Slot | Offset | Bytes | Contract |
|------|------|------|--------|-------|----------|

## AddressCache
| Name | Type | Slot | Offset | Bytes | Contract |
|------|------|------|--------|-------|----------|

## MainnetSgxVerifier
| Name              | Type                                            | Slot | Offset | Bytes | Contract                                                                            |
|-------------------|-------------------------------------------------|------|--------|-------|-------------------------------------------------------------------------------------|
| _initialized      | uint8                                           | 0    | 0      | 1     | MainnetSgxVerifier |
| _initializing     | bool                                            | 0    | 1      | 1     | MainnetSgxVerifier |
| __gap             | uint256[50]                                     | 1    | 0      | 1600  | MainnetSgxVerifier |
| _owner            | address                                         | 51   | 0      | 20    | MainnetSgxVerifier |
| __gap             | uint256[49]                                     | 52   | 0      | 1568  | MainnetSgxVerifier |
| _pendingOwner     | address                                         | 101  | 0      | 20    | MainnetSgxVerifier |
| __gap             | uint256[49]                                     | 102  | 0      | 1568  | MainnetSgxVerifier |
| addressManager    | address                                         | 151  | 0      | 20    | MainnetSgxVerifier |
| __gap             | uint256[49]                                     | 152  | 0      | 1568  | MainnetSgxVerifier |
| __reentry         | uint8                                           | 201  | 0      | 1     | MainnetSgxVerifier |
| __paused          | uint8                                           | 201  | 1      | 1     | MainnetSgxVerifier |
| __lastUnpausedAt  | uint64                                          | 201  | 2      | 8     | MainnetSgxVerifier |
| __gap             | uint256[49]                                     | 202  | 0      | 1568  | MainnetSgxVerifier |
| nextInstanceId    | uint256                                         | 251  | 0      | 32    | MainnetSgxVerifier |
| instances         | mapping(uint256 => struct SgxVerifier.Instance) | 252  | 0      | 32    | MainnetSgxVerifier |
| addressRegistered | mapping(address => bool)                        | 253  | 0      | 32    | MainnetSgxVerifier |
| __gap             | uint256[47]                                     | 254  | 0      | 1504  | MainnetSgxVerifier |

## MainnetSP1Verifier
| Name             | Type                     | Slot | Offset | Bytes | Contract                                                                            |
|------------------|--------------------------|------|--------|-------|-------------------------------------------------------------------------------------|
| _initialized     | uint8                    | 0    | 0      | 1     | MainnetSP1Verifier |
| _initializing    | bool                     | 0    | 1      | 1     | MainnetSP1Verifier |
| __gap            | uint256[50]              | 1    | 0      | 1600  | MainnetSP1Verifier |
| _owner           | address                  | 51   | 0      | 20    | MainnetSP1Verifier |
| __gap            | uint256[49]              | 52   | 0      | 1568  | MainnetSP1Verifier |
| _pendingOwner    | address                  | 101  | 0      | 20    | MainnetSP1Verifier |
| __gap            | uint256[49]              | 102  | 0      | 1568  | MainnetSP1Verifier |
| addressManager   | address                  | 151  | 0      | 20    | MainnetSP1Verifier |
| __gap            | uint256[49]              | 152  | 0      | 1568  | MainnetSP1Verifier |
| __reentry        | uint8                    | 201  | 0      | 1     | MainnetSP1Verifier |
| __paused         | uint8                    | 201  | 1      | 1     | MainnetSP1Verifier |
| __lastUnpausedAt | uint64                   | 201  | 2      | 8     | MainnetSP1Verifier |
| __gap            | uint256[49]              | 202  | 0      | 1568  | MainnetSP1Verifier |
| isProgramTrusted | mapping(bytes32 => bool) | 251  | 0      | 32    | MainnetSP1Verifier |
| __gap            | uint256[49]              | 252  | 0      | 1568  | MainnetSP1Verifier |

## MainnetZkAnyVerifier
| Name             | Type        | Slot | Offset | Bytes | Contract                                                                                |
|------------------|-------------|------|--------|-------|-----------------------------------------------------------------------------------------|
| _initialized     | uint8       | 0    | 0      | 1     | MainnetZkAnyVerifier |
| _initializing    | bool        | 0    | 1      | 1     | MainnetZkAnyVerifier |
| __gap            | uint256[50] | 1    | 0      | 1600  | MainnetZkAnyVerifier |
| _owner           | address     | 51   | 0      | 20    | MainnetZkAnyVerifier |
| __gap            | uint256[49] | 52   | 0      | 1568  | MainnetZkAnyVerifier |
| _pendingOwner    | address     | 101  | 0      | 20    | MainnetZkAnyVerifier |
| __gap            | uint256[49] | 102  | 0      | 1568  | MainnetZkAnyVerifier |
| addressManager   | address     | 151  | 0      | 20    | MainnetZkAnyVerifier |
| __gap            | uint256[49] | 152  | 0      | 1568  | MainnetZkAnyVerifier |
| __reentry        | uint8       | 201  | 0      | 1     | MainnetZkAnyVerifier |
| __paused         | uint8       | 201  | 1      | 1     | MainnetZkAnyVerifier |
| __lastUnpausedAt | uint64      | 201  | 2      | 8     | MainnetZkAnyVerifier |
| __gap            | uint256[49] | 202  | 0      | 1568  | MainnetZkAnyVerifier |
| __gap            | uint256[50] | 251  | 0      | 1600  | MainnetZkAnyVerifier |
| __gap            | uint256[50] | 301  | 0      | 1600  | MainnetZkAnyVerifier |

## MainnetRisc0Verifier
| Name             | Type                     | Slot | Offset | Bytes | Contract                                                                                |
|------------------|--------------------------|------|--------|-------|-----------------------------------------------------------------------------------------|
| _initialized     | uint8                    | 0    | 0      | 1     | MainnetRisc0Verifier |
| _initializing    | bool                     | 0    | 1      | 1     | MainnetRisc0Verifier |
| __gap            | uint256[50]              | 1    | 0      | 1600  | MainnetRisc0Verifier |
| _owner           | address                  | 51   | 0      | 20    | MainnetRisc0Verifier |
| __gap            | uint256[49]              | 52   | 0      | 1568  | MainnetRisc0Verifier |
| _pendingOwner    | address                  | 101  | 0      | 20    | MainnetRisc0Verifier |
| __gap            | uint256[49]              | 102  | 0      | 1568  | MainnetRisc0Verifier |
| addressManager   | address                  | 151  | 0      | 20    | MainnetRisc0Verifier |
| __gap            | uint256[49]              | 152  | 0      | 1568  | MainnetRisc0Verifier |
| __reentry        | uint8                    | 201  | 0      | 1     | MainnetRisc0Verifier |
| __paused         | uint8                    | 201  | 1      | 1     | MainnetRisc0Verifier |
| __lastUnpausedAt | uint64                   | 201  | 2      | 8     | MainnetRisc0Verifier |
| __gap            | uint256[49]              | 202  | 0      | 1568  | MainnetRisc0Verifier |
| isImageTrusted   | mapping(bytes32 => bool) | 251  | 0      | 32    | MainnetRisc0Verifier |
| __gap            | uint256[49]              | 252  | 0      | 1568  | MainnetRisc0Verifier |

## MainnetZkAndTeeVerifier
| Name             | Type        | Slot | Offset | Bytes | Contract                                                                                      |
|------------------|-------------|------|--------|-------|-----------------------------------------------------------------------------------------------|
| _initialized     | uint8       | 0    | 0      | 1     | MainnetZkAndTeeVerifier |
| _initializing    | bool        | 0    | 1      | 1     | MainnetZkAndTeeVerifier |
| __gap            | uint256[50] | 1    | 0      | 1600  | MainnetZkAndTeeVerifier |
| _owner           | address     | 51   | 0      | 20    | MainnetZkAndTeeVerifier |
| __gap            | uint256[49] | 52   | 0      | 1568  | MainnetZkAndTeeVerifier |
| _pendingOwner    | address     | 101  | 0      | 20    | MainnetZkAndTeeVerifier |
| __gap            | uint256[49] | 102  | 0      | 1568  | MainnetZkAndTeeVerifier |
| addressManager   | address     | 151  | 0      | 20    | MainnetZkAndTeeVerifier |
| __gap            | uint256[49] | 152  | 0      | 1568  | MainnetZkAndTeeVerifier |
| __reentry        | uint8       | 201  | 0      | 1     | MainnetZkAndTeeVerifier |
| __paused         | uint8       | 201  | 1      | 1     | MainnetZkAndTeeVerifier |
| __lastUnpausedAt | uint64      | 201  | 2      | 8     | MainnetZkAndTeeVerifier |
| __gap            | uint256[49] | 202  | 0      | 1568  | MainnetZkAndTeeVerifier |
| __gap            | uint256[50] | 251  | 0      | 1600  | MainnetZkAndTeeVerifier |
| __gap            | uint256[50] | 301  | 0      | 1600  | MainnetZkAndTeeVerifier |

## MainnetTeeAnyVerifier
| Name             | Type        | Slot | Offset | Bytes | Contract                                                                                  |
|------------------|-------------|------|--------|-------|-------------------------------------------------------------------------------------------|
| _initialized     | uint8       | 0    | 0      | 1     | MainnetTeeAnyVerifier |
| _initializing    | bool        | 0    | 1      | 1     | MainnetTeeAnyVerifier |
| __gap            | uint256[50] | 1    | 0      | 1600  | MainnetTeeAnyVerifier |
| _owner           | address     | 51   | 0      | 20    | MainnetTeeAnyVerifier |
| __gap            | uint256[49] | 52   | 0      | 1568  | MainnetTeeAnyVerifier |
| _pendingOwner    | address     | 101  | 0      | 20    | MainnetTeeAnyVerifier |
| __gap            | uint256[49] | 102  | 0      | 1568  | MainnetTeeAnyVerifier |
| addressManager   | address     | 151  | 0      | 20    | MainnetTeeAnyVerifier |
| __gap            | uint256[49] | 152  | 0      | 1568  | MainnetTeeAnyVerifier |
| __reentry        | uint8       | 201  | 0      | 1     | MainnetTeeAnyVerifier |
| __paused         | uint8       | 201  | 1      | 1     | MainnetTeeAnyVerifier |
| __lastUnpausedAt | uint64      | 201  | 2      | 8     | MainnetTeeAnyVerifier |
| __gap            | uint256[49] | 202  | 0      | 1568  | MainnetTeeAnyVerifier |
| __gap            | uint256[50] | 251  | 0      | 1600  | MainnetTeeAnyVerifier |
| __gap            | uint256[50] | 301  | 0      | 1600  | MainnetTeeAnyVerifier |

## MainnetGuardianProver
| Name                    | Type                                            | Slot | Offset | Bytes | Contract                                                                        |
|-------------------------|-------------------------------------------------|------|--------|-------|---------------------------------------------------------------------------------|
| _initialized            | uint8                                           | 0    | 0      | 1     | MainnetGuardianProver |
| _initializing           | bool                                            | 0    | 1      | 1     | MainnetGuardianProver |
| __gap                   | uint256[50]                                     | 1    | 0      | 1600  | MainnetGuardianProver |
| _owner                  | address                                         | 51   | 0      | 20    | MainnetGuardianProver |
| __gap                   | uint256[49]                                     | 52   | 0      | 1568  | MainnetGuardianProver |
| _pendingOwner           | address                                         | 101  | 0      | 20    | MainnetGuardianProver |
| __gap                   | uint256[49]                                     | 102  | 0      | 1568  | MainnetGuardianProver |
| addressManager          | address                                         | 151  | 0      | 20    | MainnetGuardianProver |
| __gap                   | uint256[49]                                     | 152  | 0      | 1568  | MainnetGuardianProver |
| __reentry               | uint8                                           | 201  | 0      | 1     | MainnetGuardianProver |
| __paused                | uint8                                           | 201  | 1      | 1     | MainnetGuardianProver |
| __lastUnpausedAt        | uint64                                          | 201  | 2      | 8     | MainnetGuardianProver |
| __gap                   | uint256[49]                                     | 202  | 0      | 1568  | MainnetGuardianProver |
| guardianIds             | mapping(address => uint256)                     | 251  | 0      | 32    | MainnetGuardianProver |
| approvals               | mapping(uint256 => mapping(bytes32 => uint256)) | 252  | 0      | 32    | MainnetGuardianProver |
| guardians               | address[]                                       | 253  | 0      | 32    | MainnetGuardianProver |
| version                 | uint32                                          | 254  | 0      | 4     | MainnetGuardianProver |
| minGuardians            | uint32                                          | 254  | 4      | 4     | MainnetGuardianProver |
| provingAutoPauseEnabled | bool                                            | 254  | 8      | 1     | MainnetGuardianProver |
| latestProofHash         | mapping(uint256 => mapping(uint256 => bytes32)) | 255  | 0      | 32    | MainnetGuardianProver |
| __gap                   | uint256[45]                                     | 256  | 0      | 1440  | MainnetGuardianProver |

## MainnetTaikoL1
| Name             | Type                   | Slot | Offset | Bytes | Contract                                                          |
|------------------|------------------------|------|--------|-------|-------------------------------------------------------------------|
| _initialized     | uint8                  | 0    | 0      | 1     | MainnetTaikoL1 |
| _initializing    | bool                   | 0    | 1      | 1     | MainnetTaikoL1 |
| __gap            | uint256[50]            | 1    | 0      | 1600  | MainnetTaikoL1 |
| _owner           | address                | 51   | 0      | 20    | MainnetTaikoL1 |
| __gap            | uint256[49]            | 52   | 0      | 1568  | MainnetTaikoL1 |
| _pendingOwner    | address                | 101  | 0      | 20    | MainnetTaikoL1 |
| __gap            | uint256[49]            | 102  | 0      | 1568  | MainnetTaikoL1 |
| addressManager   | address                | 151  | 0      | 20    | MainnetTaikoL1 |
| __gap            | uint256[49]            | 152  | 0      | 1568  | MainnetTaikoL1 |
| __reentry        | uint8                  | 201  | 0      | 1     | MainnetTaikoL1 |
| __paused         | uint8                  | 201  | 1      | 1     | MainnetTaikoL1 |
| __lastUnpausedAt | uint64                 | 201  | 2      | 8     | MainnetTaikoL1 |
| __gap            | uint256[49]            | 202  | 0      | 1568  | MainnetTaikoL1 |
| state            | struct TaikoData.State | 251  | 0      | 1600  | MainnetTaikoL1 |
| __gap            | uint256[50]            | 301  | 0      | 1600  | MainnetTaikoL1 |

## MainnetRollupAddressManager
| Name             | Type                                            | Slot | Offset | Bytes | Contract                                                                                    |
|------------------|-------------------------------------------------|------|--------|-------|---------------------------------------------------------------------------------------------|
| _initialized     | uint8                                           | 0    | 0      | 1     | MainnetRollupAddressManager |
| _initializing    | bool                                            | 0    | 1      | 1     | MainnetRollupAddressManager |
| __gap            | uint256[50]                                     | 1    | 0      | 1600  | MainnetRollupAddressManager |
| _owner           | address                                         | 51   | 0      | 20    | MainnetRollupAddressManager |
| __gap            | uint256[49]                                     | 52   | 0      | 1568  | MainnetRollupAddressManager |
| _pendingOwner    | address                                         | 101  | 0      | 20    | MainnetRollupAddressManager |
| __gap            | uint256[49]                                     | 102  | 0      | 1568  | MainnetRollupAddressManager |
| addressManager   | address                                         | 151  | 0      | 20    | MainnetRollupAddressManager |
| __gap            | uint256[49]                                     | 152  | 0      | 1568  | MainnetRollupAddressManager |
| __reentry        | uint8                                           | 201  | 0      | 1     | MainnetRollupAddressManager |
| __paused         | uint8                                           | 201  | 1      | 1     | MainnetRollupAddressManager |
| __lastUnpausedAt | uint64                                          | 201  | 2      | 8     | MainnetRollupAddressManager |
| __gap            | uint256[49]                                     | 202  | 0      | 1568  | MainnetRollupAddressManager |
| __addresses      | mapping(uint256 => mapping(bytes32 => address)) | 251  | 0      | 32    | MainnetRollupAddressManager |
| __gap            | uint256[49]                                     | 252  | 0      | 1568  | MainnetRollupAddressManager |

## MainnetTierRouter
| Name | Type | Slot | Offset | Bytes | Contract |
|------|------|------|--------|-------|----------|

## MainnetProverSet
| Name             | Type                     | Slot | Offset | Bytes | Contract                                                              |
|------------------|--------------------------|------|--------|-------|-----------------------------------------------------------------------|
| _initialized     | uint8                    | 0    | 0      | 1     | MainnetProverSet |
| _initializing    | bool                     | 0    | 1      | 1     | MainnetProverSet |
| __gap            | uint256[50]              | 1    | 0      | 1600  | MainnetProverSet |
| _owner           | address                  | 51   | 0      | 20    | MainnetProverSet |
| __gap            | uint256[49]              | 52   | 0      | 1568  | MainnetProverSet |
| _pendingOwner    | address                  | 101  | 0      | 20    | MainnetProverSet |
| __gap            | uint256[49]              | 102  | 0      | 1568  | MainnetProverSet |
| addressManager   | address                  | 151  | 0      | 20    | MainnetProverSet |
| __gap            | uint256[49]              | 152  | 0      | 1568  | MainnetProverSet |
| __reentry        | uint8                    | 201  | 0      | 1     | MainnetProverSet |
| __paused         | uint8                    | 201  | 1      | 1     | MainnetProverSet |
| __lastUnpausedAt | uint64                   | 201  | 2      | 8     | MainnetProverSet |
| __gap            | uint256[49]              | 202  | 0      | 1568  | MainnetProverSet |
| isProver         | mapping(address => bool) | 251  | 0      | 32    | MainnetProverSet |
| admin            | address                  | 252  | 0      | 20    | MainnetProverSet |
| __gap            | uint256[48]              | 253  | 0      | 1536  | MainnetProverSet |

## TokenUnlock
| Name             | Type                     | Slot | Offset | Bytes | Contract                                                      |
|------------------|--------------------------|------|--------|-------|---------------------------------------------------------------|
| _initialized     | uint8                    | 0    | 0      | 1     | TokenUnlock |
| _initializing    | bool                     | 0    | 1      | 1     | TokenUnlock |
| __gap            | uint256[50]              | 1    | 0      | 1600  | TokenUnlock |
| _owner           | address                  | 51   | 0      | 20    | TokenUnlock |
| __gap            | uint256[49]              | 52   | 0      | 1568  | TokenUnlock |
| _pendingOwner    | address                  | 101  | 0      | 20    | TokenUnlock |
| __gap            | uint256[49]              | 102  | 0      | 1568  | TokenUnlock |
| addressManager   | address                  | 151  | 0      | 20    | TokenUnlock |
| __gap            | uint256[49]              | 152  | 0      | 1568  | TokenUnlock |
| __reentry        | uint8                    | 201  | 0      | 1     | TokenUnlock |
| __paused         | uint8                    | 201  | 1      | 1     | TokenUnlock |
| __lastUnpausedAt | uint64                   | 201  | 2      | 8     | TokenUnlock |
| __gap            | uint256[49]              | 202  | 0      | 1568  | TokenUnlock |
| amountVested     | uint256                  | 251  | 0      | 32    | TokenUnlock |
| recipient        | address                  | 252  | 0      | 20    | TokenUnlock |
| tgeTimestamp     | uint64                   | 252  | 20     | 8     | TokenUnlock |
| isProverSet      | mapping(address => bool) | 253  | 0      | 32    | TokenUnlock |
| __gap            | uint256[47]              | 254  | 0      | 1504  | TokenUnlock |

## ProverSet
| Name             | Type                     | Slot | Offset | Bytes | Contract                                         |
|------------------|--------------------------|------|--------|-------|--------------------------------------------------|
| _initialized     | uint8                    | 0    | 0      | 1     | ProverSet |
| _initializing    | bool                     | 0    | 1      | 1     | ProverSet |
| __gap            | uint256[50]              | 1    | 0      | 1600  | ProverSet |
| _owner           | address                  | 51   | 0      | 20    | ProverSet |
| __gap            | uint256[49]              | 52   | 0      | 1568  | ProverSet |
| _pendingOwner    | address                  | 101  | 0      | 20    | ProverSet |
| __gap            | uint256[49]              | 102  | 0      | 1568  | ProverSet |
| addressManager   | address                  | 151  | 0      | 20    | ProverSet |
| __gap            | uint256[49]              | 152  | 0      | 1568  | ProverSet |
| __reentry        | uint8                    | 201  | 0      | 1     | ProverSet |
| __paused         | uint8                    | 201  | 1      | 1     | ProverSet |
| __lastUnpausedAt | uint64                   | 201  | 2      | 8     | ProverSet |
| __gap            | uint256[49]              | 202  | 0      | 1568  | ProverSet |
| isProver         | mapping(address => bool) | 251  | 0      | 32    | ProverSet |
| admin            | address                  | 252  | 0      | 20    | ProverSet |
| __gap            | uint256[48]              | 253  | 0      | 1536  | ProverSet |

## GuardianProver
| Name                    | Type                                            | Slot | Offset | Bytes | Contract                                                   |
|-------------------------|-------------------------------------------------|------|--------|-------|------------------------------------------------------------|
| _initialized            | uint8                                           | 0    | 0      | 1     | GuardianProver |
| _initializing           | bool                                            | 0    | 1      | 1     | GuardianProver |
| __gap                   | uint256[50]                                     | 1    | 0      | 1600  | GuardianProver |
| _owner                  | address                                         | 51   | 0      | 20    | GuardianProver |
| __gap                   | uint256[49]                                     | 52   | 0      | 1568  | GuardianProver |
| _pendingOwner           | address                                         | 101  | 0      | 20    | GuardianProver |
| __gap                   | uint256[49]                                     | 102  | 0      | 1568  | GuardianProver |
| addressManager          | address                                         | 151  | 0      | 20    | GuardianProver |
| __gap                   | uint256[49]                                     | 152  | 0      | 1568  | GuardianProver |
| __reentry               | uint8                                           | 201  | 0      | 1     | GuardianProver |
| __paused                | uint8                                           | 201  | 1      | 1     | GuardianProver |
| __lastUnpausedAt        | uint64                                          | 201  | 2      | 8     | GuardianProver |
| __gap                   | uint256[49]                                     | 202  | 0      | 1568  | GuardianProver |
| guardianIds             | mapping(address => uint256)                     | 251  | 0      | 32    | GuardianProver |
| approvals               | mapping(uint256 => mapping(bytes32 => uint256)) | 252  | 0      | 32    | GuardianProver |
| guardians               | address[]                                       | 253  | 0      | 32    | GuardianProver |
| version                 | uint32                                          | 254  | 0      | 4     | GuardianProver |
| minGuardians            | uint32                                          | 254  | 4      | 4     | GuardianProver |
| provingAutoPauseEnabled | bool                                            | 254  | 8      | 1     | GuardianProver |
| latestProofHash         | mapping(uint256 => mapping(uint256 => bytes32)) | 255  | 0      | 32    | GuardianProver |
| __gap                   | uint256[45]                                     | 256  | 0      | 1440  | GuardianProver |

