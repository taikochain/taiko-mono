// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "test/layer1/Layer1Test.sol";

contract GasComparision is Layer1Test {
    TaikoData.BlockV2 private blk;

    function test_save_block_gas_comparison() public {
        saveBlockAsWhole(
            TaikoData.BlockV2({
                metaHash: keccak256(abi.encodePacked("1")),
                blockId: 1,
                assignedProver: address(0),
                livenessBond: 0,
                proposedAt: 1,
                proposedIn: 1,
                nextTransitionId: 1,
                livenessBondReturned: true,
                verifiedTransitionId: 1
            })
        );

        uint256 gasUsedWhole;
        uint256 gasUsedFields;

        // Measure gas for saveBlockAsWhole
        vm.startSnapshotGas("saveBlockAsWhole");
        saveBlockAsWhole(
            TaikoData.BlockV2({
                metaHash: keccak256(abi.encodePacked("2")),
                blockId: 2,
                assignedProver: address(0),
                livenessBond: 0,
                proposedAt: 2,
                proposedIn: 2,
                nextTransitionId: 2,
                livenessBondReturned: true,
                verifiedTransitionId: 2
            })
        );
        gasUsedWhole = vm.stopSnapshotGas();

        // Measure gas for saveBlockAsFields
        vm.startSnapshotGas("saveBlockAsFields");
        saveBlockAsFields(
            TaikoData.BlockV2({
                metaHash: keccak256(abi.encodePacked("3")),
                blockId: 2,
                assignedProver: address(0),
                livenessBond: 0,
                proposedAt: 3,
                proposedIn: 3,
                nextTransitionId: 3,
                livenessBondReturned: true,
                verifiedTransitionId: 3
            })
        );
        gasUsedFields = vm.stopSnapshotGas();

        emit log_named_uint("Gas used by saveBlockAsWhole", gasUsedWhole);
        emit log_named_uint("Gas used by saveBlockAsFields", gasUsedFields);
    }

    function saveBlockAsWhole(TaikoData.BlockV2 memory _blk) internal {
        blk = _blk;
    }

    function saveBlockAsFields(TaikoData.BlockV2 memory _blk) internal {
        blk.metaHash = _blk.metaHash;
        blk.blockId = _blk.blockId;
        blk.proposedAt = _blk.proposedAt;
        blk.proposedIn = _blk.proposedIn;
        blk.nextTransitionId = _blk.nextTransitionId;
        blk.livenessBondReturned = _blk.livenessBondReturned;
        blk.verifiedTransitionId = _blk.verifiedTransitionId;
    }

    function test_read_block_gas_comparison() public {
        saveBlockAsWhole(
            TaikoData.BlockV2({
                metaHash: keccak256(abi.encodePacked("1")),
                blockId: 1,
                assignedProver: address(0),
                livenessBond: 0,
                proposedAt: 1,
                proposedIn: 1,
                nextTransitionId: 1,
                livenessBondReturned: true,
                verifiedTransitionId: 1
            })
        );

        // Measure gas for reading block as a whole
        vm.startSnapshotGas("readBlockAsWhole");
        TaikoData.BlockV2 memory blkWhole = readBlockAsWhole();
        uint256 gasUsedWhole = vm.stopSnapshotGas();

        // Measure gas for reading block fields separately
        vm.startSnapshotGas("readBlockAsFields");
        (uint256 proposedIn, uint256 proposedAt, bytes32 metaHash) = readBlockAsFields();
        uint256 gasUsedFields = vm.stopSnapshotGas();

        emit log_named_uint("Gas used by readBlockAsWhole", gasUsedWhole);
        emit log_named_uint("Gas used by readBlockAsFields", gasUsedFields);
    }

    function readBlockAsWhole() internal view returns (TaikoData.BlockV2 memory) {
        return blk;
    }

    function readBlockAsFields() internal view returns (uint256, uint256, bytes32) {
        return (blk.proposedIn, blk.proposedAt, blk.metaHash);
    }
}
