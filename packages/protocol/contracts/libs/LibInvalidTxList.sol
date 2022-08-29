// SPDX-License-Identifier: MIT
//
// ╭━━━━╮╱╱╭╮╱╱╱╱╱╭╮╱╱╱╱╱╭╮
// ┃╭╮╭╮┃╱╱┃┃╱╱╱╱╱┃┃╱╱╱╱╱┃┃
// ╰╯┃┃┣┻━┳┫┃╭┳━━╮┃┃╱╱╭━━┫╰━┳━━╮
// ╱╱┃┃┃╭╮┣┫╰╯┫╭╮┃┃┃╱╭┫╭╮┃╭╮┃━━┫
// ╱╱┃┃┃╭╮┃┃╭╮┫╰╯┃┃╰━╯┃╭╮┃╰╯┣━━┃
// ╱╱╰╯╰╯╰┻┻╯╰┻━━╯╰━━━┻╯╰┻━━┻━━╯
pragma solidity ^0.8.9;

import "../libs/LibTaikoConstants.sol";
import "../libs/LibTxListDecoder.sol";
import "../libs/LibMerkleProof.sol";

/// @dev A library to invalidate a txList using the following rules:
///
/// A txList is valid if and only if:
/// 1. The txList's lenght is no more than `TAIKO_BLOCK_MAX_TXLIST_BYTES`;
/// 2. The txList is well-formed RLP, with no additional trailing bytes;
/// 3. The total number of transactions is no more than `TAIKO_BLOCK_MAX_TXS` and;
/// 4. The sum of all transaction gas limit is no more than  `TAIKO_BLOCK_MAX_GAS_LIMIT`.
///
/// A transaction is valid if and only if:
/// 1. The transaction is well-formed RLP, with no additional trailing bytes (rule#1 in Ethereum yellow paper);
/// 2. The transaction's signature is valid (rule#2 in Ethereum yellow paper), and;
/// 3. The transaction's the gas limit is no smaller than the intrinsic gas `TAIKO_TX_MIN_GAS_LIMIT`(rule#5 in Ethereum yellow paper).
///
library LibInvalidTxList {
    enum Reason {
        OK,
        BINARY_TOO_LARGE,
        BINARY_NOT_DECODABLE,
        BLOCK_TOO_MANY_TXS,
        BLOCK_GAS_LIMIT_TOO_LARGE,
        TX_INVALID_SENDER,
        TX_INVALID_SIG,
        TX_GAS_LIMIT_TOO_SMALL
    }

    function isTxListInvalid(
        bytes calldata encoded,
        Reason hint,
        uint256 txIdx
    ) internal pure returns (Reason) {
        if (encoded.length > LibTaikoConstants.TAIKO_BLOCK_MAX_TXLIST_BYTES) {
            return Reason.BINARY_TOO_LARGE;
        }

        try LibTxListDecoder.decodeTxList(encoded) returns (
            LibTxListDecoder.TxList memory txList
        ) {
            if (txList.items.length > LibTaikoConstants.TAIKO_BLOCK_MAX_TXS) {
                return Reason.BLOCK_TOO_MANY_TXS;
            }

            if (
                LibTxListDecoder.sumGasLimit(txList) >
                LibTaikoConstants.TAIKO_BLOCK_MAX_GAS_LIMIT
            ) {
                return Reason.BLOCK_GAS_LIMIT_TOO_LARGE;
            }

            require(txIdx < txList.items.length, "invalid txIdx");
            LibTxListDecoder.Tx memory _tx = txList.items[txIdx];

            if (hint == Reason.TX_INVALID_SENDER) {
                // TODO(daniel/roger):
                // require(tx.sender != LibTaikoConstants.GOLD_FINGER_ADDRESS);
                return Reason.TX_INVALID_SENDER;
            }

            if (hint == Reason.TX_INVALID_SIG) {
                // TODO(daniel/roger): verify the signature is indeed invalid; otherwise, throw.
                return Reason.TX_INVALID_SIG;
            }

            if (hint == Reason.TX_GAS_LIMIT_TOO_SMALL) {
                require(
                    _tx.gasLimit >= LibTaikoConstants.TAIKO_TX_MIN_GAS_LIMIT,
                    "bad hint"
                );
                return Reason.TX_GAS_LIMIT_TOO_SMALL;
            }

            revert("failed to prove txlist invalid");
        } catch (bytes memory) {
            return Reason.BINARY_NOT_DECODABLE;
        }
    }
}
