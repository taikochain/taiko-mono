// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { TestBase } from "../TestBase.sol";
import { console2 } from "forge-std/console2.sol";
import { AddressManager } from "../../contracts/common/AddressManager.sol";
import { LibProving } from "../../contracts/L1/libs/LibProving.sol";
import { LibProposing } from "../../contracts/L1/libs/LibProposing.sol";
import { LibUtils } from "../../contracts/L1/libs/LibUtils.sol";
import { TaikoData } from "../../contracts/L1/TaikoData.sol";
import { TaikoL1 } from "../../contracts/L1/TaikoL1.sol";
import { TaikoToken } from "../../contracts/L1/TaikoToken.sol";
import { GuardianVerifier } from
    "../../contracts/L1/verifiers/GuardianVerifier.sol";
import { OptimisticRollupConfigProvider } from
    "../../contracts/L1/tiers/OptimisticRollupConfigProvider.sol";
import { PseZkVerifier } from "../../contracts/L1/verifiers/PseZkVerifier.sol";
import { SignalService } from "../../contracts/signal/SignalService.sol";
import { StringsUpgradeable as Strings } from
    "@ozu/utils/StringsUpgradeable.sol";
import { AddressResolver } from "../../contracts/common/AddressResolver.sol";
import { LibTiers } from "../../contracts/L1/tiers/ITierProvider.sol";

contract MockVerifier {
    fallback(bytes calldata) external returns (bytes memory) {
        return bytes.concat(keccak256("taiko"));
    }
}

