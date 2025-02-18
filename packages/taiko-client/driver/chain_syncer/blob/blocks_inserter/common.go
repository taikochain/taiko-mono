package blocksinserter

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"math/big"

	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/beacon/engine"
	"github.com/ethereum/go-ethereum/common"
	consensus "github.com/ethereum/go-ethereum/consensus/taiko"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/ethereum/go-ethereum/log"
	"github.com/ethereum/go-ethereum/miner"
	"github.com/ethereum/go-ethereum/rlp"

	"github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/encoding"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/pkg/rpc"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/pkg/utils"
)

// createPayloadAndSetHead tries to insert a new head block to the L2 execution engine's local
// block chain through Engine APIs.
func createPayloadAndSetHead(
	ctx context.Context,
	rpc *rpc.Client,
	meta *createPayloadAndSetHeadMetaData,
	anchorTx *types.Transaction,
) (*engine.ExecutableData, error) {
	log.Debug(
		"Try to insert a new L2 head block",
		"parentNumber", meta.Parent.Number,
		"parentHash", meta.Parent.Hash(),
		"l1Origin", meta.L1Origin,
	)
	// Insert a TaikoL2.anchorV2 / TaikoAnchor.anchorV3 transaction at transactions list head,
	// then encode the transactions list.
	txListBytes, err := rlp.EncodeToBytes(append([]*types.Transaction{anchorTx}, meta.Txs...))
	if err != nil {
		log.Error("Encode txList error", "blockID", meta.BlockID, "error", err)
		return nil, err
	}

	// If the Pacaya block is preconfirmed, we don't need to insert it again.
	if meta.BlockID.Cmp(new(big.Int).SetUint64(rpc.PacayaClients.ForkHeight)) >= 0 {
		header, err := isBlockPreconfirmed(ctx, rpc, meta, txListBytes, anchorTx)
		if err != nil {
			return nil, err
		} else if header != nil {
			// Update the l1Origin and headL1Origin cursor for that preconfirmed block.
			meta.L1Origin.L2BlockHash = header.Hash()
			if _, err := rpc.L2.UpdateL1Origin(ctx, meta.L1Origin); err != nil {
				return nil, fmt.Errorf("failed to update L1 origin: %w", err)
			}
			if _, err := rpc.L2.SetHeadL1Origin(ctx, meta.L1Origin.BlockID); err != nil {
				return nil, fmt.Errorf("failed to write head L1 origin: %w", err)
			}

			log.Info(
				"🧬 The block is preconfirmed",
				"blockID", meta.BlockID,
				"hash", header.Hash(),
				"coinbase", header.Coinbase,
				"timestamp", header.Time,
				"anchorBlockID", meta.AnchorBlockID,
				"anchorBlockHash", meta.AnchorBlockHash,
				"baseFee", utils.WeiToEther(header.BaseFee),
			)

			return encoding.ToExecutableData(header), nil
		}
	}

	payload, err := createExecutionPayloads(
		ctx,
		rpc,
		meta.createExecutionPayloadsMetaData,
		txListBytes,
		anchorTx,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to create execution payloads: %w", err)
	}

	var lastVerifiedBlockHash common.Hash
	lastVerifiedTS, err := rpc.GetLastVerifiedTransitionPacaya(ctx)
	if err != nil {
		lastVerifiedBlockInfo, err := rpc.GetLastVerifiedBlockOntake(ctx)
		if err != nil {
			return nil, fmt.Errorf("failed to fetch last verified block: %w", err)
		}

		if meta.BlockID.Uint64() > lastVerifiedBlockInfo.BlockId {
			lastVerifiedBlockHash = lastVerifiedBlockInfo.BlockHash
		}
	} else {
		if meta.BlockID.Uint64() > lastVerifiedTS.BlockId {
			lastVerifiedBlockHash = lastVerifiedTS.Ts.BlockHash
		}
	}

	fc := &engine.ForkchoiceStateV1{
		HeadBlockHash:      payload.BlockHash,
		SafeBlockHash:      lastVerifiedBlockHash,
		FinalizedBlockHash: lastVerifiedBlockHash,
	}

	// Update the fork choice
	fcRes, err := rpc.L2Engine.ForkchoiceUpdate(ctx, fc, nil)
	if err != nil {
		return nil, err
	}
	if fcRes.PayloadStatus.Status != engine.VALID {
		return nil, fmt.Errorf("unexpected ForkchoiceUpdate response status: %s", fcRes.PayloadStatus.Status)
	}

	return payload, nil
}

