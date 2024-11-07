// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../TaikoTest.sol";

// A contract which is not our ErcXXXTokenVault
// Which in such case, the sent funds are still recoverable, but not via the
// onMessageRecall() but Bridge will send it back
contract UntrustedSendMessageRelayer {
    function sendMessage(
        address bridge,
        IBridge.Message memory message,
        uint256 message_value
    )
        public
        returns (bytes32 msgHash, IBridge.Message memory updatedMessage)
    {
        return IBridge(bridge).sendMessage{ value: message_value }(message);
    }
}

// A malicious contract that attempts to exhaust gas
contract MaliciousContract2 {
    fallback() external payable {
        while (true) { } // infinite loop
    }
}

// Non malicious contract that does not exhaust gas
contract NonMaliciousContract1 {
    fallback() external payable { }
}

contract BridgeTest is TaikoTest {
    DefaultResolver resolver;
    BadReceiver badReceiver;
    GoodReceiver goodReceiver;
    Bridge bridge;
    Bridge destBridge;
    SignalService signalService;
    SignalService destSignalService;
    UntrustedSendMessageRelayer untrustedSenderContract;

    NonMaliciousContract1 nonmaliciousContract1;
    MaliciousContract2 maliciousContract2;

    address mockDAO = randAddress(); //as "real" L1 owner

    uint64 chainId;
    uint64 destChainId;

    function setUp() public {
        vm.startPrank(Alice);
        vm.deal(Alice, 100 ether);

        chainId = uint64(block.chainid);
        destChainId = chainId + 1;

        goodReceiver = new GoodReceiver();
        badReceiver = new BadReceiver();

        // Deploy on local chain
        resolver = deployDefaultResolver();

        bridge = deployBridge(resolver, address(new Bridge()));
        signalService = deploySignalService(resolver, address(new SignalServiceNoProofCheck()));
        untrustedSenderContract = new UntrustedSendMessageRelayer();
        vm.deal(address(untrustedSenderContract), 10 ether);

        // Deploy on destination chain
        vm.chainId(destChainId);
        destSignalService = deploySignalService(resolver, address(new SignalService()));
        destBridge = deployBridge(resolver, address(new Bridge()));
        vm.deal(address(destBridge), 100 ether);
        vm.chainId(chainId);

        // Register contracts from destination chain
        resolver.setAddress(destChainId, "taiko", address(uint160(123)));
        resolver.setAddress(destChainId, "bridge_watchdog", address(uint160(123)));

        vm.stopPrank();
    }

    function test_Bridge_send_ether_to_to_with_value() public {
        IBridge.Message memory message = IBridge.Message({
            id: 0,
            from: address(bridge),
            srcChainId: uint64(block.chainid),
            destChainId: destChainId,
            srcOwner: Alice,
            destOwner: Alice,
            to: Alice,
            value: 10_000,
            fee: 1000,
            gasLimit: 1_000_000,
            data: ""
        });
        // Mocking proof - but obviously it needs to be created in prod
        // corresponding to the message
        bytes memory proof = hex"00";

        bytes32 msgHash = destBridge.hashMessage(message);

        vm.chainId(destChainId);
        vm.prank(Bob, Bob);
        destBridge.processMessage(message, proof);

        IBridge.Status status = destBridge.messageStatus(msgHash);

        assertEq(status == IBridge.Status.DONE, true);
        // Alice has 100 ether + 1000 wei balance, because we did not use the
        // 'sendMessage'
        // since we mocking the proof, so therefore the 1000 wei
        // deduction/transfer did not happen
        assertTrue(Alice.balance >= 100 ether + 10_000);
        assertTrue(Alice.balance <= 100 ether + 10_000 + 1000);
        assertTrue(Bob.balance >= 0 && Bob.balance <= 1000);
    }

    function test_Bridge_send_ether_to_contract_with_value_simple() public {
        IBridge.Message memory message = IBridge.Message({
            id: 0,
            from: address(bridge),
            srcChainId: uint64(block.chainid),
            destChainId: destChainId,
            srcOwner: Alice,
            destOwner: Alice,
            to: address(goodReceiver),
            value: 10_000,
            fee: 1000,
            gasLimit: 1_000_000,
            data: ""
        });
        // Mocking proof - but obviously it needs to be created in prod
        // corresponding to the message
        bytes memory proof = hex"00";

        bytes32 msgHash = destBridge.hashMessage(message);

        vm.chainId(destChainId);
        vm.prank(Bob, Bob);
        destBridge.processMessage(message, proof);

        IBridge.Status status = destBridge.messageStatus(msgHash);

        assertEq(status == IBridge.Status.DONE, true);

        // Bob (relayer) and goodContract has 1000 wei balance
        assertEq(address(goodReceiver).balance, 10_000);
        console2.log("Bob.balance:", Bob.balance);
        assertTrue(Bob.balance >= 0 && Bob.balance <= 1000);
    }

    function test_Bridge_send_ether_to_contract_with_value_and_message_data() public {
        IBridge.Message memory message = IBridge.Message({
            id: 0,
            from: address(bridge),
            srcChainId: uint64(block.chainid),
            destChainId: destChainId,
            srcOwner: Alice,
            destOwner: Alice,
            to: address(goodReceiver),
            value: 1000,
            fee: 1000,
            gasLimit: 1_000_000,
            data: abi.encodeCall(GoodReceiver.onMessageInvocation, abi.encode(Carol))
        });
        // Mocking proof - but obviously it needs to be created in prod
        // corresponding to the message
        bytes memory proof = hex"00";

        bytes32 msgHash = destBridge.hashMessage(message);

        vm.chainId(destChainId);
        vm.prank(Bob, Bob);
        destBridge.processMessage(message, proof);

        IBridge.Status status = destBridge.messageStatus(msgHash);

        assertEq(status == IBridge.Status.DONE, true);

        // Carol and goodContract has 500 wei balance
        assertEq(address(goodReceiver).balance, 500);
        assertEq(Carol.balance, 500);
    }

    function test_Bridge_send_message_ether_reverts_if_value_doesnt_match_expected() public {
        // uint256 amount = 1 wei;
        IBridge.Message memory message = newMessage({
            owner: Alice,
            to: Alice,
            value: 0,
            gasLimit: 1_000_000,
            fee: 1_000_000,
            destChain: destChainId
        });

        vm.expectRevert(Bridge.B_INVALID_VALUE.selector);
        bridge.sendMessage(message);
    }

    function test_Bridge_send_message_ether_reverts_when_owner_is_zero_address() public {
        uint256 amount = 1 wei;
        IBridge.Message memory message = newMessage({
            owner: address(0),
            to: Alice,
            value: 0,
            gasLimit: 0,
            fee: 0,
            destChain: destChainId
        });

        vm.expectRevert(EssentialContract.ZERO_ADDRESS.selector);
        bridge.sendMessage{ value: amount }(message);
    }

    function test_Bridge_send_message_ether_reverts_when_dest_chain_is_not_enabled() public {
        uint256 amount = 1 wei;
        IBridge.Message memory message = newMessage({
            owner: Alice,
            to: Alice,
            value: 0,
            gasLimit: 0,
            fee: 0,
            destChain: destChainId + 1
        });

        vm.expectRevert(Bridge.B_INVALID_CHAINID.selector);
        bridge.sendMessage{ value: amount }(message);
    }

    function test_Bridge_send_message_ether_reverts_when_dest_chain_same_as_block_chainid()
        public
    {
        uint256 amount = 1 wei;
        IBridge.Message memory message = newMessage({
            owner: Alice,
            to: Alice,
            value: 0,
            gasLimit: 0,
            fee: 0,
            destChain: uint64(block.chainid)
        });

        vm.expectRevert(Bridge.B_INVALID_CHAINID.selector);
        bridge.sendMessage{ value: amount }(message);
    }

    function test_Bridge_send_message_ether_with_no_processing_fee() public {
        uint256 amount = 0 wei;
        IBridge.Message memory message = newMessage({
            owner: Alice,
            to: Alice,
            value: 0,
            gasLimit: 0,
            fee: 0,
            destChain: destChainId
        });

        (, IBridge.Message memory _message) = bridge.sendMessage{ value: amount }(message);
        assertEq(bridge.isMessageSent(_message), true);
    }

    function test_Bridge_send_message_ether_with_processing_fee() public {
        uint256 amount = 0 wei;
        uint64 fee = 1_000_000 wei;
        IBridge.Message memory message = newMessage({
            owner: Alice,
            to: Alice,
            value: 0,
            gasLimit: 1_000_000,
            fee: fee,
            destChain: destChainId
        });

        (, IBridge.Message memory _message) = bridge.sendMessage{ value: amount + fee }(message);
        assertEq(bridge.isMessageSent(_message), true);
    }

    function test_Bridge_recall_message_ether() public {
        uint256 amount = 1 ether;
        uint64 fee = 0 wei;
        IBridge.Message memory message = newMessage({
            owner: Alice,
            to: Alice,
            value: amount,
            gasLimit: 0,
            fee: fee,
            destChain: destChainId
        });

        uint256 starterBalanceVault = address(bridge).balance;
        uint256 starterBalanceAlice = Alice.balance;

        vm.prank(Alice, Alice);
        (, IBridge.Message memory _message) = bridge.sendMessage{ value: amount + fee }(message);
        assertEq(bridge.isMessageSent(_message), true);

        assertEq(address(bridge).balance, (starterBalanceVault + amount + fee));
        assertEq(Alice.balance, (starterBalanceAlice - (amount + fee)));
        bridge.recallMessage(message, "");

        assertEq(address(bridge).balance, (starterBalanceVault + fee));
        assertEq(Alice.balance, (starterBalanceAlice - fee));
    }

    function test_Bridge_recall_message_but_not_supports_recall_interface() public {
        // In this test we expect that the 'message value is still refundable,
        // just not via
        // ERCXXTokenVault (message.from) but directly from the Bridge

        uint256 amount = 1 ether;
        uint64 fee = 0 wei;
        IBridge.Message memory message = newMessage({
            owner: Alice,
            to: Alice,
            value: amount,
            gasLimit: 0,
            fee: fee,
            destChain: destChainId
        });

        uint256 starterBalanceVault = address(bridge).balance;

        (, message) = untrustedSenderContract.sendMessage(address(bridge), message, amount + fee);

        assertEq(address(bridge).balance, (starterBalanceVault + amount + fee));

        bridge.recallMessage(message, "");

        assertEq(address(bridge).balance, (starterBalanceVault + fee));
    }

    function test_Bridge_send_message_ether_with_processing_fee_invalid_amount() public {
        uint256 amount = 0 wei;
        uint64 fee = 1_000_000 wei;
        IBridge.Message memory message = newMessage({
            owner: Alice,
            to: Alice,
            value: 0,
            gasLimit: 1_000_000,
            fee: fee,
            destChain: destChainId
        });

        vm.expectRevert(Bridge.B_INVALID_VALUE.selector);
        bridge.sendMessage{ value: amount }(message);
    }

    function test_processMessage_InvokeMessageCall_DoS1() public {
        nonmaliciousContract1 = new NonMaliciousContract1();

        IBridge.Message memory message = IBridge.Message({
            id: 0,
            from: address(this),
            srcChainId: uint64(block.chainid),
            destChainId: destChainId,
            srcOwner: Alice,
            destOwner: Alice,
            to: address(nonmaliciousContract1),
            value: 1000,
            fee: 1000,
            gasLimit: 1_000_000,
            data: ""
        });

        bytes memory proof = hex"00";
        bytes32 msgHash = destBridge.hashMessage(message);
        vm.chainId(destChainId);
        vm.prank(Bob, Bob);

        destBridge.processMessage(message, proof);

        IBridge.Status status = destBridge.messageStatus(msgHash);
        assertEq(status == IBridge.Status.DONE, true); // test pass check
    }

    function test_processMessage_InvokeMessageCall_DoS2_testfail() public {
        maliciousContract2 = new MaliciousContract2();

        IBridge.Message memory message = IBridge.Message({
            id: 0,
            from: address(this),
            srcChainId: uint64(block.chainid),
            destChainId: destChainId,
            srcOwner: Alice,
            destOwner: Alice,
            to: address(maliciousContract2),
            value: 1000,
            fee: 1000,
            gasLimit: 1_000_000,
            data: ""
        });

        bytes memory proof = hex"00";
        bytes32 msgHash = destBridge.hashMessage(message);
        vm.chainId(destChainId);
        vm.prank(Bob, Bob);

        destBridge.processMessage(message, proof);

        IBridge.Status status = destBridge.messageStatus(msgHash);
        assertEq(status == IBridge.Status.RETRIABLE, true); //Test fail check
    }

    function retry_message_reverts_when_status_non_retriable() public {
        IBridge.Message memory message = newMessage({
            owner: Alice,
            to: Alice,
            value: 0,
            gasLimit: 10_000,
            fee: 1,
            destChain: destChainId
        });

        vm.expectRevert(Bridge.B_INVALID_STATUS.selector);
        destBridge.retryMessage(message, true);
    }

    function retry_message_reverts_when_last_attempt_and_message_is_not_owner() public {
        vm.startPrank(Alice);
        IBridge.Message memory message = newMessage({
            owner: Bob,
            to: Alice,
            value: 0,
            gasLimit: 10_000,
            fee: 1,
            destChain: destChainId
        });

        vm.expectRevert(Bridge.B_PERMISSION_DENIED.selector);
        destBridge.retryMessage(message, true);
    }

    function newMessage(
        address owner,
        address to,
        uint256 value,
        uint32 gasLimit,
        uint64 fee,
        uint64 destChain
    )
        internal
        view
        returns (IBridge.Message memory)
    {
        return IBridge.Message({
            srcOwner: owner,
            destOwner: owner,
            destChainId: destChain,
            to: to,
            value: value,
            fee: fee,
            id: 0, // placeholder, will be overwritten
            from: owner, // placeholder, will be overwritten
            srcChainId: uint64(block.chainid), // will be overwritten
            gasLimit: gasLimit,
            data: ""
        });
    }
}