abstract contract TaikoL1TestBase is TestBase {
    AddressManager public addressManager;
    TaikoToken public tko;
    SignalService public ss;
    TaikoL1 public L1;
    TaikoData.Config conf;
    uint256 internal logCount;
    PseZkVerifier public pv;
    GuardianVerifier public gv;
    OptimisticRollupConfigProvider public cp;

    bytes32 public constant GENESIS_BLOCK_HASH = keccak256("GENESIS_BLOCK_HASH");
    // 1 TKO --> it is to huge. It should be in 'wei' (?).
    // Because otherwise first proposal is around: 1TKO * (1_000_000+20_000)
    // required as a deposit.
    // uint32 feePerGas = 10;
    // uint16 provingWindow = 60 minutes;
    uint64 l2GasExcess = 1e18;

    address public constant L2Treasury =
        0x859d74b52762d9ed07D1b2B8d7F93d26B1EA78Bb;
    address public constant L2SS = 0xa008AE5Ba00656a3Cc384de589579e3E52aC030C;
    address public constant TaikoL2 = 0x0082D90249342980d011C58105a03b35cCb4A315;
    address public constant L1EthVault =
        0xDAFEA492D9c6733ae3d56b7Ed1ADB60692c98Bc5;

    function deployTaikoL1() internal virtual returns (TaikoL1 taikoL1);

    function setUp() public virtual {
        L1 = deployTaikoL1();
        conf = L1.getConfig();

        addressManager = new AddressManager();
        addressManager.init();

        ss = new SignalService();
        ss.init(address(addressManager));

        pv = new PseZkVerifier();
        pv.init(address(addressManager));

        gv = new GuardianVerifier();
        gv.init(address(addressManager));

        cp = new OptimisticRollupConfigProvider();

        registerAddress("tier_pse_zkevm", address(pv));
        registerAddress("tier_guardian", address(gv));
        registerAddress("tier_provider", address(cp));
        registerAddress("signal_service", address(ss));
        registerAddress("ether_vault", address(L1EthVault));
        registerL2Address("treasury", L2Treasury);
        registerL2Address("taiko", address(TaikoL2));
        registerL2Address("signal_service", address(L2SS));
        registerL2Address("taiko_l2", address(TaikoL2));
        registerAddress(pv.getVerifierName(300), address(new MockVerifier()));

        tko = new TaikoToken();
        registerAddress("taiko_token", address(tko));
        address[] memory premintRecipients = new address[](1);
        premintRecipients[0] = address(this);

        uint256[] memory premintAmounts = new uint256[](1);
        premintAmounts[0] = 1e9 ether;

        tko.init(
            address(addressManager),
            "TaikoToken",
            "TKO",
            premintRecipients,
            premintAmounts
        );

        // Set protocol broker
        registerAddress("taiko", address(this));
        tko.mint(address(this), 1e9 ether);

        registerAddress("taiko", address(L1));

        L1.init(address(addressManager), GENESIS_BLOCK_HASH);
        printVariables("init  ");
    }

    function proposeBlock(
        address proposer,
        address prover,
        uint32 gasLimit,
        uint24 txListSize
    )
        internal
        returns (TaikoData.BlockMetadata memory meta)
    {
        TaikoData.TierFee[] memory tierFees = new TaikoData.TierFee[](3);
        // Register the tier fees
        // Based on OPL2ConfigTier we need 3:
        // - LibTiers.TIER_PSE_ZKEVM;
        // - LibTiers.TIER_OPTIMISTIC;
        // - LibTiers.TIER_GUARDIAN;
        tierFees[0] = TaikoData.TierFee(LibTiers.TIER_OPTIMISTIC, 1 ether);
        tierFees[1] = TaikoData.TierFee(LibTiers.TIER_PSE_ZKEVM, 2 ether);
        tierFees[2] = TaikoData.TierFee(LibTiers.TIER_GUARDIAN, 0 ether);
        // For the test not to fail, set the message.value to the highest, the
        // rest will be returned
        // anyways
        uint256 msgValue = 2 ether;

        TaikoData.ProverAssignment memory assignment = TaikoData
            .ProverAssignment({
            prover: prover,
            feeToken: address(0),
            tierFees: tierFees,
            expiry: uint64(block.timestamp + 60 minutes),
            signature: new bytes(0)
        });

        bytes memory txList = new bytes(txListSize);

        assignment.signature =
            grantWithSignature(prover, assignment, keccak256(txList));

        TaikoData.StateVariables memory variables = L1.getStateVariables();

        uint256 _mixHash;
        unchecked {
            _mixHash = block.prevrandao * variables.numBlocks;
        }

        meta.timestamp = uint64(block.timestamp);
        meta.l1Height = uint64(block.number - 1);
        meta.l1Hash = blockhash(block.number - 1);
        meta.mixHash = bytes32(_mixHash);
        meta.txListHash = keccak256(txList);
        meta.gasLimit = gasLimit;

        vm.prank(proposer, proposer);
        meta = L1.proposeBlock{ value: msgValue }(
            meta.txListHash, abi.encode(assignment), txList
        );
    }

    function proveBlock(
        address msgSender,
        address prover,
        TaikoData.BlockMetadata memory meta,
        bytes32 parentHash,
        bytes32 blockHash,
        bytes32 signalRoot,
        uint16 tier,
        bytes4 revertReason,
        bool unprovable
    )
        internal
    {
        TaikoData.BlockEvidence memory evidence = TaikoData.BlockEvidence({
            metaHash: LibProposing.hashMetadata(meta),
            parentHash: parentHash,
            blockHash: blockHash,
            signalRoot: signalRoot,
            graffiti: 0x0,
            tier: tier,
            proof: new bytes(102)
        });

        bytes32 instance = pv.getInstance(prover, evidence);
        uint16 verifierId = tier;

        evidence.proof = bytes.concat(
            bytes2(verifierId),
            bytes16(0),
            bytes16(instance),
            bytes16(0),
            bytes16(uint128(uint256(instance))),
            new bytes(100)
        );

        if (tier == LibTiers.TIER_GUARDIAN) {
            evidence.proof = "";

            if (unprovable) {
                evidence.proof =
                    bytes.concat(bytes32(keccak256("RETURN_LIVENESS_BOND")));
            }
        }

        if (revertReason != "") {
            vm.prank(msgSender, msgSender);
            vm.expectRevert(revertReason);
            L1.proveBlock(meta.id, abi.encode(evidence));
        } else {
            vm.prank(msgSender, msgSender);
            L1.proveBlock(meta.id, abi.encode(evidence));
        }
    }

    function verifyBlock(address, uint64 count) internal {
        L1.verifyBlocks(count);
    }

    function registerAddress(bytes32 nameHash, address addr) internal {
        addressManager.setAddress(block.chainid, nameHash, addr);
        console2.log(block.chainid, uint256(nameHash), unicode"→", addr);
    }

    function registerL2Address(bytes32 nameHash, address addr) internal {
        addressManager.setAddress(conf.chainId, nameHash, addr);
        console2.log(
            conf.chainId, string(abi.encodePacked(nameHash)), unicode"→", addr
        );
    }

    function grantWithSignature(
        address signer,
        TaikoData.ProverAssignment memory assignment,
        bytes32 txListHash
    )
        internal
        view
        returns (bytes memory signature)
    {
        bytes32 digest =
            LibProposing.hashAssignmentForTxList(assignment, txListHash);
        uint256 signerPrivateKey;

        // In the test suite these are the 3 which acts as provers
        if (signer == Alice) {
            signerPrivateKey = 0x1;
        } else if (signer == Bob) {
            signerPrivateKey = 0x2;
        } else if (signer == Carol) {
            signerPrivateKey = 0x3;
        }

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, digest);
        signature = abi.encodePacked(r, s, v);
    }

    function giveEthAndTko(
        address to,
        uint256 amountTko,
        uint256 amountEth
    )
        internal
    {
        vm.deal(to, amountEth);
        console2.log("TKO balance this:", tko.balanceOf(address(this)));
        console2.log(amountTko);
        tko.transfer(to, amountTko);

        vm.prank(to, to);
        tko.approve(address(L1), amountTko);

        console2.log("TKO balance:", to, tko.balanceOf(to));
        console2.log("ETH balance:", to, to.balance);
    }

    function printVariables(string memory comment) internal {
        TaikoData.StateVariables memory vars = L1.getStateVariables();

        string memory str = string.concat(
            Strings.toString(logCount++),
            ":[",
            Strings.toString(vars.lastVerifiedBlockId),
            unicode"→",
            Strings.toString(vars.numBlocks),
            "]"
        );

        str = string.concat(
            str,
            " nextEthDepositToProcess:",
            Strings.toString(vars.nextEthDepositToProcess),
            " numEthDeposits:",
            Strings.toString(vars.numEthDeposits),
            " // ",
            comment
        );
        console2.log(str);
    }

    function mine(uint256 counts) internal {
        vm.warp(block.timestamp + 20 * counts);
        vm.roll(block.number + counts);
    }
}
