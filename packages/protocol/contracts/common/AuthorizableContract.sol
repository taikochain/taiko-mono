pragma solidity ^0.8.20;

import { EssentialContract } from "../common/EssentialContract.sol";

/// @title AuthorizableContract
abstract contract AuthorizableContract is EssentialContract {
    mapping(address => bytes32 label) public authorizedAddresses;
    uint256[49] private __gap;

    event Authorized(address indexed addr, bytes32 oldLabel, bytes32 newLabel);

    error ADDRESS_UNAUTHORIZED();
    error INVALID_ADDRESS();
    error INVALID_LABEL();

    modifier onlyAuthorized() {
        if (!isAuthorized(msg.sender)) revert ADDRESS_UNAUTHORIZED();
        _;
    }

    function authorize(address addr, bytes32 label) external onlyOwner {
        if (addr == address(0)) revert INVALID_ADDRESS();

        bytes32 oldLabel = authorizedAddresses[addr];
        if (oldLabel == label) revert INVALID_LABEL();
        authorizedAddresses[addr] = label;

        emit Authorized(addr, oldLabel, label);
    }

    function isAuthorized(address addr) public view returns (bool) {
        return addr != address(0) && authorizedAddresses[addr] != 0;
    }

    function _init(address _addressManager) internal virtual override {
        if (_addressManager == address(0)) revert INVALID_ADDRESS();
        EssentialContract._init(_addressManager);
    }

    function _init() internal virtual {
        EssentialContract._init(address(0));
    }
}
