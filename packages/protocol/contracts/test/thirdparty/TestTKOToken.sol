// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {TkoToken} from "../../L1/TkoToken.sol";

contract TestTkoToken is TkoToken {
    function mintAnyone(address account, uint256 amount) public {
        _mint(account, amount);
    }
}
