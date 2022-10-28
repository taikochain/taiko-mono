// SPDX-License-Identifier: MIT
//
// ╭━━━━╮╱╱╭╮╱╱╱╱╱╭╮╱╱╱╱╱╭╮
// ┃╭╮╭╮┃╱╱┃┃╱╱╱╱╱┃┃╱╱╱╱╱┃┃
// ╰╯┃┃┣┻━┳┫┃╭┳━━╮┃┃╱╱╭━━┫╰━┳━━╮
// ╱╱┃┃┃╭╮┣┫╰╯┫╭╮┃┃┃╱╭┫╭╮┃╭╮┃━━┫
// ╱╱┃┃┃╭╮┃┃╭╮┫╰╯┃┃╰━╯┃╭╮┃╰╯┣━━┃
// ╱╱╰╯╰╯╰┻┻╯╰┻━━╯╰━━━┻╯╰┻━━┻━━╯
pragma solidity ^0.8.9;

import "../../../bridge/libs/LibBridgeData.sol";
import "../../../bridge/libs/LibBridgeSignal.sol";

contract TestLibBridgeSignal {
    function sendSignal(address sender, bytes32 signal) public {
        LibBridgeSignal.sendSignal(sender, signal);
    }

    function isSignalSent(address sender, bytes32 signal)
        public
        view
        returns (bool)
    {
        return LibBridgeSignal.isSignalSent(sender, signal);
    }

    function decode(bytes memory proof)
        public
        pure
        returns (LibBridgeSignal.SignalProof memory)
    {
        LibBridgeSignal.SignalProof memory mkp = abi.decode(
            proof,
            (LibBridgeSignal.SignalProof)
        );

        return mkp;
    }
}
