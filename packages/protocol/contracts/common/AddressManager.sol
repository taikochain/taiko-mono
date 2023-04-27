// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

/* External Imports */
import {
    OwnableUpgradeable
} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @notice Interface to set and get an address for a name.
 */
interface IAddressManager {
    /**
     * Changes the address associated with a particular name.
     * @param domain Uint256 domain to assiciate an address with.
     * @param name Name hash to associate an address with.
     * @param newAddress Address to associate with the name.
     */
    function setAddress(
        uint256 domain,
        bytes32 name,
        address newAddress
    ) external;

    /**
     * Retrieves the address associated with a given name.
     * @param domain Class to retrieve an address for.
     * @param name Name hash to retrieve an address for.
     * @return Address associated with the given name.
     */
    function getAddress(
        uint256 domain,
        bytes32 name
    ) external view returns (address);
}

/**
 * @title AddressManager
 */
contract AddressManager is OwnableUpgradeable, IAddressManager {
    mapping(uint256 domain => mapping(bytes32 name => address addr))
        private addresses;

    event AddressSet(
        uint256 indexed _domain,
        bytes32 indexed _name,
        address _newAddress,
        address _oldAddress
    );

    /// @dev Initializer to be called after being deployed behind a proxy.
    function init() external initializer {
        OwnableUpgradeable.__Ownable_init();
    }

    function setAddress(
        uint256 domain,
        bytes32 name,
        address newAddress
    ) external virtual onlyOwner {
        address oldAddress = addresses[domain][name];
        addresses[domain][name] = newAddress;
        emit AddressSet(domain, name, newAddress, oldAddress);
    }

    function getAddress(
        uint256 domain,
        bytes32 name
    ) external view virtual returns (address addr) {
        addr = addresses[domain][name];
    }
}
