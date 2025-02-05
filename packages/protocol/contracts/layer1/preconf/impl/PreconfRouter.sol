// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "src/shared/common/EssentialContract.sol";
import "src/shared/libs/LibStrings.sol";
import "src/layer1/based/TaikoInbox.sol";
import "src/layer1/forced-inclusion/TaikoWrapper.sol";
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

    /// @inheritdoc IPreconfRouter
    function proposePreconfedBlocks(
        bytes calldata _forcedInclusionParams,
        bytes calldata _batchParams,
        bytes calldata _batchTxList
    )
        external
        returns (ITaikoInbox.BatchMetadata memory meta_)
    {
        // Sender must be the selected operator for the epoch
        address selectedOperator =
            IPreconfWhitelist(resolve(LibStrings.B_PRECONF_WHITELIST, false)).getOperatorForEpoch();
        require(msg.sender == selectedOperator, NotTheOperator());

        // check if we have a forced inclusion inbox
        address wrapper = resolve(LibStrings.B_TAIKO_WRAPPER, true);
        if (wrapper == address(0)) {
            require(_forcedInclusionParams.length == 0, ForcedInclusionNotSupported());
            address taikoInbox = resolve(LibStrings.B_TAIKO, false);
            (, meta_) = ITaikoInbox(taikoInbox).proposeBatch(_batchParams, _batchTxList);
        } else {
            (, meta_) = TaikoWrapper(wrapper).proposeBatchWithForcedInclusion(
                _forcedInclusionParams, _batchParams, _batchTxList
            );
        }

        // Verify that the sender had set itself as the proposer
        require(meta_.proposer == msg.sender, ProposerIsNotTheSender());
    }
}
