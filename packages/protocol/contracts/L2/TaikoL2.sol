// SPDX-License-Identifier: MIT
//
// ╭━━━━╮╱╱╭╮╱╱╱╱╱╭╮╱╱╱╱╱╭╮
// ┃╭╮╭╮┃╱╱┃┃╱╱╱╱╱┃┃╱╱╱╱╱┃┃
// ╰╯┃┃┣┻━┳┫┃╭┳━━╮┃┃╱╱╭━━┫╰━┳━━╮
// ╱╱┃┃┃╭╮┣┫╰╯┫╭╮┃┃┃╱╭┫╭╮┃╭╮┃━━┫
// ╱╱┃┃┃╭╮┃┃╭╮┫╰╯┃┃╰━╯┃╭╮┃╰╯┣━━┃
// ╱╱╰╯╰╯╰┻┻╯╰┻━━╯╰━━━┻╯╰┻━━┻━━╯
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../common/EssentialContract.sol";
import "../libs/LibStorageProof.sol";
import "../libs/LibTxList.sol";

contract TaikoL2 is EssentialContract {
    /**********************
     * State Variables    *
     **********************/

    mapping(uint256 => bytes32) public anchorHashes;
    uint256 public lastAnchorHeight;

    uint256[48] private __gap;

    /**********************
     * Events             *
     **********************/

    event Anchored(
        uint256 anchorHeight,
        bytes32 anchorHash,
        bytes32 proofKey,
        bytes32 proofVal
    );

    event EtherCredited(address receipient, uint256 amount);
    event EtherReturned(address receipient, uint256 amount);

    /**********************
     * Modifiers          *
     **********************/

    modifier onlyWhenNotAnchored() {
        require(lastAnchorHeight < block.number, "L2:anchored already");
        lastAnchorHeight = block.number;
        _;
    }

    /**********************
     * External Functions *
     **********************/

    receive() external payable onlyFromNamed("bridge_helper") {
        emit EtherReturned(msg.sender, msg.value);
    }

    function init(address _addressManager) external initializer {
        EssentialContract._init(_addressManager);
    }

    function creditEther(address receipient, uint256 amount)
        external
        nonReentrant
        onlyFromNamed("bridge_helper")
    {
        require(receipient != address(this), "L2:invalid address");
        payable(receipient).transfer(amount);
        emit EtherCredited(receipient, amount);
    }

    function anchor(uint256 anchorHeight, bytes32 anchorHash)
        external
        onlyWhenNotAnchored
    {
        require(anchorHeight != 0 && anchorHash != 0x0, "L2:invalid anchor");

        if (anchorHashes[anchorHeight] == 0x0) {
            anchorHashes[anchorHeight] = anchorHash;

            (bytes32 proofKey, bytes32 proofVal) = LibStorageProof
                .computeAnchorProofKV(block.number, anchorHeight, anchorHash);

            assembly {
                sstore(proofKey, proofVal)
            }

            emit Anchored(anchorHeight, anchorHash, proofKey, proofVal);
        }
    }

    function verifyBlockInvalid(bytes calldata txList) external {
        require(
            !LibTxListValidator.isTxListValid(txList),
            "L2:txList is valid"
        );

        (bytes32 proofKey, bytes32 proofVal) = LibStorageProof
            .computeInvalidTxListProofKV(keccak256(txList));

        assembly {
            sstore(proofKey, proofVal)
        }
    }
}