// createExecutionPayloads creates a new execution payloads through Engine APIs.
func createExecutionPayloads(
	ctx context.Context,
	rpc *rpc.Client,
	meta *createExecutionPayloadsMetaData,
	txListBytes []byte,
	anchorTx *types.Transaction,
) (payloadData *engine.ExecutableData, err error) {
	var gasLimit = meta.GasLimit
	if meta.BlockID.Uint64() >= rpc.PacayaClients.ForkHeight {
		gasLimit += consensus.AnchorV3GasLimit
	} else {
		gasLimit += consensus.AnchorGasLimit
	}

	attributes := &engine.PayloadAttributes{
		Timestamp:             meta.Timestamp,
		Random:                meta.Difficulty,
		SuggestedFeeRecipient: meta.SuggestedFeeRecipient,
		Withdrawals:           meta.Withdrawals,
		BlockMetadata: &engine.BlockMetadata{
			Beneficiary: meta.SuggestedFeeRecipient,
			GasLimit:    gasLimit,
			Timestamp:   meta.Timestamp,
			TxList:      txListBytes,
			MixHash:     meta.Difficulty,
			ExtraData:   meta.ExtraData,
		},
		BaseFeePerGas: meta.BaseFee,
		L1Origin:      meta.L1Origin,
	}

	log.Debug(
		"PayloadAttributes",
		"blockID", meta.BlockID,
		"timestamp", attributes.Timestamp,
		"random", attributes.Random,
		"suggestedFeeRecipient", attributes.SuggestedFeeRecipient,
		"withdrawals", len(attributes.Withdrawals),
		"gasLimit", attributes.BlockMetadata.GasLimit,
		"timestamp", attributes.BlockMetadata.Timestamp,
		"mixHash", attributes.BlockMetadata.MixHash,
		"baseFee", utils.WeiToGWei(attributes.BaseFeePerGas),
		"extraData", string(attributes.BlockMetadata.ExtraData),
		"l1OriginHeight", attributes.L1Origin.L1BlockHeight,
		"l1OriginHash", attributes.L1Origin.L1BlockHash,
	)

	// Step 1, prepare a payload
	fcRes, err := rpc.L2Engine.ForkchoiceUpdate(
		ctx,
		&engine.ForkchoiceStateV1{HeadBlockHash: meta.ParentHash},
		attributes,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to update fork choice: %w", err)
	}
	if fcRes.PayloadStatus.Status != engine.VALID {
		return nil, fmt.Errorf("unexpected ForkchoiceUpdate response status: %s", fcRes.PayloadStatus.Status)
	}
	if fcRes.PayloadID == nil {
		return nil, errors.New("empty payload ID")
	}

	// Step 2, get the payload
	payload, err := rpc.L2Engine.GetPayload(ctx, fcRes.PayloadID)
	if err != nil {
		return nil, fmt.Errorf("failed to get payload: %w", err)
	}

	log.Debug(
		"Payload",
		"blockID", meta.BlockID,
		"baseFee", utils.WeiToGWei(payload.BaseFeePerGas),
		"number", payload.Number,
		"hash", payload.BlockHash,
		"gasLimit", payload.GasLimit,
		"gasUsed", payload.GasUsed,
		"timestamp", payload.Timestamp,
		"withdrawalsHash", payload.WithdrawalsHash,
	)

	// Step 3, execute the payload
	execStatus, err := rpc.L2Engine.NewPayload(ctx, payload)
	if err != nil {
		return nil, fmt.Errorf("failed to create a new payload: %w", err)
	}
	if execStatus.Status != engine.VALID {
		return nil, fmt.Errorf("unexpected NewPayload response status: %s", execStatus.Status)
	}

	return payload, nil
}

