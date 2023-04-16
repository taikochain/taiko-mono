// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import {AddressManager} from "../contracts/thirdparty/AddressManager.sol";
import {TaikoConfig} from "../contracts/L1/TaikoConfig.sol";
import {TaikoData} from "../contracts/L1/TaikoData.sol";
import {TaikoL1} from "../contracts/L1/TaikoL1.sol";
import {TaikoToken} from "../contracts/L1/TaikoToken.sol";
import {SignalService} from "../contracts/signal/SignalService.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {TestLn as TestMath} from "./TestLn.sol";

contract Verifier {
    fallback(bytes calldata) external returns (bytes memory) {
        return bytes.concat(keccak256("taiko"));
    }
}

abstract contract TaikoL1TestBase is Test {
    AddressManager public addressManager;
    TaikoToken public tko;
    SignalService public ss;
    TaikoL1 public L1;
    TaikoData.Config conf;
    uint256 internal logCount;

    uint256 private constant SCALING_E18 = 1e18;

    bytes32 public constant GENESIS_BLOCK_HASH =
        keccak256("GENESIS_BLOCK_HASH");
    uint64 l2GasExcess = 1E18;

    address public constant L2SS = 0xa008AE5Ba00656a3Cc384de589579e3E52aC030C;
    address public constant L2TaikoL2 =
        0x0082D90249342980d011C58105a03b35cCb4A315;

    address public constant Alice = 0x10020FCb72e27650651B05eD2CEcA493bC807Ba4;
    address public constant Bob = 0x200708D76eB1B69761c23821809d53F65049939e;
    address public constant Carol = 0x300C9b60E19634e12FC6D68B7FEa7bFB26c2E419;
    address public constant Dave = 0x400147C0Eb43D8D71b2B03037bB7B31f8f78EF5F;
    address public constant Eve = 0x50081b12838240B1bA02b3177153Bca678a86078;

    uint32 private constant INIT_FEE = 1e9; // 10 TKO : Only relevant for the first proposing
    uint16 private constant PROOF_TIME_TARGET = 1800;
    uint8 private constant ADJUSTMENT_QUOTIENT = 16;

    function deployTaikoL1() internal virtual returns (TaikoL1 taikoL1);

    function setUp() public virtual {
        // vm.warp(1000000);
        addressManager = new AddressManager();
        addressManager.init();
        uint64 initBasefee = INIT_FEE;

        // Calculating it for our needs based on testnet/mainnet proof vars.
        // See Brecht's comment https://github.com/taikoxyz/taiko-mono/pull/13564
        uint256 scale = uint256(PROOF_TIME_TARGET * ADJUSTMENT_QUOTIENT);
        // ln_pub() expects 1e18 fixed format
        int256 logInput = int256((scale * initBasefee) * SCALING_E18);
        int256 log_result = TestMath.ln_pub(logInput);
        uint64 initProofTimeIssued = uint64(
            ((scale * (uint256(log_result))) / (SCALING_E18))
        );

        L1 = deployTaikoL1();
        L1.init(
            address(addressManager),
            GENESIS_BLOCK_HASH,
            initBasefee,
            initProofTimeIssued
        );
        conf = L1.getConfig();

        tko = new TaikoToken();
        address[] memory premintRecipients;
        uint256[] memory premintAmounts;
        tko.init(
            address(addressManager),
            "TaikoToken",
            "TKO",
            premintRecipients,
            premintAmounts
        );

        ss = new SignalService();
        ss.init(address(addressManager));

        // set proto_broker to this address to mint some TKO
        _registerAddress("proto_broker", address(this));
        tko.mint(address(this), 1E9 * 1E8);

        // register all addresses
        _registerAddress("taiko_token", address(tko));
        _registerAddress("proto_broker", address(L1));
        _registerAddress("signal_service", address(ss));
        _registerL2Address("signal_service", address(L2SS));
        _registerL2Address("taiko_l2", address(L2TaikoL2));

        _registerAddress(
            string(abi.encodePacked("verifier_", uint16(100))),
            address(new Verifier())
        );

        printVariables("init  ");
    }

    function proposeBlock(
        address proposer,
        uint24 txListSize
    ) internal returns (TaikoData.BlockMetadata memory meta) {
        uint32 gasLimit = 1000000;
        bytes memory txList = new bytes(txListSize);
        TaikoData.BlockMetadataInput memory input = TaikoData
            .BlockMetadataInput({
                beneficiary: proposer,
                gasLimit: gasLimit,
                txListHash: keccak256(txList),
                txListByteStart: 0,
                txListByteEnd: txListSize,
                cacheTxListInfo: 0
            });

        TaikoData.StateVariables memory variables = L1.getStateVariables();

        uint256 _mixHash;
        unchecked {
            _mixHash = block.prevrandao * variables.numBlocks;
        }

        meta.id = variables.numBlocks;
        meta.timestamp = uint64(block.timestamp);
        meta.l1Height = uint64(block.number - 1);
        meta.l1Hash = blockhash(block.number - 1);
        meta.mixHash = bytes32(_mixHash);
        meta.txListHash = keccak256(txList);
        meta.txListByteStart = 0;
        meta.txListByteEnd = txListSize;
        meta.gasLimit = gasLimit;
        meta.beneficiary = proposer;

        vm.prank(proposer, proposer);
        L1.proposeBlock(abi.encode(input), txList);
    }

    function proveBlock(
        address prover,
        TaikoData.BlockMetadata memory meta,
        bytes32 parentHash,
        bytes32 blockHash,
        bytes32 signalRoot
    ) internal {
        TaikoData.ZKProof memory zkproof = TaikoData.ZKProof({
            data: new bytes(100),
            verifierId: 100
        });

        TaikoData.BlockEvidence memory evidence = TaikoData.BlockEvidence({
            meta: meta,
            zkproof: zkproof,
            parentHash: parentHash,
            blockHash: blockHash,
            signalRoot: signalRoot,
            graffiti: 0x0,
            prover: prover,
            gasUsed: 100000
        });

        vm.prank(prover, prover);
        L1.proveBlock(meta.id, abi.encode(evidence));
    }

    function verifyBlock(address verifier, uint256 count) internal {
        vm.prank(verifier, verifier);
        L1.verifyBlocks(count);
    }

    function _registerAddress(string memory name, address addr) internal {
        string memory key = L1.keyForName(block.chainid, name);
        addressManager.setAddress(key, addr);
        console2.log(key, unicode"→", addr);
    }

    function _registerL2Address(string memory name, address addr) internal {
        string memory key = L1.keyForName(conf.chainId, name);
        addressManager.setAddress(key, addr);
        console2.log(key, unicode"→", addr);
    }

    function _depositTaikoToken(
        address who,
        uint256 amountTko,
        uint256 amountEth
    ) internal {
        vm.deal(who, amountEth);
        tko.transfer(who, amountTko);
        vm.prank(who, who);
        L1.deposit(amountTko);
    }

    function printVariables(string memory comment) internal {
        TaikoData.StateVariables memory vars = L1.getStateVariables();
        uint256 fee = L1.getProverFee();
        string memory str = string.concat(
            Strings.toString(logCount++),
            ":[",
            Strings.toString(vars.lastVerifiedBlockId),
            unicode"→",
            Strings.toString(vars.numBlocks),
            "]",
            " fee:",
            Strings.toString(fee),
            " lastProposedAt:",
            Strings.toString(vars.lastProposedAt),
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
