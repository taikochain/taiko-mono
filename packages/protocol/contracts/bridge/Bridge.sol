// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/
pragma solidity ^0.8.20;

import { AddressResolver } from "../common/AddressResolver.sol";
import { BridgeErrors } from "./BridgeErrors.sol";
import { EssentialContract } from "../common/EssentialContract.sol";
import { IBridge } from "./IBridge.sol";
import { BridgeData } from "./BridgeData.sol";
import { BridgeEvents } from "./BridgeEvents.sol";
import { LibBridgeProcess } from "./libs/LibBridgeProcess.sol";
import { LibBridgeRecall } from "./libs/LibBridgeRecall.sol";
import { LibBridgeRetry } from "./libs/LibBridgeRetry.sol";
import { LibBridgeSend } from "./libs/LibBridgeSend.sol";
import { LibBridgeSignal } from "./libs/LibBridgeSignal.sol";
import { LibBridgeStatus } from "./libs/LibBridgeStatus.sol";
import { Proxied } from "../common/Proxied.sol";

/// @title Bridge
/// @notice See the documentation for {IBridge}.
/// @dev The code hash for the same address on L1 and L2 may be different.
contract Bridge is EssentialContract, IBridge, BridgeErrors, BridgeEvents {
    BridgeData.State private _state; // 50 slots reserved

    event MessageStatusChanged(
        bytes32 indexed msgHash, BridgeData.Status status
    );

    event DestChainEnabled(uint256 indexed chainId, bool enabled);

    receive() external payable { }

    /// @notice Initializes the contract.
    /// @param _addressManager The address of the {AddressManager} contract.
    function init(address _addressManager) external initializer {
        EssentialContract._init(_addressManager);
    }

    /// @notice Sends a message from the current chain to the destination chain
    /// specified in the message.
    /// @inheritdoc IBridge
    function sendMessage(BridgeData.Message calldata message)
        external
        payable
        nonReentrant
        returns (bytes32 msgHash)
    {
        return LibBridgeSend.sendMessage({
            state: _state,
            resolver: AddressResolver(this),
            message: message
        });
    }

    /// @notice Processes a message received from another chain.
    /// @inheritdoc IBridge
    function processMessage(
        BridgeData.Message calldata message,
        bytes[] calldata proofs
    )
        external
        nonReentrant
    {
        return LibBridgeProcess.processMessage({
            state: _state,
            resolver: AddressResolver(this),
            message: message,
            proofs: proofs,
            checkProof: shouldCheckProof()
        });
    }

    /// @notice Retries executing a message that previously failed on its
    /// destination chain.
    /// @inheritdoc IBridge
    function retryMessage(
        BridgeData.Message calldata message,
        bool isLastAttempt
    )
        external
        nonReentrant
    {
        return LibBridgeRetry.retryMessage({
            state: _state,
            resolver: AddressResolver(this),
            message: message,
            isLastAttempt: isLastAttempt
        });
    }

    /// @notice Recalls a failed message on its source chain
    /// @inheritdoc IBridge
    function recallMessage(
        BridgeData.Message calldata message,
        bytes[] calldata proofs
    )
        external
        nonReentrant
    {
        return LibBridgeRecall.recallMessage({
            state: _state,
            resolver: AddressResolver(this),
            message: message,
            proofs: proofs,
            checkProof: shouldCheckProof()
        });
    }

    /// @notice Checks if the message with the given hash has been sent on its
    /// source chain.
    /// @inheritdoc IBridge
    function isMessageSent(bytes32 msgHash)
        public
        view
        virtual
        returns (bool)
    {
        return LibBridgeSignal.isSignalSent(AddressResolver(this), msgHash);
    }

    /// @notice Checks if the message with the given hash has been received on
    /// its destination chain.
    /// @inheritdoc IBridge
    function isMessageReceived(
        bytes32 msgHash,
        uint256 srcChainId,
        bytes[] calldata proofs
    )
        public
        view
        virtual
        override
        returns (bool)
    {
        return LibBridgeSignal.isSignalReceived({
            resolver: AddressResolver(this),
            signal: msgHash,
            srcChainId: srcChainId,
            proofs: proofs
        });
    }

    /// @notice Checks if a msgHash has failed on its destination chain.
    /// @inheritdoc IBridge
    function isMessageFailed(
        bytes32 msgHash,
        uint256 destChainId,
        bytes[] calldata proofs
    )
        public
        view
        virtual
        override
        returns (bool)
    {
        return LibBridgeSignal.isSignalReceived({
            resolver: AddressResolver(this),
            signal: LibBridgeStatus.getDerivedSignalForFailedMessage(msgHash),
            srcChainId: destChainId,
            proofs: proofs
        });
    }

    /// @notice Checks if a failed message has been recalled on its source
    /// chain.
    /// @inheritdoc IBridge
    function isMessageRecalled(bytes32 msgHash) public view returns (bool) {
        return _state.recalls[msgHash];
    }

    /// @notice Gets the execution status of the message with the given hash on
    /// its destination chain.
    /// @param msgHash The hash of the message.
    /// @return Returns the status of the message.
    function getMessageStatus(bytes32 msgHash)
        public
        view
        virtual
        returns (BridgeData.Status)
    {
        return _state.statuses[msgHash];
    }

    /// @notice Gets the current context.
    /// @inheritdoc IBridge
    function context() public view returns (BridgeData.Context memory) {
        return _state.ctx;
    }

    /// @notice Checks if the destination chain with the given ID is enabled.
    /// @param _chainId The ID of the chain.
    /// @return enabled Returns true if the destination chain is enabled, false
    /// otherwise.
    function isDestChainEnabled(uint256 _chainId)
        public
        view
        returns (bool enabled)
    {
        (enabled,) =
            LibBridgeSend.isDestChainEnabled(AddressResolver(this), _chainId);
    }

    /// @notice Tells if we need to check real proof or it is a test.
    /// @return Returns true if this contract, or can be false if mock/test.
    function shouldCheckProof() internal pure virtual returns (bool) {
        return true;
    }
}

/// @title ProxiedBridge
/// @notice Proxied version of the parent contract.
contract ProxiedBridge is Proxied, Bridge { }
