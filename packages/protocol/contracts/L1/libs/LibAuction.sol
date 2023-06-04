// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import { AddressResolver } from "../../common/AddressResolver.sol";
import { LibAddress } from "../../libs/LibAddress.sol";
import { LibUtils } from "./LibUtils.sol";
import { TaikoData } from "../../L1/TaikoData.sol";
import { TaikoToken } from "../TaikoToken.sol";

library LibAuction {
    using LibAddress for address;

    event BatchBid(uint64 indexed batchId, uint64 startedAt, TaikoData.Bid bid);

    error L1_BID_INVALID();
    error L1_BATCH_NOT_AUCTIONABLE();
    error L1_INSUFFICIENT_TOKEN();
    error L1_NOT_THE_BEST_BID();

    function bidForBatch(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        uint64 batchId,
        TaikoData.Bid memory bid
    )
        internal
    {
        if (!isBidValid(state, config, bid, batchId)) {
            revert L1_BID_INVALID();
        }

        if (!isBatchAuctionable(state, config, batchId)) {
            revert L1_BATCH_NOT_AUCTIONABLE();
        }

        bid.prover = msg.sender;
        bid.blockMaxGasLimit = config.blockMaxGasLimit;

        // Have in-memory and write it back at the end of the function
        TaikoData.Auction memory auction =
            state.auctions[batchId % config.auctionRingBufferSize];

        // Deposit amount is per block, not per block * auctionBatchSize
        uint64 totalDeposit = bid.deposit * config.auctionBatchSize;

        if (batchId != auction.batchId) {
            // It is a new auction
            auction.startedAt = uint64(block.timestamp);
            auction.bid = bid;
            auction.batchId = batchId;
            unchecked {
                state.numOfAuctions += 1;
            }
        } else {
            // An ongoing one
            if (!isBidBetter(auction.bid, bid)) {
                revert L1_NOT_THE_BEST_BID();
            }
            //'Refund' current
            state.taikoTokenBalances[auction.bid.prover] += totalDeposit;
        }

        // Check if bidder at least have the balance
        if (state.taikoTokenBalances[bid.prover] < totalDeposit) {
            revert L1_INSUFFICIENT_TOKEN();
        }

        state.taikoTokenBalances[bid.prover] -= totalDeposit;
        auction.bid = bid;

        emit BatchBid(auction.batchId, auction.startedAt, bid);
    }

    // Check validity requirements
    function isBidValid(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        TaikoData.Bid memory newBid,
        uint64 batchId
    )
        internal
        view
        returns (bool)
    {
        if (
            batchId == 0 || config.maxFeePerGas < newBid.feePerGas
                || newBid.prover != address(0) // auto-fill
                || newBid.proofWindow
                    > state.proofWindow * config.auctionProofWindowMultiplier // Cannot
                // be more than 2x of average
                // TODO(daniel): why
                // TODO(daniel): rename maxFeePerGas?
                || newBid.feePerGas > config.maxFeePerGas
        ) {
            return false;
        }

        return true;
    }

    // Check if auction ha ended or not
    function hasAuctionEnded(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        uint64 batchId
    )
        internal
        view
        returns (bool)
    {
        if (batchId == 0) return true;

        TaikoData.Auction memory auction =
            state.auctions[batchId % config.auctionRingBufferSize];

        return auction.batchId == batchId
            && block.timestamp > auction.startedAt + config.auctionWindow;
    }

    // isBidAcceptable determines is checking if the bid is acceptable based on
    // the defined
    // criteria. Shall be called after isBatchAuctionable() returns true.
    function isBidBetter(
        TaikoData.Bid memory oldBid,
        TaikoData.Bid memory newBid
    )
        internal
        pure
        returns (bool result)
    {
        if (
            newBid.feePerGas
                <= (oldBid.feePerGas - ((oldBid.feePerGas * 9000) / 10_000)) // 90%
                && newBid.deposit
                    <= ((oldBid.deposit - ((oldBid.deposit * 5000) / 10_000))) // 50%
        ) {
            result = true;
        }
    }

    // isBatchAuctionable determines whether a new bid for a batch of blocks
    // would be accepted or not. 'open ended' - so returns true if no bids came
    // yet
    function isBatchAuctionable(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        uint256 batchId
    )
        internal
        view
        returns (bool result)
    {
        if (batchId == 0) return false;

        uint64 currentProposedBatchId = batchForBlock(config, state.numBlocks);
        uint64 currentVerifiedBatchId =
            batchForBlock(config, state.lastVerifiedBlockId + 1);

        // Regardless of auction started or not - do not allow too many auctions
        // to be open
        if (
            // the batch of lastVerifiedBlockId is never auctionable as it has
            // to be ended before the last verifeid block can be verified.
            batchId < currentVerifiedBatchId
            // We cannot start a new auction if the previous one has not started
            || batchId > state.numOfAuctions + 1
            // We cannot start a new auction if we have to keep all the auctions
            // info in order to prove/verify blocks
            || batchId >= currentVerifiedBatchId + config.auctionRingBufferSize
                || batchId
                    >= currentProposedBatchId + config.auctonMaxAheadOfProposals
        ) {
            return false;
        }

        TaikoData.Auction memory auction =
            state.auctions[batchId % config.auctionRingBufferSize];

        return auction.batchId != batchId
            || block.timestamp <= auction.startedAt + config.auctionWindow;
    }

    function isBlockProvableBy(
        TaikoData.State storage state,
        TaikoData.Config memory config,
        uint256 blockId,
        address prover
    )
        internal
        view
        returns (bool result)
    {
        if (blockId == 0) return false;

        if (prover == address(0) || prover == address(1)) {
            // Note that auction may not exist at all.
            return true;
        }

        // Nobody can prove a block before the auction ended
        uint64 batchId = batchForBlock(config, blockId);
        if (
            !hasAuctionEnded({ state: state, config: config, batchId: batchId })
        ) {
            return false;
        }

        TaikoData.Auction memory auction =
            state.auctions[batchId % config.auctionRingBufferSize];

        if (prover == auction.bid.prover) return true;

        return block.timestamp
            > auction.startedAt + config.auctionWindow + auction.bid.proofWindow;
    }

    // Mapping blockId to batchId where batchId is a ring buffer, blockId is
    // absolute (aka. block height)
    function batchForBlock(
        TaikoData.Config memory config,
        uint256 blockId
    )
        internal
        pure
        returns (uint64)
    {
        if (blockId == 0) {
            return 0;
        } else {
            unchecked {
                return uint64((blockId - 1) / config.auctionBatchSize) + 1;
            }
        }
    }
}
