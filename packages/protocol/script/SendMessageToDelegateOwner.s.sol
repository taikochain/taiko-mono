// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/src/Script.sol";
import "../contracts/L2/DelegateOwner.sol";
import "../contracts/bridge/IBridge.sol";
import "../test/common/TestMulticall3.sol";

contract SendMessageToDelegateOwner is Script {
    address public delegateOwner = 0x904aa0aC002532f1410457484893107757683F53;
    address public multicall3 = 0xcA11bde05977b3631167028862bE2a173976CA11;
    address public l1Bridge = 0xd60247c6848B7Ca29eDdF63AA924E53dB6Ddd8EC;

    modifier broadcast() {
        vm.startBroadcast();
        _;
        vm.stopBroadcast();
    }

    function run() external broadcast {
        TestMulticall3.Call3[] memory calls = new TestMulticall3.Call3[](2);
        calls[0].target = address(delegateOwner);
        calls[0].allowFailure = false;
        calls[0].callData =
            abi.encodeCall(DelegateOwner.setAdmin, (0x4757D97449acA795510b9f3152C6a9019A3545c3));

        calls[1].target = address(delegateOwner);
        calls[1].allowFailure = false;
        calls[1].callData =
            abi.encodeCall(DelegateOwner.setAdmin, (0x55d79345Afc87806B690C9f96c4D7BfE2Bca8268));

        DelegateOwner.Call memory dcall = DelegateOwner.Call({
            txId: 0, // Has to match with DelegateOwner's nextTxId
            target: multicall3,
            isDelegateCall: true,
            txdata: abi.encodeCall(TestMulticall3.aggregate3, (calls))
        });

        IBridge.Message memory message = IBridge.Message({
            id: 0,
            fee: 0,
            gasLimit: 1_000_000, // cannot be zero
            from: msg.sender,
            srcChainId: 1,
            srcOwner: msg.sender,
            destChainId: 167_000,
            destOwner: delegateOwner,
            to: delegateOwner,
            value: 0,
            data: abi.encode(dcall)
        });

        IBridge(l1Bridge).sendMessage(message);
    }
}
