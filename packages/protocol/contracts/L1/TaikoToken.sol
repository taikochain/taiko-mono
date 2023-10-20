// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.20;

import { ERC20SnapshotUpgradeable } from
    "lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20SnapshotUpgradeable.sol";
import { ERC20Upgradeable } from
    "lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/ERC20Upgradeable.sol";
import { ERC20VotesUpgradeable } from
    "lib/openzeppelin-contracts-upgradeable/contracts/token/ERC20/extensions/ERC20VotesUpgradeable.sol";

import { EssentialContract } from "../common/EssentialContract.sol";
import { Proxied } from "../common/Proxied.sol";

/// @title TaikoToken
/// @notice The TaikoToken (TKO), in the protocol is used for prover collateral
/// in the form of bonds. It is an ERC20 token with 18 decimal places of
/// precision.
contract TaikoToken is
    EssentialContract,
    ERC20SnapshotUpgradeable,
    ERC20VotesUpgradeable
{
    error TKO_INVALID_ADDR();
    error TKO_INVALID_PREMINT_PARAMS();

    /// @notice Initializes the TaikoToken contract and mints initial tokens to
    /// specified recipients.
    /// @param _addressManager The {AddressManager} address.
    /// @param _name The name of the token.
    /// @param _symbol The symbol of the token.
    /// @param _premintRecipients An array of addresses to receive initial token
    /// minting.
    /// @param _premintAmounts An array of token amounts to mint for each
    /// corresponding recipient.
    function init(
        address _addressManager,
        string calldata _name,
        string calldata _symbol,
        address[] calldata _premintRecipients,
        uint256[] calldata _premintAmounts
    )
        public
        initializer
    {
        EssentialContract._init(_addressManager);
        ERC20Upgradeable.__ERC20_init_unchained(_name, _symbol);
        ERC20SnapshotUpgradeable.__ERC20Snapshot_init_unchained();
        ERC20VotesUpgradeable.__ERC20Votes_init_unchained();

        for (uint256 i; i < _premintRecipients.length; ++i) {
            _mint(_premintRecipients[i], _premintAmounts[i]);
        }
    }

    /// @notice Creates a new token snapshot.
    function snapshot() public onlyOwner {
        _snapshot();
    }

    /// @notice Transfers tokens to a specified address.
    /// @param to The address to transfer tokens to.
    /// @param amount The amount of tokens to transfer.
    /// @return A boolean indicating whether the transfer was successful or not.
    function transfer(
        address to,
        uint256 amount
    )
        public
        override
        returns (bool)
    {
        if (to == address(this)) revert TKO_INVALID_ADDR();
        return super.transfer(to, amount);
    }

    /// @notice Transfers tokens from one address to another.
    /// @param from The address to transfer tokens from.
    /// @param to The address to transfer tokens to.
    /// @param amount The amount of tokens to transfer.
    /// @return A boolean indicating whether the transfer was successful or not.
    function transferFrom(
        address from,
        address to,
        uint256 amount
    )
        public
        override
        returns (bool)
    {
        if (to == address(this)) revert TKO_INVALID_ADDR();
        return super.transferFrom(from, to, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    )
        internal
        override(ERC20Upgradeable, ERC20SnapshotUpgradeable)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    )
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._afterTokenTransfer(from, to, amount);
    }

    function _mint(
        address to,
        uint256 amount
    )
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._mint(to, amount);
    }

    function _burn(
        address from,
        uint256 amount
    )
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._burn(from, amount);
    }
}

/// @title ProxiedTaikoToken
/// @notice Proxied version of the TaikoToken contract.
contract ProxiedTaikoToken is Proxied, TaikoToken { }
