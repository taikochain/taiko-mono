package builder

import (
	"context"
	"crypto/ecdsa"
	"fmt"
	"math/big"

	"github.com/ethereum-optimism/optimism/op-service/eth"
	"github.com/ethereum-optimism/optimism/op-service/txmgr"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/rlp"

	"github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/encoding"
	pacayaBindings "github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/pacaya"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/pkg/config"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/pkg/rpc"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/pkg/utils"
)

// BlobTransactionBuilder is responsible for building a TaikoL1.proposeBlock transaction with txList
// bytes saved in blob.
type BlobTransactionBuilder struct {
	rpc                     *rpc.Client
	proposerPrivateKey      *ecdsa.PrivateKey
	taikoL1Address          common.Address
	proverSetAddress        common.Address
	l2SuggestedFeeRecipient common.Address
	gasLimit                uint64
	chainConfig             *config.ChainConfig
	revertProtectionEnabled bool
}

// NewBlobTransactionBuilder creates a new BlobTransactionBuilder instance based on giving configurations.
func NewBlobTransactionBuilder(
	rpc *rpc.Client,
	proposerPrivateKey *ecdsa.PrivateKey,
	taikoL1Address common.Address,
	proverSetAddress common.Address,
	l2SuggestedFeeRecipient common.Address,
	gasLimit uint64,
	chainConfig *config.ChainConfig,
	revertProtectionEnabled bool,
) *BlobTransactionBuilder {
	return &BlobTransactionBuilder{
		rpc,
		proposerPrivateKey,
		taikoL1Address,
		proverSetAddress,
		l2SuggestedFeeRecipient,
		gasLimit,
		chainConfig,
		revertProtectionEnabled,
	}
}

// BuildOntake implements the ProposeBlockTransactionBuilder interface.
func (b *BlobTransactionBuilder) BuildOntake(
	ctx context.Context,
	txListBytesArray [][]byte,
) (*txmgr.TxCandidate, error) {
	// Check if the current L2 chain is after ontake fork.
	_, slotB, err := b.rpc.GetProtocolStateVariablesOntake(&bind.CallOpts{Context: ctx})
	if err != nil {
		return nil, err
	}

	if !b.chainConfig.IsOntake(new(big.Int).SetUint64(slotB.NumBlocks)) {
		return nil, fmt.Errorf("ontake transaction builder is not supported before ontake fork")
	}

	// ABI encode the TaikoL1.proposeBlocksV2 / ProverSet.proposeBlocksV2 parameters.
	var (
		to                 = &b.taikoL1Address
		data               []byte
		blobs              []*eth.Blob
		encodedParamsArray [][]byte
	)
	if b.proverSetAddress != rpc.ZeroAddress {
		to = &b.proverSetAddress
	}

	for i := range txListBytesArray {
		var blob = &eth.Blob{}
		if err := blob.FromData(txListBytesArray[i]); err != nil {
			return nil, err
		}

		blobs = append(blobs, blob)

		encodedParams, err := encoding.EncodeBlockParamsOntake(&encoding.BlockParamsV2{
			Coinbase:         b.l2SuggestedFeeRecipient,
			ParentMetaHash:   [32]byte{},
			AnchorBlockId:    0,
			Timestamp:        0,
			BlobTxListOffset: 0,
			BlobTxListLength: uint32(len(txListBytesArray[i])),
			BlobIndex:        uint8(i),
		})
		if err != nil {
			return nil, err
		}

		encodedParamsArray = append(encodedParamsArray, encodedParams)
	}
	txListArray := make([][]byte, len(encodedParamsArray))
	if b.proverSetAddress != rpc.ZeroAddress {
		if b.revertProtectionEnabled {
			data, err = encoding.ProverSetABI.Pack("proposeBlocksV2Conditionally", encodedParamsArray, txListArray)
		} else {
			data, err = encoding.ProverSetABI.Pack("proposeBlocksV2", encodedParamsArray, txListArray)
		}
		if err != nil {
			return nil, err
		}
	} else {
		data, err = encoding.TaikoL1ABI.Pack("proposeBlocksV2", encodedParamsArray, txListArray)
		if err != nil {
			return nil, err
		}
	}

	return &txmgr.TxCandidate{
		TxData:   data,
		Blobs:    blobs,
		To:       to,
		GasLimit: b.gasLimit,
	}, nil
}

// BuildPacaya implements the ProposeBlocksTransactionBuilder interface.
func (b *BlobTransactionBuilder) BuildPacaya(
	ctx context.Context,
	txBatch []types.Transactions,
) (*txmgr.TxCandidate, error) {
	// ABI encode the TaikoInbox.proposeBatch / ProverSet.proposeBatch parameters.
	var (
		to            = &b.taikoL1Address
		data          []byte
		blobs         []*eth.Blob
		encodedParams []byte
		blockParams   []pacayaBindings.ITaikoInboxBlockParams
		allTxs        types.Transactions
	)

	for _, txs := range txBatch {
		allTxs = append(allTxs, txs...)
		blockParams = append(blockParams, pacayaBindings.ITaikoInboxBlockParams{
			NumTransactions: uint16(len(txs)),
			TimeShift:       0,
		})
	}

	rlpEncoded, err := rlp.EncodeToBytes(allTxs)
	if err != nil {
		return nil, fmt.Errorf("failed to encode transactions: %w", err)
	}
	txListsBytes, err := utils.Compress(rlpEncoded)
	if err != nil {
		return nil, fmt.Errorf("failed to compress transactions: %w", err)
	}

	if blobs, err = b.splitToBlobs(txListsBytes); err != nil {
		return nil, err
	}

	if encodedParams, err = encoding.EncodeBatchParams(&encoding.BatchParams{
		Coinbase:                 b.l2SuggestedFeeRecipient,
		TxListOffset:             0,
		TxListSize:               uint32(len(txListsBytes)),
		FirstBlobIndex:           0,
		NumBlobs:                 uint8(len(blobs)),
		RevertIfNotFirstProposal: b.revertProtectionEnabled,
		Blocks:                   blockParams,
	}); err != nil {
		return nil, err
	}

	if b.proverSetAddress != rpc.ZeroAddress {
		to = &b.proverSetAddress

		if data, err = encoding.ProverSetPavayaABI.Pack("proposeBatch", encodedParams, []byte{}); err != nil {
			return nil, err
		}
	} else {
		if data, err = encoding.TaikoInboxABI.Pack("proposeBatch", encodedParams, []byte{}); err != nil {
			return nil, err
		}
	}

	return &txmgr.TxCandidate{
		TxData:   data,
		Blobs:    blobs,
		To:       to,
		GasLimit: b.gasLimit,
	}, nil
}

// splitToBlobs splits the txListBytes into multiple blobs.
func (b *BlobTransactionBuilder) splitToBlobs(txListBytes []byte) ([]*eth.Blob, error) {
	var blobs []*eth.Blob
	for start := 0; start < len(txListBytes); start += rpc.BlobBytes {
		end := start + rpc.BlobBytes
		if end > len(txListBytes) {
			end = len(txListBytes)
		}

		var blob = &eth.Blob{}
		if err := blob.FromData(txListBytes[start:end]); err != nil {
			return nil, err
		}

		blobs = append(blobs, blob)
	}

	return blobs, nil
}
