// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/introspection/IERC165Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC6372Upgradeable.sol";
import "../common/EssentialContract.sol";
import "../common/LibStrings.sol";

/// @notice TaikoToken was `EssentialContract, ERC20SnapshotUpgradeable, ERC20VotesUpgradeable`.
/// We use this contract to take 50 more slots to remove `ERC20SnapshotUpgradeable` from the parent
/// contract list.
/// We can simplify the code since we no longer need to maintain upgradability with Hekla.
// solhint-disable contract-name-camelcase
abstract contract TaikoTokenBase0 is EssentialContract {
    // solhint-disable var-name-mixedcase
    uint256[50] private __slots_previously_used_by_ERC20SnapshotUpgradeable;
}

/// @title TaikoTokenBase
/// @notice The base contract for both the canonical and the bridged Taiko token.
/// @custom:security-contact security@taiko.xyz
abstract contract TaikoTokenBase is TaikoTokenBase0, ERC20VotesUpgradeable, IERC165Upgradeable {
    uint256[50] private __gap;

    function clock() public view override returns (uint48) {
        return SafeCastUpgradeable.toUint48(block.timestamp);
    }

    // solhint-disable-next-line func-name-mixedcase
    function CLOCK_MODE() public pure override returns (string memory) {
        // See https://eips.ethereum.org/EIPS/eip-6372
        return "mode=timestamp";
    }

    /// @notice Checks if the contract supports the given interface.
    /// @param _interfaceId The interface identifier.
    /// @return true if the contract supports the interface, false otherwise.
    function supportsInterface(bytes4 _interfaceId) public view virtual override returns (bool) {
        return _interfaceId == type(IERC6372Upgradeable).interfaceId
            || _interfaceId == type(IERC165Upgradeable).interfaceId;
    }
}
