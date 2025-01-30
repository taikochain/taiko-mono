// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "../../shared/CommonTest.sol";
import "src/layer1/forced-inclusion/ForcedInclusionStore.sol";

contract ForcedInclusionStoreForTest is ForcedInclusionStore {
    constructor(
        address _resolver,
        uint8 _inclusionDelay,
        uint64 _feeInGwei
    )
        ForcedInclusionStore(_resolver, _inclusionDelay, _feeInGwei)
    { }

    function _blobHash(uint8 blobIndex) internal view virtual override returns (bytes32) {
        return bytes32(uint256(blobIndex + 1));
    }
}

contract MockInbox {
    uint64 public numBatches;

    constructor() {
        numBatches = 1;
    }

    function setNumBatches(uint64 _numBatches) external {
        numBatches = _numBatches;
    }

    function getStats2() external view returns (ITaikoInbox.Stats2 memory stats2_) {
        stats2_.numBatches = numBatches;
    }
}

abstract contract ForcedInclusionStoreTestBase is CommonTest {
    address internal storeOwner = Alice;
    address internal whitelistedProposer = Alice;
    uint8 internal constant inclusionDelay = 12;
    uint64 internal constant feeInGwei = 0.001 ether / 1 gwei;

    ForcedInclusionStore internal store;
    MockInbox internal mockInbox;

    function setUpOnEthereum() internal virtual override {
        register(LibStrings.B_TAIKO_FORCED_INCLUSION_INBOX, whitelistedProposer);

        store = ForcedInclusionStore(
            deploy({
                name: LibStrings.B_FORCED_INCLUSION_STORE,
                impl: address(
                    new ForcedInclusionStoreForTest(address(resolver), inclusionDelay, feeInGwei)
                ),
                data: abi.encodeCall(ForcedInclusionStore.init, (storeOwner))
            })
        );

        mockInbox = new MockInbox();
        register(LibStrings.B_TAIKO, address(mockInbox));
    }
}

contract ForcedInclusionStoreTest is ForcedInclusionStoreTestBase {
    function test_storeForcedInclusion_success() public transactBy(Alice) {
        vm.deal(Alice, 1 ether);

        uint64 _feeInGwei = store.feeInGwei();

        for (uint8 i; i < 5; ++i) {
            store.storeForcedInclusion{ value: _feeInGwei * 1 gwei }({
                blobIndex: i,
                blobByteOffset: 0,
                blobByteSize: 1024
            });
            (
                bytes32 blobHash,
                uint64 feeInGwei,
                uint64 createdAt,
                uint32 blobByteOffset,
                uint32 blobByteSize
            ) = store.queue(store.tail() - 1);

            assertEq(blobHash, bytes32(uint256(i + 1))); //  = blobIndex + 1
            assertEq(createdAt, uint64(block.timestamp));
            assertEq(feeInGwei, _feeInGwei);
            assertEq(blobByteOffset, 0);
            assertEq(blobByteSize, 1024);
        }
    }

    function test_storeForcedInclusion_incorrectFee() public transactBy(Alice) {
        vm.deal(Alice, 1 ether);

        uint64 feeInGwei = store.feeInGwei();
        vm.expectRevert(IForcedInclusionStore.IncorrectFee.selector);
        store.storeForcedInclusion{ value: feeInGwei * 1 gwei - 1 }({
            blobIndex: 0,
            blobByteOffset: 0,
            blobByteSize: 1024
        });

        vm.expectRevert(IForcedInclusionStore.IncorrectFee.selector);
        store.storeForcedInclusion{ value: feeInGwei * 1 gwei + 1 }({
            blobIndex: 0,
            blobByteOffset: 0,
            blobByteSize: 1024
        });
    }

    function test_storeConsumeForcedInclusion_success() public {
        vm.deal(Alice, 1 ether);
        uint64 _feeInGwei = store.feeInGwei();

        mockInbox.setNumBatches(100);

        vm.prank(Alice);
        store.storeForcedInclusion{ value: _feeInGwei * 1 gwei }({
            blobIndex: 0,
            blobByteOffset: 0,
            blobByteSize: 1024
        });

        assertEq(store.head(), 0);
        assertEq(store.tail(), 1);

        IForcedInclusionStore.ForcedInclusion memory inclusion = store.getForcedInclusion(0);

        vm.prank(whitelistedProposer);
        inclusion = store.consumeOldestForcedInclusion(Bob);

        assertEq(inclusion.blobHash, bytes32(uint256(1)));
        assertEq(inclusion.blobByteOffset, 0);
        assertEq(inclusion.blobByteSize, 1024);
        assertEq(inclusion.feeInGwei, _feeInGwei);
        assertEq(inclusion.createdAtBatchId, 100);
        assertEq(Bob.balance, _feeInGwei * 1 gwei);
    }

    function test_storeConsumeForcedInclusion_notOperator() public {
        vm.deal(Alice, 1 ether);
        uint64 _feeInGwei = store.feeInGwei();

        mockInbox.setNumBatches(100);

        vm.prank(Alice);
        store.storeForcedInclusion{ value: _feeInGwei * 1 gwei }({
            blobIndex: 0,
            blobByteOffset: 0,
            blobByteSize: 1024
        });

        assertEq(store.head(), 0);
        assertEq(store.tail(), 1);

        vm.warp(block.timestamp + inclusionDelay);

        vm.prank(Carol);
        vm.expectRevert(EssentialContract.ACCESS_DENIED.selector);
        store.consumeOldestForcedInclusion(Bob);
    }

    function test_storeConsumeForcedInclusion_noEligibleInclusion() public {
        vm.prank(whitelistedProposer);
        vm.expectRevert(IForcedInclusionStore.NoForcedInclusionFound.selector);
        store.consumeOldestForcedInclusion(Bob);
    }

    function test_storeConsumeForcedInclusion_beforeWindowExpires() public {
        vm.deal(Alice, 1 ether);

        mockInbox.setNumBatches(100);

        vm.prank(whitelistedProposer);
        store.storeForcedInclusion{ value: store.feeInGwei() * 1 gwei }({
            blobIndex: 0,
            blobByteOffset: 0,
            blobByteSize: 1024
        });

        // Verify the stored reqeust is correct
        IForcedInclusionStore.ForcedInclusion memory inclusion = store.getForcedInclusion(0);

        assertEq(inclusion.blobHash, bytes32(uint256(1)));
        assertEq(inclusion.blobByteOffset, 0);
        assertEq(inclusion.blobByteSize, 1024);
        assertEq(inclusion.createdAtBatchId, mockInbox.numBatches());
        assertEq(inclusion.feeInGwei, store.feeInGwei());

        vm.warp(block.timestamp + inclusionDelay - 1);
        vm.prank(whitelistedProposer);

        // head request should be consumable
        inclusion = store.consumeOldestForcedInclusion(Bob);
        assertEq(inclusion.blobHash, bytes32(uint256(1)));
        assertEq(inclusion.blobByteOffset, 0);
        assertEq(inclusion.blobByteSize, 1024);
        assertEq(inclusion.createdAtBatchId, mockInbox.numBatches());
        assertEq(inclusion.feeInGwei, store.feeInGwei());

        // the head request should have been deleted
        inclusion = store.getForcedInclusion(0);
        assertEq(inclusion.blobHash, 0);
        assertEq(inclusion.blobByteOffset, 0);
        assertEq(inclusion.blobByteSize, 0);
        assertEq(inclusion.createdAtBatchId, 0);
        assertEq(inclusion.feeInGwei, 0);
    }
}
