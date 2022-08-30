// SPDX-License-Identifier: MIT
//
// ╭━━━━╮╱╱╭╮╱╱╱╱╱╭╮╱╱╱╱╱╭╮
// ┃╭╮╭╮┃╱╱┃┃╱╱╱╱╱┃┃╱╱╱╱╱┃┃
// ╰╯┃┃┣┻━┳┫┃╭┳━━╮┃┃╱╱╭━━┫╰━┳━━╮
// ╱╱┃┃┃╭╮┣┫╰╯┫╭╮┃┃┃╱╭┫╭╮┃╭╮┃━━┫
// ╱╱┃┃┃╭╮┃┃╭╮┫╰╯┃┃╰━╯┃╭╮┃╰╯┣━━┃
// ╱╱╰╯╰╯╰┻┻╯╰┻━━╯╰━━━┻╯╰┻━━┻━━╯
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "../common/EssentialContract.sol";
import "../libs/LibInvalidTxList.sol";
import "../libs/LibFootprint.sol";
import "../libs/LibTaikoConstants.sol";
import "../libs/LibTxListDecoder.sol";

contract TaikoL2 is EssentialContract {
    using LibTxListDecoder for bytes;
    /**********************
     * State Variables    *
     **********************/

    mapping(uint256 => bytes32) public blockHashes;
    mapping(uint256 => bytes32) public anchorHashes;
    uint256 public chainId;
    uint256 public lastAnchorHeight;

    uint256[46] private __gap;

    /**********************
     * Events             *
     **********************/

    event Footprint(bytes32 value);
    event BlockInvalidated(address invalidator);
    event EtherCredited(address recipient, uint256 amount);
    event EtherReturned(address recipient, uint256 amount);

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

    receive() external payable onlyFromNamed("eth_depositor") {
        emit EtherReturned(msg.sender, msg.value);
    }

    fallback() external payable {
        revert("L2:not allowed");
    }

    function init(address _addressManager, uint256 _chainId)
        external
        initializer
    {
        EssentialContract._init(_addressManager);
        chainId = _chainId;
    }

    function creditEther(address recipient, uint256 amount)
        external
        nonReentrant
        onlyFromNamed("eth_depositor")
    {
        require(
            recipient != address(0) && recipient != address(this),
            "L2:invalid address"
        );
        payable(recipient).transfer(amount);
        emit EtherCredited(recipient, amount);
    }

    /// @dev This transaciton must be the last transaction in a L2 block
    /// in addition to the txList.
    function anchor(uint256 anchorHeight, bytes32 anchorHash)
        external
        onlyWhenNotAnchored
    {
        require(anchorHeight != 0 && anchorHash != 0, "L2:0 anchor value");
        anchorHashes[anchorHeight] = anchorHash;

        _checkGlobalVariables();

        emit Footprint(
            LibFootprint.computeAnchorFootprint(
                block.number,
                blockhash(block.number - 1),
                anchorHeight,
                anchorHash
            )
        );
    }

    function verifyTxListInvalid(
        bytes calldata txList,
        LibInvalidTxList.Reason hint,
        uint256 txIdx
    ) external {
        LibInvalidTxList.Reason reason = LibInvalidTxList.isTxListInvalid(
            txList,
            hint,
            txIdx
        );
        require(
            reason != LibInvalidTxList.Reason.OK,
            "L2:failed to invalidate txList"
        );

        _checkGlobalVariables();

        emit Footprint(
            LibFootprint.computeBlockInvalidationFootprint(
                block.number,
                blockhash(block.number - 1),
                txList.hashTxList()
            )
        );
    }

    function _checkGlobalVariables() private {
        // Check chainid
        require(block.chainid == chainId, "L2:invalid chain id");

        // Check base fee
        require(block.basefee == 0, "L2:invalid base fee");

        // Check the latest 255 block hashes match the storage version.
        for (uint256 i = 2; i <= 256 && block.number >= i; i++) {
            uint256 j = block.number - i;
            require(blockHashes[j] == blockhash(j), "L2:invalid ancestor hash");
        }

        // Store parent hash into storage tree.
        blockHashes[block.number - 1] = blockhash(block.number - 1);
    }
}
