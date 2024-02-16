// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../TaikoL1TestBase.sol";
import "../../../contracts/L1/gov/TaikoGovernor.sol";
import "../../../contracts/L1/gov/TaikoTimelockController.sol";
import "@openzeppelin/contracts/governance/IGovernor.sol";
import "@openzeppelin/contracts/governance/TimelockController.sol";

/// @author Kirk Baird <kirk@sigmaprime.io>
contract TestTkoGovernor is TaikoL1TestBase {
    TaikoGovernor public tkoGovernor;
    TaikoTimelockController public taikoTimelockController;

    function deployTaikoL1() internal override returns (TaikoL1) {
        return
            TaikoL1(payable(deployProxy({ name: "taiko", impl: address(new TaikoL1()), data: "" })));
    }

    function setUp() public override {
        // Call the TaikoL1TestBase setUp()
        super.setUp();

        // deploy TaikoTimelockController
        taikoTimelockController = TaikoTimelockController(
            payable(
                LibDeploy.deployERC1967Proxy({
                    impl: address(new TaikoTimelockController()),
                    owner: address(0),
                    data: ""
                })
            )
        );

        // init TaikoTimelockController
        uint256 minDelay = 0.5 days;
        taikoTimelockController.init(minDelay);

        // deploy TaikoGovernor
        tkoGovernor = TaikoGovernor(
            payable(
                LibDeploy.deployERC1967Proxy({
                    impl: address(new TaikoGovernor()),
                    owner: address(0),
                    data: ""
                })
            )
        );

        // init TaikoGovernor
        tkoGovernor.init(tko, taikoTimelockController);
        // Alice delegate voting power to self
        vm.startPrank(Alice);
        tko.delegate(Alice);
        vm.stopPrank();

        address owner = taikoTimelockController.owner();
        vm.startPrank(owner);
        // Owner set access controls for timelock controller
        taikoTimelockController.grantRole(
            taikoTimelockController.PROPOSER_ROLE(), address(tkoGovernor)
        );
        taikoTimelockController.grantRole(
            taikoTimelockController.EXECUTOR_ROLE(), address(tkoGovernor)
        );
        taikoTimelockController.grantRole(
            taikoTimelockController.CANCELLER_ROLE(), address(tkoGovernor)
        );

        // Owner delegate voting power to self
        tko.delegate(owner);

        // Transfer Alice double the proposal threshold worth of tokens
        uint256 proposalThreshold = tkoGovernor.proposalThreshold();
        tko.transfer(Alice, proposalThreshold * 2);
        tko.transfer(Bob, proposalThreshold * 5);
        vm.roll(block.number + 1); // increase block number to help facilitate snapshots in
            // TaikoToken

        vm.stopPrank();
    }

    function test_init() public {
        // GovernorVotesQuorumFractionUpgradeable
        assertEq(tkoGovernor.quorumNumerator(), 4, "Incorrect initial quorum numerator");
        assertEq(
            tkoGovernor.quorumNumerator(block.number), 4, "Incorrect initial block quorum numerator"
        );
        assertEq(tkoGovernor.quorumDenominator(), 100, "Incorrect quorum denominator");

        // GovernorUpgradeable
        assertEq(tkoGovernor.name(), "Taiko", "Incorrect name");
        assertEq(tkoGovernor.version(), "1", "Incorrect version");

        // GovernorVotesUpgradeable
        assertEq(address(tkoGovernor.token()), address(tko), "Incorrect token");

        // GovernorCompatibilityBravoUpgradeable
        assertEq(
            tkoGovernor.COUNTING_MODE(), "support=bravo&quorum=bravo", "Incorrect counting mode"
        );

        // GovernorTimelockControlUpgradeable
        assertEq(tkoGovernor.timelock(), address(taikoTimelockController), "Incorrect timelock");

        // Interfaces
        assertEq(
            tkoGovernor.supportsInterface(type(IGovernorTimelockUpgradeable).interfaceId),
            true,
            "Incorrect supports interface"
        );
        assertEq(
            tkoGovernor.supportsInterface(type(IGovernorUpgradeable).interfaceId),
            true,
            "Incorrect supports interface"
        );
        assertEq(
            tkoGovernor.supportsInterface(type(IERC1155ReceiverUpgradeable).interfaceId),
            true,
            "Incorrect supports interface"
        );

        // TaikoGovernor
        assertEq(tkoGovernor.votingDelay(), 7200, "Incorrect voting delay");
        assertEq(tkoGovernor.votingPeriod(), 50_400, "Incorrect voting period");
        assertEq(tkoGovernor.proposalThreshold(), 100_000 ether, "Incorrect proposal threshold");
    }

    // Tests `propose()`
    function test_propose() public {
        // Parameters for `tkoGovernor.propose()`
        address[] memory targets = new address[](1);
        targets[0] = Alice;

        uint256[] memory values = new uint256[](1);
        values[0] = 1 ether;

        bytes[] memory calldatas = new bytes[](1);

        string memory description = "Send alice an ether";

        address proposer = Alice;
        vm.startPrank(proposer);

        // Prepare for event emission
        uint256 startBlock = block.number + tkoGovernor.votingDelay();
        uint256 endBlock = startBlock + tkoGovernor.votingPeriod();
        uint256 calculatedProposalId =
            tkoGovernor.hashProposal(targets, values, calldatas, keccak256(bytes(description)));

        vm.expectEmit(true, true, true, true);
        emit IGovernor.ProposalCreated(
            calculatedProposalId,
            Alice,
            targets,
            values,
            new string[](targets.length),
            calldatas,
            startBlock,
            endBlock,
            description
        );

        // `propose()`
        uint256 proposalId = tkoGovernor.propose(targets, values, calldatas, description);
        vm.stopPrank();

        // Validate proposal
        assertEq(proposalId, calculatedProposalId, "Proposal does not have the correct ID");
        assertEq(
            tkoGovernor.state(proposalId) == IGovernorUpgradeable.ProposalState.Pending,
            true,
            "Incorrect proposal state"
        );
        assertEq(
            tkoGovernor.proposalSnapshot(proposalId), startBlock, "Incorrect proposal snapshot"
        );
        assertEq(tkoGovernor.proposalDeadline(proposalId), endBlock, "Incorrect proposal deadline");
    }

    // Tests `castVote()`, `queue()` and `execute()`
    function test_execute() public {
        // Parameters for `propose()`
        address proposer = Alice;
        address[] memory targets = new address[](1);
        targets[0] = Alice;
        uint256[] memory values = new uint256[](1);
        values[0] = 1 ether;
        bytes[] memory calldatas = new bytes[](1);
        string memory description = "Send alice an ether";
        bytes32 descriptionHash = keccak256(bytes(description));

        // Send the values to the timelock controller for execute
        (bool success,) = address(taikoTimelockController).call{ value: values[0] }("");

        assertEq(success, true, "Transfer funds unsuccessful");

        // `propose()`
        vm.startPrank(proposer);
        uint256 proposalId = tkoGovernor.propose(targets, values, calldatas, description);
        vm.stopPrank();

        // Skip to voting start
        uint256 startBlock = tkoGovernor.proposalSnapshot(proposalId);
        vm.roll(startBlock + 1);

        // `castVote()`
        vm.startPrank(tko.owner());
        tkoGovernor.castVote(proposalId, 1); // 1 = for

        // Skip to voting end
        uint256 endBlock = tkoGovernor.proposalDeadline(proposalId);
        vm.roll(endBlock + 1);

        // `queue()` successful proposal
        tkoGovernor.queue(proposalId);

        // Skip delay amount of time
        uint256 eta = tkoGovernor.proposalEta(proposalId);
        vm.warp(eta + 1);

        // Prepare execute event
        bytes32 timelockId = taikoTimelockController.hashOperationBatch(
            targets, values, calldatas, 0, descriptionHash
        );
        vm.expectEmit(true, true, true, true);
        emit TimelockController.CallExecuted(timelockId, 0, targets[0], values[0], calldatas[0]);

        // `execute()`
        // tkoGovernor.execute(targets, values, calldatas, descriptionHash);
        tkoGovernor.execute(proposalId);

        vm.stopPrank();
    }
}
