// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "eigenlayer-contracts/src/contracts/interfaces/ISlasher.sol";
import "eigenlayer-contracts/src/contracts/interfaces/IAVSDirectory.sol";
import "../iface/IPreconfServiceManager.sol";

/// @dev This contract is a Eigenlayer based preconf servicei implementation.
contract EigenlayerPreconfServiceManager is IPreconfServiceManager, ReentrancyGuard {
    address internal immutable preconfRegistry;
    address internal immutable preconfTaskManager;
    IAVSDirectory internal immutable avsDirectory;
    ISlasher internal immutable slasher;

    /// @dev This is currently just a flag and not actually being used to lock the stake.
    mapping(address operator => uint256 timestamp) public stakeLockedUntil;

    uint256[49] private __gap; // 50 - 1

    constructor(
        address _preconfRegistry,
        address _preconfTaskManager,
        IAVSDirectory _avsDirectory,
        ISlasher _slasher
    ) {
        preconfRegistry = _preconfRegistry;
        preconfTaskManager = _preconfTaskManager;
        avsDirectory = _avsDirectory;
        slasher = _slasher;
    }

    modifier onlyCallableBy(address allowedSender) {
        if (msg.sender != allowedSender) {
            revert SenderIsNotAllowed();
        }
        _;
    }

    /// @dev Simply relays the call to the AVS directory
    function registerOperatorToAVS(
        address operator,
        bytes calldata operatorSignature
    )
        external
        nonReentrant
        onlyCallableBy(preconfRegistry)
    {
        ISignatureUtils.SignatureWithSaltAndExpiry memory sig =
            abi.decode(operatorSignature, (ISignatureUtils.SignatureWithSaltAndExpiry));
        avsDirectory.registerOperatorToAVS(operator, sig);
    }

    /// @dev Simply relays the call to the AVS directory
    function deregisterOperatorFromAVS(address operator)
        external
        nonReentrant
        onlyCallableBy(preconfRegistry)
    {
        avsDirectory.deregisterOperatorFromAVS(operator);
    }

    /// @dev This not completely functional until Eigenlayer decides the logic of their Slasher.
    ///  for now this simply sets a value in the storage and releases an event.
    function lockStakeUntil(
        address operator,
        uint256 timestamp
    )
        external
        nonReentrant
        onlyCallableBy(preconfTaskManager)
    {
        stakeLockedUntil[operator] = timestamp;
        emit StakeLockedUntil(operator, timestamp);
    }

    /// @dev This not completely functional until Eigenlayer decides the logic of their Slasher.
    function slashOperator(address operator)
        external
        nonReentrant
        onlyCallableBy(preconfTaskManager)
    {
        if (slasher.canSlash(operator, address(this))) {
            slasher.freezeOperator(operator);
        }
    }
}
