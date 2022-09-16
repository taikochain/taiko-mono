// SPDX-License-Identifier: MIT
//
// ╭━━━━╮╱╱╭╮╱╱╱╱╱╭╮╱╱╱╱╱╭╮
// ┃╭╮╭╮┃╱╱┃┃╱╱╱╱╱┃┃╱╱╱╱╱┃┃
// ╰╯┃┃┣┻━┳┫┃╭┳━━╮┃┃╱╱╭━━┫╰━┳━━╮
// ╱╱┃┃┃╭╮┣┫╰╯┫╭╮┃┃┃╱╭┫╭╮┃╭╮┃━━┫
// ╱╱┃┃┃╭╮┃┃╭╮┫╰╯┃┃╰━╯┃╭╮┃╰╯┣━━┃
// ╱╱╰╯╰╯╰┻┻╯╰┻━━╯╰━━━┻╯╰┻━━┻━━╯
pragma solidity ^0.8.9;

import "./LibBridgeData.sol";
import "./LibBridgeRead.sol";

/// @author dantaik <dan@taiko.xyz>
library LibBridgeSend {
    using LibAddress for address;
    using LibBridgeData for Message;
    using LibBridgeRead for LibBridgeData.State;

    /*********************
     * Internal Functions*
     *********************/

    function sendMessage(
        LibBridgeData.State storage state,
        address refundFeeTo,
        Message memory message
    ) internal returns (uint256 height, bytes32 mhash) {
        require(refundFeeTo != address(0), "B:refundFeeTo");
        require(
            message.destChainId != block.chainid &&
                state.isDestChainEnabled(message.destChainId),
            "B:destChainId"
        );

        message.id = state.nextMessageId++;
        message.sender = msg.sender;
        message.srcChainId = block.chainid;

        if (message.owner == address(0)) {
            message.owner = msg.sender;
        }

        height = block.number;
        mhash = message.hashMessage();
        assembly {
            sstore(mhash, 1)
        }

        _handleMessageFee(refundFeeTo, message);

        emit LibBridgeData.MessageSent(height, mhash, message);
    }

    function enableDestChain(
        LibBridgeData.State storage state,
        uint256 chainId,
        bool enabled
    ) internal {
        require(chainId > 0 && chainId != block.chainid, "B:chainId");
        state.destChains[chainId] = enabled;
        emit LibBridgeData.DestChainEnabled(chainId, enabled);
    }

    /*********************
     * Private Functions *
     *********************/

    function _handleMessageFee(address refundFeeTo, Message memory message)
        private
    {
        uint256 requiredEther = message.maxProcessingFee +
            message.depositValue +
            message.callValue +
            (message.gasLimit * message.gasPrice);

        if (msg.value > requiredEther) {
            refundFeeTo.sendEther(msg.value - requiredEther);
        } else if (msg.value < requiredEther) {
            revert("B:lowFee");
        }
    }
}