// isBlockPreconfirmed checks if the block is preconfirmed.
func isBlockPreconfirmed(
	ctx context.Context,
	rpc *rpc.Client,
	meta *createPayloadAndSetHeadMetaData,
	txListBytes []byte,
	anchorTx *types.Transaction,
) (*types.Header, error) {
	var blockID = new(big.Int).Add(meta.Parent.Number, common.Big1)
	block, err := rpc.L2.BlockByNumber(ctx, blockID)
	if err != nil && !errors.Is(err, ethereum.NotFound) {
		return nil, fmt.Errorf("failed to get block by number %d: %w", blockID, err)
	}

	if block == nil {
		return nil, nil
	}

	var (
		txListHash = crypto.Keccak256Hash(txListBytes[:])
		args       = &miner.BuildPayloadArgs{
			Parent:       meta.Parent.Hash(),
			Timestamp:    block.Time(),
			FeeRecipient: block.Coinbase(),
			Random:       block.MixDigest(),
			Withdrawals:  make([]*types.Withdrawal, 0),
			Version:      engine.PayloadV2,
			TxListHash:   &txListHash,
		}
		id = args.Id()
	)
	executableData, err := rpc.L2Engine.GetPayload(ctx, &id)
	if err != nil {
		return nil, fmt.Errorf("failed to get payload: %w", err)
	}

	if executableData.BlockHash != block.Hash() {
		err = fmt.Errorf("block hash mismatch: %s != %s", executableData.BlockHash, block.Hash())
	}
	if block.ParentHash() != meta.ParentHash {
		err = fmt.Errorf("parent hash mismatch: %s != %s", block.ParentHash(), meta.ParentHash)
	}
	if block.Transactions().Len() == 0 {
		err = errors.New("transactions list is empty")
	}
	if block.Transactions()[0].Hash() != anchorTx.Hash() {
		err = fmt.Errorf("anchor transaction mismatch: %s != %s", block.Transactions()[0].Hash(), anchorTx.Hash())
	}
	if block.UncleHash() != types.EmptyUncleHash {
		err = fmt.Errorf("uncle hash mismatch: %s != %s", block.UncleHash(), types.EmptyUncleHash)
	}
	if block.Coinbase() != meta.SuggestedFeeRecipient {
		err = fmt.Errorf("coinbase mismatch: %s != %s", block.Coinbase(), meta.SuggestedFeeRecipient)
	}
	if block.Difficulty().Cmp(common.Big0) != 0 {
		err = fmt.Errorf("difficulty mismatch: %s != 0", block.Difficulty())
	}
	if block.MixDigest() != meta.Difficulty {
		err = fmt.Errorf("mixDigest mismatch: %s != %s", block.MixDigest(), meta.Difficulty)
	}
	if block.Number().Uint64() != meta.BlockID.Uint64() {
		err = fmt.Errorf("block number mismatch: %d != %d", block.Number(), meta.BlockID)
	}
	if block.GasLimit() != meta.GasLimit+consensus.AnchorV3GasLimit {
		err = fmt.Errorf("gas limit mismatch: %d != %d", block.GasLimit(), meta.GasLimit+consensus.AnchorV3GasLimit)
	}
	if block.Time() != meta.Timestamp {
		err = fmt.Errorf("timestamp mismatch: %d != %d", block.Time(), meta.Timestamp)
	}
	if !bytes.Equal(block.Extra(), meta.ExtraData) {
		err = fmt.Errorf("extra data mismatch: %s != %s", block.Extra(), meta.ExtraData)
	}
	if block.BaseFee().Cmp(meta.BaseFee) != 0 {
		err = fmt.Errorf("base fee mismatch: %s != %s", block.BaseFee(), meta.BaseFee)
	}
	if block.Withdrawals().Len() != 0 {
		err = fmt.Errorf("withdrawals mismatch: %d != 0", block.Withdrawals().Len())
	}

	if err != nil {
		log.Debug("Failed to check if the block is preconfirmed", "error", err)
		return nil, nil
	}

	return block.Header(), nil
}
