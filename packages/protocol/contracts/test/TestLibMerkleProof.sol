// SPDX-License-Identifier: MIT
//
// ╭━━━━╮╱╱╭╮╱╱╱╱╱╭╮╱╱╱╱╱╭╮
// ┃╭╮╭╮┃╱╱┃┃╱╱╱╱╱┃┃╱╱╱╱╱┃┃
// ╰╯┃┃┣┻━┳┫┃╭┳━━╮┃┃╱╱╭━━┫╰━┳━━╮
// ╱╱┃┃┃╭╮┣┫╰╯┫╭╮┃┃┃╱╭┫╭╮┃╭╮┃━━┫
// ╱╱┃┃┃╭╮┃┃╭╮┫╰╯┃┃╰━╯┃╭╮┃╰╯┣━━┃
// ╱╱╰╯╰╯╰┻┻╯╰┻━━╯╰━━━┻╯╰┻━━┻━━╯
pragma solidity ^0.8.9;

import "../libs/LibMerkleProof.sol";

contract TestLibMerkleProof {
    function verifyStorage(
        bytes32 stateRoot,
        address addr,
        bytes32 key,
        bytes32 value,
        bytes calldata mkproof
    ) public pure {
        return
            LibMerkleProof.verifyStorage(stateRoot, addr, key, value, mkproof);
    }

    function verifyFootprint(
        bytes32 root,
        uint256 index,
        bytes memory value,
        bytes calldata proof
    ) public pure {
        return LibMerkleProof.verifyFootprint(root, index, value, proof);
    }

    function setStorage(bytes32 key, bytes32 value) public {
        assembly {
            sstore(key, value)
        }
    }
}
