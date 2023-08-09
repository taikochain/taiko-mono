// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.20;

import { LibBridgeData } from "./libs/LibBridgeData.sol";

/**
 * @title IRecallableMessageSender
 * @notice An interface that all recallable message senders shall implement.
 */
interface IRecallableMessageSender {
    function onMessageRecalled(IBridge.Message calldata message)
        external
        payable;
}

/**
 * @title IBridge
 * @notice Bridge interface for cross-chain communication of messages and
 * assets.
 * Ether is held by Bridges on L1 and by the EtherVault on L2, not by token
 * vaults.
 */
interface IBridge {
    // Struct representing a message sent across the bridge.
    struct Message {
        uint256 id; // Message ID.
        address from; // Message sender address (auto-filled).
        uint256 srcChainId; // Source chain ID (auto-filled).
        uint256 destChainId; // Destination chain ID (auto-filled).
        address user; // User address of the bridged asset.
        address to; // Destination address.
        address refundTo; // Alternate address to send any refund. If blank,
            // defaults to user.
        uint256 value; // Value to invoke on the destination chain, for ERC20
            // transfers.
        uint256 fee; // Processing fee for the relayer. Zero if user will
            // process themselves.
        uint256 gasLimit; // Gas limit to invoke on the destination chain, for
            // ERC20 transfers.
        bytes data; // Call data to invoke on the destination chain, for ERC20
            // transfers.
        string memo; // Optional memo.
    }

    // Struct representing the context of a bridge operation.
    struct Context {
        bytes32 msgHash; // Message hash.
        address from; // Sender's address.
        uint256 srcChainId; // Source chain ID.
    }

    event SignalSent(address indexed sender, bytes32 msgHash);
    event MessageSent(bytes32 indexed msgHash, Message message);
    event MessageRecalled(bytes32 indexed msgHash);

    /**
     * @notice Sends a message to the destination chain and takes custody
     * of Ether required in this contract. All extra Ether will be refunded.
     * @param message The message to be sent.
     * @return msgHash The hash of the sent message.
     */
    function sendMessage(Message memory message)
        external
        payable
        returns (bytes32 msgHash);

    /**
     * @notice Release Ether with a proof that the message processing on the
     * destination
     * chain has failed.
     * @param message The message to be recalled.
     * @param proof The proof of message processing failure.
     */
    function recallMessage(
        IBridge.Message calldata message,
        bytes calldata proof
    )
        external;

    /**
     * @notice Checks if a msgHash has been stored on the bridge contract by the
     * current address.
     * @param msgHash The hash of the message.
     * @return Returns true if the message has been sent, false otherwise.
     */
    function isMessageSent(bytes32 msgHash) external view returns (bool);

    /**
     * @notice Checks if a msgHash has been received on the destination chain
     * and
     * sent by the source chain.
     * @param msgHash The hash of the message.
     * @param srcChainId The source chain ID.
     * @param proof The proof of message receipt.
     * @return Returns true if the message has been received, false otherwise.
     */
    function isMessageReceived(
        bytes32 msgHash,
        uint256 srcChainId,
        bytes calldata proof
    )
        external
        view
        returns (bool);

    /**
     * @notice Checks if a msgHash has failed on the destination chain.
     * @param msgHash The hash of the message.
     * @param destChainId The destination chain ID.
     * @param proof The proof of message failure.
     * @return Returns true if the message has failed, false otherwise.
     */
    function isMessageFailed(
        bytes32 msgHash,
        uint256 destChainId,
        bytes calldata proof
    )
        external
        view
        returns (bool);

    /**
     * @notice Returns the bridge state context.
     * @return context The context of the current bridge operation.
     */
    function context() external view returns (Context memory context);

    /**
     * @notice Computes the hash of a given message.
     * @param message The message to compute the hash for.
     * @return Returns the hash of the message.
     */
    function hashMessage(IBridge.Message calldata message)
        external
        pure
        returns (bytes32);
}
