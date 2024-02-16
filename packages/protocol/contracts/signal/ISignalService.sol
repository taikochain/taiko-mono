// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/
//
//   Email: security@taiko.xyz
//   Website: https://taiko.xyz
//   GitHub: https://github.com/taikoxyz
//   Discord: https://discord.gg/taikoxyz
//   Twitter: https://twitter.com/taikoxyz
//   Blog: https://mirror.xyz/labs.taiko.eth
//   Youtube: https://www.youtube.com/@taikoxyz

pragma solidity 0.8.24;

/// @title ISignalService
/// @notice The SignalService contract serves as a secure cross-chain message
/// passing system. It defines methods for sending and verifying signals with
/// merkle proofs. The trust assumption is that the target chain has secure
/// access to the merkle root (such as Taiko injects it in the anchor
/// transaction). With this, verifying a signal is reduced to simply verifying
/// a merkle proof.

interface ISignalService {
    /// @notice Emitted when a remote chain's state root or signal root is
    /// relayed locally as a signal.
    event ChainDataRelayed(
        uint64 indexed chainid,
        uint64 indexed blockId,
        bytes32 indexed kind,
        bytes32 data,
        bytes32 signal
    );

    /// @notice Send a signal (message) by setting the storage slot to a value of 1.
    /// @param signal The signal (message) to send.
    /// @return slot The location in storage where this signal is stored.
    function sendSignal(bytes32 signal) external returns (bytes32 slot);

    /// @notice Relay a data from a remote chain locally as a signal. The signal is calculated
    /// uniquely from chainId, kind, and data.
    /// @param chainId The remote chainId.
    /// @param blockId The chain data's corresponding blockId
    /// @param kind A value to mark the data type.
    /// @param chainData The remote data.
    /// @return signal The signal for this chain data.
    function relayChainData(
        uint64 chainId,
        uint64 blockId,
        bytes32 kind,
        bytes32 chainData
    )
        external
        returns (bytes32 signal);

    /// @notice Verifies if a signal has been received on the target chain.
    /// @param chainId The identifier for the source chain from which the
    /// signal originated.
    /// @param app The address that initiated the signal.
    /// @param signal The signal (message) to send.
    /// @param proof Merkle proof that the signal was persisted on the
    /// source chain.
    function proveSignalReceived(
        uint64 chainId,
        address app,
        bytes32 signal,
        bytes calldata proof
    )
        external;

    /// @notice Verifies if a particular signal has already been sent.
    /// @param app The address that initiated the signal.
    /// @param signal The signal (message) that was sent.
    /// @return True if the signal has been sent, otherwise false.
    function isSignalSent(address app, bytes32 signal) external view returns (bool);

    /// @notice Checks if a chain data has been relayed.
    /// uniquely from chainId, kind, and data.
    /// @param chainId The remote chainId.
    /// @param blockId The chain data's corresponding blockId
    /// @param kind A value to mark the data type.
    /// @param chainData The remote data.
    /// @return True if the data has been relayed, otherwise false.
    function isChainDataRelayed(
        uint64 chainId,
        uint64 blockId,
        bytes32 kind,
        bytes32 chainData
    )
        external
        view
        returns (bool);

    /// @notice Returns the given block's  chain data.
    /// @param blockId The chain data's corresponding block id. If this value is 0, use the top
    /// block id.
    /// @param kind A value to mark the data type.
    /// @return _blockId The actual block id.
    /// @return _chainData The relayed chain data.
    function getChainData(
        uint64 chainId,
        uint64 blockId,
        bytes32 kind
    )
        external
        view
        returns (uint64 _blockId, bytes32 _chainData);
}
