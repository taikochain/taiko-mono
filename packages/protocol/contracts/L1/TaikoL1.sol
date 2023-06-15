// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.20;

import { AddressResolver } from "../common/AddressResolver.sol";
import { EssentialContract } from "../common/EssentialContract.sol";
import { ICrossChainSync } from "../common/ICrossChainSync.sol";
import { Proxied } from "../common/Proxied.sol";
import { LibEthDepositing } from "./libs/LibEthDepositing.sol";
import { LibAuction } from "./libs/LibAuction.sol";
import { LibProposing } from "./libs/LibProposing.sol";
import { LibProving } from "./libs/LibProving.sol";
import { LibTaikoToken } from "./libs/LibTaikoToken.sol";
import { LibUtils } from "./libs/LibUtils.sol";
import { LibVerifying } from "./libs/LibVerifying.sol";
import { TaikoConfig } from "./TaikoConfig.sol";
import { TaikoErrors } from "./TaikoErrors.sol";
import { TaikoData } from "./TaikoData.sol";
import { TaikoEvents } from "./TaikoEvents.sol";

/// @custom:security-contact hello@taiko.xyz
contract TaikoL1 is
    EssentialContract,
    ICrossChainSync,
    TaikoEvents,
    TaikoErrors
{
    using LibUtils for TaikoData.State;

    TaikoData.State public state;
    uint256[100] private __gap;

    receive() external payable {
        depositEtherToL2();
    }

    /**
     * Initialize the rollup.
     *
     * @param _addressManager The AddressManager address.
     * @param _genesisBlockHash The block hash of the genesis block.
     * @param _initFeePerGas Initial (reasonable) block fee value,
     * @param _initAvgProofWindow Initial (reasonable) proof window.
     */
    function init(
        address _addressManager,
        bytes32 _genesisBlockHash,
        uint48 _initFeePerGas,
        uint16 _initAvgProofWindow
    )
        external
        initializer
    {
        EssentialContract._init(_addressManager);
        LibVerifying.init({
            state: state,
            config: getConfig(),
            genesisBlockHash: _genesisBlockHash,
            initFeePerGas: _initFeePerGas,
            initAvgProofWindow: _initAvgProofWindow
        });
    }

    /**
     * Propose a Taiko L2 block.
     *
     * @param input An abi-encoded BlockMetadataInput that the actual L2
     *        block header must satisfy.
     * @param txList A list of transactions in this block, encoded with RLP.
     *        Note, in the corresponding L2 block an _anchor transaction_
     *        will be the first transaction in the block -- if there are
     *        `n` transactions in `txList`, then there will be up to `n + 1`
     *        transactions in the L2 block.
     */
    function proposeBlock(
        bytes calldata input,
        bytes calldata txList
    )
        external
        nonReentrant
        returns (TaikoData.BlockMetadata memory meta)
    {
        TaikoData.Config memory config = getConfig();
        meta = LibProposing.proposeBlock({
            state: state,
            config: config,
            resolver: AddressResolver(this),
            input: abi.decode(input, (TaikoData.BlockMetadataInput)),
            txList: txList
        });
        if (config.maxVerificationsPerTx > 0) {
            LibVerifying.verifyBlocks({
                state: state,
                config: config,
                resolver: AddressResolver(this),
                maxBlocks: config.maxVerificationsPerTx
            });
        }
    }

    /**
     * Prove a block with a zero-knowledge proof.
     *
     * @param blockId The index of the block to prove. This is also used
     *        to select the right implementation version.
     * @param input An abi-encoded TaikoData.BlockEvidence object.
     */
    function proveBlock(
        uint256 blockId,
        bytes calldata input
    )
        external
        nonReentrant
    {
        TaikoData.Config memory config = getConfig();
        LibProving.proveBlock({
            state: state,
            config: config,
            resolver: AddressResolver(this),
            blockId: blockId,
            evidence: abi.decode(input, (TaikoData.BlockEvidence))
        });
        if (config.maxVerificationsPerTx > 0) {
            LibVerifying.verifyBlocks({
                state: state,
                config: config,
                resolver: AddressResolver(this),
                maxBlocks: config.maxVerificationsPerTx
            });
        }
    }

    /**
     * Bid for proving rights of a batch.
     *
     * @param bid The actual bid
     * @param batchId The batchId prover is bidding for
     */
    function bidForBatch(
        uint64 batchId,
        TaikoData.Bid memory bid
    )
        external
        payable
        nonReentrant
    {
        LibAuction.bidForBatch({
            state: state,
            config: getConfig(),
            batchId: batchId,
            bid: bid
        });
    }

    /**
     * Verify up to N blocks.
     * @param maxBlocks Max number of blocks to verify.
     */
    function verifyBlocks(uint256 maxBlocks) external nonReentrant {
        if (maxBlocks == 0) revert L1_INVALID_PARAM();
        LibVerifying.verifyBlocks({
            state: state,
            config: getConfig(),
            resolver: AddressResolver(this),
            maxBlocks: maxBlocks
        });
    }

    // From proposer side - same way paying the fees - and saving gas.
    function depositTaikoToken(uint64 amount) external nonReentrant {
        LibTaikoToken.depositTaikoToken(state, AddressResolver(this), amount);
    }

    function withdrawTaikoToken(uint64 amount) external nonReentrant {
        LibTaikoToken.withdrawTaikoToken(state, AddressResolver(this), amount);
    }

    function depositEtherToL2() public payable {
        LibEthDepositing.depositEtherToL2(
            state, getConfig(), AddressResolver(this)
        );
    }

    function getTaikoTokenBalance(address addr) public view returns (uint256) {
        return state.taikoTokenBalances[addr];
    }

    function getBlockFee(uint32 gasLimit) public view returns (uint64) {
        return LibProposing.getBlockFee({
            state: state,
            config: getConfig(),
            gasLimit: gasLimit
        });
    }

    function getBlock(uint256 blockId)
        public
        view
        returns (bytes32 _metaHash, address _proposer, uint64 _proposedAt)
    {
        TaikoData.Block storage blk = LibProposing.getBlock({
            state: state,
            config: getConfig(),
            blockId: blockId
        });
        _metaHash = blk.metaHash;
        _proposer = blk.proposer;
        _proposedAt = blk.proposedAt;
    }

    function getForkChoice(
        uint256 blockId,
        bytes32 parentHash,
        uint32 parentGasUsed
    )
        public
        view
        returns (TaikoData.ForkChoice memory)
    {
        return LibProving.getForkChoice({
            state: state,
            config: getConfig(),
            blockId: blockId,
            parentHash: parentHash,
            parentGasUsed: parentGasUsed
        });
    }

    function getCrossChainBlockHash(uint256 blockId)
        public
        view
        override
        returns (bytes32)
    {
        (bool found, TaikoData.Block storage blk) = LibUtils.getL2ChainData({
            state: state,
            config: getConfig(),
            blockId: blockId
        });
        return found
            ? blk.forkChoices[blk.verifiedForkChoiceId].blockHash
            : bytes32(0);
    }

    function getCrossChainSignalRoot(uint256 blockId)
        public
        view
        override
        returns (bytes32)
    {
        (bool found, TaikoData.Block storage blk) = LibUtils.getL2ChainData({
            state: state,
            config: getConfig(),
            blockId: blockId
        });

        return found
            ? blk.forkChoices[blk.verifiedForkChoiceId].signalRoot
            : bytes32(0);
    }

    function getStateVariables()
        public
        view
        returns (TaikoData.StateVariables memory)
    {
        return state.getStateVariables();
    }

    /**
     * Returns a list of auctions. Note that if the auction doesn't exist,
     * an empty will be returned instead. Client should check if the auction
     * returned has the correct batch id.
     *
     * @param startBatchId The first batch's id.
     * @param count The number of auctions to return.
     */
    function getAuctions(
        uint256 startBatchId,
        uint256 count
    )
        public
        view
        returns (uint256 currentTime, TaikoData.Auction[] memory auctions)
    {
        return LibAuction.getAuctions({
            state: state,
            config: getConfig(),
            startBatchId: startBatchId,
            count: count
        });
    }

    function getConfig()
        public
        pure
        virtual
        returns (TaikoData.Config memory)
    {
        return TaikoConfig.getConfig();
    }

    function batchForBlock(uint256 blockId) public pure returns (uint256) {
        return LibAuction.batchForBlock(getConfig(), blockId);
    }

    function isBatchAuctionable(uint256 batchId) public view returns (bool) {
        return LibAuction.isBatchAuctionable(state, getConfig(), batchId);
    }

    function isBlockProvableBy(
        uint256 blockId,
        address prover
    )
        public
        view
        returns (bool provable, bool proofWindowElapsed, TaikoData.Auction memory auction)
    {
        return LibAuction.isBlockProvableBy(state, getConfig(), blockId, prover);
    }

    function isBidBetter(
        TaikoData.Bid memory newBid,
        TaikoData.Bid memory oldBid
    )
        public
        pure
        returns (bool)
    {
        return LibAuction.isBidBetter(newBid, oldBid);
    }

    function getVerifierName(uint16 id) public pure returns (bytes32) {
        return LibUtils.getVerifierName(id);
    }
}

contract ProxiedTaikoL1 is Proxied, TaikoL1 { }
