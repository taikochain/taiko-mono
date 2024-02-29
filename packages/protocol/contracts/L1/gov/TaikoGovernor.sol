// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts-upgradeable/governance/GovernorUpgradeable.sol";
import
    "@openzeppelin/contracts-upgradeable/governance/compatibility/GovernorCompatibilityBravoUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesUpgradeable.sol";
import
    "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol";
import
    "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorTimelockControlUpgradeable.sol";
import "../../common/EssentialContract.sol";

/// @title TaikoGovernor
/// @custom:security-contact security@taiko.xyz
contract TaikoGovernor is
    EssentialContract,
    GovernorCompatibilityBravoUpgradeable,
    GovernorVotesUpgradeable,
    GovernorVotesQuorumFractionUpgradeable,
    GovernorTimelockControlUpgradeable
{
    uint256[50] private __gap;

    error TG_INVALID_SIGNATURES_LENGTH();

    /// @notice Initializes the contract.
    /// @param _owner The owner of this contract. msg.sender will be used if this value is zero.
    /// @param _token The Taiko token.
    /// @param _timelock The timelock contract address.
    function init(
        address _owner,
        IVotesUpgradeable _token,
        TimelockControllerUpgradeable _timelock
    )
        external
        initializer
    {
        _Essential_init(_owner);
        __Governor_init("TaikoGovernor");
        __GovernorCompatibilityBravo_init();
        __GovernorVotes_init(_token);
        __GovernorVotesQuorumFraction_init(4);
        __GovernorTimelockControl_init(_timelock);
    }

    /// @dev See {IGovernor-propose}
    function propose(
        address[] memory _targets,
        uint256[] memory _values,
        bytes[] memory _calldatas,
        string memory _description
    )
        public
        override(IGovernorUpgradeable, GovernorUpgradeable, GovernorCompatibilityBravoUpgradeable)
        returns (uint256)
    {
        return super.propose(_targets, _values, _calldatas, _description);
    }

    /// @notice An overwrite of GovernorCompatibilityBravoUpgradeable's propose() as that one does
    /// not checks the length of signatures equal to calldatas.
    /// See vulnerability description here:
    /// https://github.com/taikoxyz/taiko-mono/security/dependabot/114
    /// See fix in OZ 4.8.3 here:
    /// https://github.com/OpenZeppelin/openzeppelin-contracts/blob/0a25c1940ca220686588c4af3ec526f725fe2582/contracts/governance/compatibility/GovernorCompatibilityBravo.sol#L72
    /// @dev See {GovernorCompatibilityBravoUpgradeable-propose}
    function propose(
        address[] memory _targets,
        uint256[] memory _values,
        string[] memory _signatures,
        bytes[] memory _calldatas,
        string memory _description
    )
        public
        virtual
        override(GovernorCompatibilityBravoUpgradeable)
        returns (uint256)
    {
        if (_signatures.length != _calldatas.length) revert TG_INVALID_SIGNATURES_LENGTH();

        return GovernorCompatibilityBravoUpgradeable.propose(
            _targets, _values, _signatures, _calldatas, _description
        );
    }

    function supportsInterface(bytes4 _interfaceId)
        public
        view
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable, IERC165Upgradeable)
        returns (bool)
    {
        return super.supportsInterface(_interfaceId);
    }

    function state(uint256 _proposalId)
        public
        view
        override(IGovernorUpgradeable, GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (ProposalState)
    {
        return super.state(_proposalId);
    }

    // How long after a proposal is created should voting power be fixed. A
    // large voting delay gives users time to unstake tokens if necessary.
    function votingDelay() public pure override returns (uint256) {
        return 7200; // 1 day
    }

    // How long does a proposal remain open to votes.
    function votingPeriod() public pure override returns (uint256) {
        return 50_400; // 1 week
    }

    // The number of votes required in order for a voter to become a proposer
    function proposalThreshold() public pure override returns (uint256) {
        return 1_000_000_000 ether / 10_000; // 0.01% of Taiko Token
    }

    function _execute(
        uint256 _proposalId,
        address[] memory _targets,
        uint256[] memory _values,
        bytes[] memory _calldatas,
        bytes32 _descriptionHash
    )
        internal
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
    {
        super._execute(_proposalId, _targets, _values, _calldatas, _descriptionHash);
    }

    function _cancel(
        address[] memory _targets,
        uint256[] memory _values,
        bytes[] memory _calldatas,
        bytes32 _descriptionHash
    )
        internal
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (uint256)
    {
        return super._cancel(_targets, _values, _calldatas, _descriptionHash);
    }

    function _executor()
        internal
        view
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (address)
    {
        return super._executor();
    }
}
