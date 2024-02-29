// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/// @title IBridge
/// @notice The bridge used in conjunction with the {ISignalService}.
/// @dev Ether is held by Bridges on L1 and L2s.
/// @custom:security-contact security@taiko.xyz
interface IBridge {
    enum Status {
        NEW,
        RETRIABLE,
        DONE,
        FAILED,
        RECALLED
    }

    struct Message {
        // Message ID.
        uint128 id;
        // The address, EOA or contract, that interacts with this bridge.
        address from;
        // Source chain ID.
        uint64 srcChainId;
        // Destination chain ID where the `to` address lives.
        uint64 destChainId;
        // The owner of the message on the source chain.
        address srcOwner;
        // The owner of the message on the destination chain.
        address destOwner;
        // The destination address on the destination chain.
        address to;
        // Alternate address to send any refund on the destination chain.
        // If blank, defaults to destOwner.
        address refundTo;
        // value to invoke on the destination chain.
        uint256 value;
        // Processing fee for the relayer. Zero if owner will process themself.
        uint256 fee;
        // gasLimit to invoke on the destination chain.
        uint256 gasLimit;
        // callData to invoke on the destination chain.
        bytes data;
        // Optional memo.
        string memo;
    }

    // Note that this struct shall take only 1 slot to minimize gas cost
    struct ProofReceipt {
        // The time a message is marked as received on the destination chain
        uint64 receivedAt;
        // The address that can execute the message after the invocation delay without an extra
        // delay.
        // For a failed message, preferredExecutor's value doesn't matter as only the owner can
        // invoke the message.
        address preferredExecutor;
    }

    // Struct representing the context of a bridge operation.
    struct Context {
        bytes32 msgHash; // Message hash.
        address from; // Sender's address.
        uint64 srcChainId; // Source chain ID.
    }

    event MessageSent(bytes32 indexed msgHash, Message message);
    event MessageReceived(bytes32 indexed msgHash, Message message, bool isRecall);
    event MessageRecalled(bytes32 indexed msgHash);
    event MessageExecuted(bytes32 indexed msgHash);
    event MessageRetried(bytes32 indexed msgHash);
    event MessageStatusChanged(bytes32 indexed msgHash, Status status);
    event MessageSuspended(bytes32 msgHash, bool suspended);
    event AddressBanned(address indexed addr, bool banned);

    /// @notice Sends a message to the destination chain and takes custody
    /// of Ether required in this contract. All extra Ether will be refunded.
    /// @param _message The message to be sent.
    /// @return msgHash_ The hash of the sent message.
    /// @return message_ The updated message sent.
    function sendMessage(Message calldata _message)
        external
        payable
        returns (bytes32 msgHash_, Message memory message_);

    /// @notice Recalls a failed message on its source chain, releasing
    /// associated assets.
    /// @dev This function checks if the message failed on the source chain and
    /// releases associated Ether or tokens.
    /// @param _message The message whose associated Ether should be released.
    /// @param _proof The merkle inclusion proof.
    function recallMessage(Message calldata _message, bytes calldata _proof) external;

    /// @notice Processes a bridge message on the destination chain. This
    /// function is callable by any address, including the `message.destOwner`.
    /// @dev The process begins by hashing the message and checking the message
    /// status in the bridge  If the status is "NEW", the message is invoked. The
    /// status is updated accordingly, and processing fees are refunded as
    /// needed.
    /// @param _message The message to be processed.
    /// @param _proof The merkle inclusion proof.
    function processMessage(Message calldata _message, bytes calldata _proof) external;

    /// @notice Retries to invoke the messageCall after releasing associated
    /// Ether and tokens.
    /// @dev This function can be called by any address, including the
    /// `message.destOwner`.
    /// It attempts to invoke the messageCall and updates the message status
    /// accordingly.
    /// @param _message The message to retry.
    /// @param _isLastAttempt Specifies if this is the last attempt to retry the
    /// message.
    function retryMessage(Message calldata _message, bool _isLastAttempt) external;

    /// @notice Returns the bridge state context.
    /// @return ctx_ The context of the current bridge operation.
    function context() external view returns (Context memory ctx_);

    /// @notice Checks if the message was sent.
    /// @param _message The message.
    /// @return true if the message was sent.
    function isMessageSent(Message calldata _message) external view returns (bool);

    /// @notice Hash the message
    /// @param _message The message struct variable to be hashed.
    /// @return The message's hash.
    function hashMessage(Message memory _message) external pure returns (bytes32);
}

/// @title IRecallableSender
/// @notice An interface that all recallable message senders shall implement.
interface IRecallableSender {
    function onMessageRecalled(
        IBridge.Message calldata _message,
        bytes32 _msgHash
    )
        external
        payable;
}

/// @title IMessageInvocable
/// @notice An interface that all bridge message receiver shall implement
interface IMessageInvocable {
    /// @notice Called when this contract is the bridge target.
    /// @param _data The data for this contract to interpret.
    /// @dev This method should be guarded with `onlyFromNamed("bridge")`.
    function onMessageInvocation(bytes calldata _data) external payable;
}
