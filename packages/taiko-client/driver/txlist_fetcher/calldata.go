package txlistfetcher

import (
	"context"
	"fmt"
	"math/big"

	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/core/types"

	"github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/encoding"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/metadata"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/pkg"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/pkg/rpc"
)

// CalldataFetcher is responsible for fetching the txList bytes from the transaction's calldata.
type CalldataFetcher struct {
	rpc *rpc.Client
}

// NewCalldataFetch creates a new CalldataFetcher instance based on the given rpc client.
func NewCalldataFetch(rpc *rpc.Client) *CalldataFetcher {
	return &CalldataFetcher{rpc: rpc}
}

// Fetch fetches the txList bytes from the transaction's calldata, by parsing the `BlockProposedV2` event.
func (d *CalldataFetcher) FetchOntake(
	ctx context.Context,
	tx *types.Transaction,
	meta metadata.TaikoBlockMetaDataOntake,
) ([]byte, error) {
	if meta.GetBlobUsed() {
		return nil, pkg.ErrBlobUsed
	}

	// Fetch the txlist data from the `CalldataTxList` event.
	end := meta.GetRawBlockHeight().Uint64()
	iter, err := d.rpc.OntakeClients.TaikoL1.FilterCalldataTxList(
		&bind.FilterOpts{Context: ctx, Start: meta.GetRawBlockHeight().Uint64(), End: &end},
		[]*big.Int{meta.GetBlockID()},
	)
	if err != nil {
		return nil, err
	}
	for iter.Next() {
		return iter.Event.TxList, nil
	}

	if iter.Error() != nil {
		return nil, fmt.Errorf(
			"failed to fetch calldata for block %d: %w", meta.GetBlockID(), iter.Error(),
		)
	}

	return nil, fmt.Errorf("calldata for block %d not found", meta.GetBlockID())
}

// FetchPacaya fetches the txList bytes from the transaction's calldata, by parsing the `BatchProposed` event.
func (d *CalldataFetcher) FetchPacaya(
	ctx context.Context,
	tx *types.Transaction,
	meta metadata.TaikoBatchMetaDataPacaya,
) ([]byte, error) {
	if len(meta.GetBlobHashes()) != 0 {
		return nil, pkg.ErrBlobUsed
	}

	txList, err := encoding.UnpackTxListBytes(tx.Data())
	if err != nil {
		return nil, fmt.Errorf("failed to unpack txList bytes: %w", err)
	}

	return sliceTxList(meta.GetBatchID(), txList, meta.GetTxListOffset(), meta.GetTxListSize())
}
