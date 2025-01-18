// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./RouterTestBase.sol";
import "../mocks/MockBeaconBlockRoot.sol";
import "src/layer1/based/ITaikoInbox.sol";

contract RouterTest is RouterTestBase {
    function test_proposePreconfedBlocks() external {
        address[] memory operators = new address[](3);
        operators[0] = Bob;
        operators[1] = Carol;
        operators[2] = David;
        addOperators(operators);

        // Setup mock beacon for operator selection
        vm.chainId(1);
        uint256 epochOneStart = LibPreconfConstants.getGenesisTimestamp(block.chainid);
        // Current epoch
        uint256 epochTwoStart = epochOneStart + LibPreconfConstants.SECONDS_IN_EPOCH;

        MockBeaconBlockRoot mockBeacon = new MockBeaconBlockRoot();
        bytes32 mockRoot = bytes32(uint256(1)); // This will select Carol

        address beaconBlockRootContract = LibPreconfConstants.getBeaconBlockRootContract();
        vm.etch(beaconBlockRootContract, address(mockBeacon).code);
        MockBeaconBlockRoot(payable(beaconBlockRootContract)).set(
            epochOneStart + LibPreconfConstants.SECONDS_IN_SLOT, mockRoot
        );

        // Setup block params
        ITaikoInbox.BlockParams[] memory blockParams = new ITaikoInbox.BlockParams[](1);
        blockParams[0] = ITaikoInbox.BlockParams({ numTransactions: 1, timeShift: 1 });

        // Create batch params with correct structure
        ITaikoInbox.BatchParams memory params = ITaikoInbox.BatchParams({
            proposer: address(0),
            coinbase: address(0),
            parentMetaHash: bytes32(0),
            anchorBlockId: 0,
            anchorInput: bytes32(0),
            lastBlockTimestamp: uint64(block.timestamp),
            txListOffset: 0,
            txListSize: 0,
            firstBlobIndex: 0,
            numBlobs: 0,
            revertIfNotFirstProposal: false,
            signalSlots: new bytes32[](0),
            blocks: blockParams
        });

        // Warp to arbitrary slot in epoch 2
        vm.warp(epochTwoStart + 2 * LibPreconfConstants.SECONDS_IN_SLOT);

        // Prank as Carol (selected operator) and propose blocks
        vm.prank(Carol);
        ITaikoInbox.BatchMetadata memory meta =
            router.proposePreconfedBlocks("", abi.encode(params), "");

        // Assert the proposer was set correctly in the metadata
        assertEq(meta.proposer, Carol);
    }

    function test_proposePreconfedBlocks_notOperator() external {
        address[] memory operators = new address[](3);
        operators[0] = Bob;
        operators[1] = Carol;
        operators[2] = David;
        addOperators(operators);

        // Setup mock beacon for operator selection
        vm.chainId(1);
        uint256 epochOneStart = LibPreconfConstants.getGenesisTimestamp(block.chainid);
        MockBeaconBlockRoot mockBeacon = new MockBeaconBlockRoot();
        // Current epoch
        uint256 epochTwoStart = epochOneStart + LibPreconfConstants.SECONDS_IN_EPOCH;

        bytes32 mockRoot = bytes32(uint256(1)); // This will select Carol

        address beaconBlockRootContract = LibPreconfConstants.getBeaconBlockRootContract();
        vm.etch(beaconBlockRootContract, address(mockBeacon).code);
        MockBeaconBlockRoot(payable(beaconBlockRootContract)).set(
            epochOneStart + LibPreconfConstants.SECONDS_IN_SLOT, mockRoot
        );

        // Warp to arbitrary slot in epoch 2
        vm.warp(epochTwoStart + 2 * LibPreconfConstants.SECONDS_IN_SLOT);

        // Prank as David (not the selected oeprator) and propose blocks
        vm.prank(David);
        vm.expectRevert(IPreconfRouter.NOT_THE_OPERATOR.selector);
        router.proposePreconfedBlocks("", "", "");
    }
}
