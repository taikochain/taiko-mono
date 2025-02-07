// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "src/shared/common/EssentialContract.sol";
import "src/shared/libs/LibStrings.sol";
import "src/layer1/based/ITaikoInbox.sol";
import "../iface/IPreconfRouter.sol";
import "../iface/IPreconfWhitelist.sol";

/// @title PreconfRouter
/// @custom:security-contact security@taiko.xyz
contract PreconfRouter is EssentialContract, IPreconfRouter {
    uint256[50] private __gap;

    constructor(address _resolver) EssentialContract(_resolver) { }

    function init(address _owner) external initializer {
        __Essential_init(_owner);
    }

    /// @inheritdoc ITaikoProposerEntryPoint
    function proposeBatch(
        bytes calldata _params,
        bytes calldata _txList
    )
        external
        returns (ITaikoInbox.BatchInfo memory info_, ITaikoInbox.BatchMetadata memory meta_)
    {
        // Sender must be the selected operator for the epoch
        address selectedOperator =
            IPreconfWhitelist(resolve(LibStrings.B_PRECONF_WHITELIST, false)).getOperatorForEpoch();
        require(msg.sender == selectedOperator, NotTheOperator());

        // check if we have a forced inclusion inbox
        address entryPoint = resolve(LibStrings.B_TAIKO_WRAPPER, true);
        if (entryPoint == address(0)) {
            entryPoint = resolve(LibStrings.B_TAIKO, false);
        }

        // Both TaikoInbox and TaikoWrapper implement the same ABI for proposeBatch.
        (info_, meta_) = ITaikoInbox(entryPoint).proposeBatch(_params, _txList);

        // Verify that the sender had set itself as the proposer
        require(meta_.proposer == msg.sender, ProposerIsNotTheSender());
    }
}
