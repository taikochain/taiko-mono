package eventiterator

import (
	"context"
	"errors"
	"math/big"

	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/core/types"

	"github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/metadata"
	ontakeBindings "github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/ontake"
	pacayaBindings "github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/pacaya"
	chainIterator "github.com/taikoxyz/taiko-mono/packages/taiko-client/pkg/chain_iterator"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/pkg/rpc"
)

// EndBlockProposedEventIterFunc ends the current iteration.
type EndBlockProposedEventIterFunc func()

// OnBlockProposedEvent represents the callback function which will be called when a TaikoL1.BlockProposed event is
// iterated.
type OnBlockProposedEvent func(
	context.Context,
	metadata.TaikoBlockMetaData,
	EndBlockProposedEventIterFunc,
) error

// BlockProposedIterator iterates the emitted TaikoL1.BlockProposed events in the chain,
// with the awareness of reorganization.
type BlockProposedIterator struct {
	ctx                context.Context
	taikoL1            *ontakeBindings.TaikoL1Client
	taikoInbox         *pacayaBindings.TaikoInboxClient
	blockBatchIterator *chainIterator.BlockBatchIterator
	isEnd              bool
}

// BlockProposedIteratorConfig represents the configs of a BlockProposed event iterator.
type BlockProposedIteratorConfig struct {
	Client                *rpc.EthClient
	TaikoL1               *ontakeBindings.TaikoL1Client
	TaikoInbox            *pacayaBindings.TaikoInboxClient
	MaxBlocksReadPerEpoch *uint64
	StartHeight           *big.Int
	EndHeight             *big.Int
	OnBlockProposedEvent  OnBlockProposedEvent
	BlockConfirmations    *uint64
}

// NewBlockProposedIterator creates a new instance of BlockProposed event iterator.
func NewBlockProposedIterator(ctx context.Context, cfg *BlockProposedIteratorConfig) (*BlockProposedIterator, error) {
	if cfg.OnBlockProposedEvent == nil {
		return nil, errors.New("invalid callback")
	}

	iterator := &BlockProposedIterator{
		ctx:     ctx,
		taikoL1: cfg.TaikoL1,
	}

	// Initialize the inner block iterator.
	blockIterator, err := chainIterator.NewBlockBatchIterator(ctx, &chainIterator.BlockBatchIteratorConfig{
		Client:                cfg.Client,
		MaxBlocksReadPerEpoch: cfg.MaxBlocksReadPerEpoch,
		StartHeight:           cfg.StartHeight,
		EndHeight:             cfg.EndHeight,
		BlockConfirmations:    cfg.BlockConfirmations,
		OnBlocks: assembleBlockProposedIteratorCallback(
			cfg.Client,
			cfg.TaikoL1,
			cfg.TaikoInbox,
			cfg.OnBlockProposedEvent,
			iterator,
		),
	})
	if err != nil {
		return nil, err
	}

	iterator.blockBatchIterator = blockIterator

	return iterator, nil
}

// Iter iterates the given chain between the given start and end heights,
// will call the callback when a BlockProposed event is iterated.
func (i *BlockProposedIterator) Iter() error {
	return i.blockBatchIterator.Iter()
}

// end ends the current iteration.
func (i *BlockProposedIterator) end() {
	i.isEnd = true
}

// assembleBlockProposedIteratorCallback assembles the callback which will be used
// by a event iterator's inner block iterator.
func assembleBlockProposedIteratorCallback(
	client *rpc.EthClient,
	taikoL1 *ontakeBindings.TaikoL1Client,
	taikoInbox *pacayaBindings.TaikoInboxClient,
	callback OnBlockProposedEvent,
	eventIter *BlockProposedIterator,
) chainIterator.OnBlocksFunc {
	return func(
		ctx context.Context,
		start, end *types.Header,
		updateCurrentFunc chainIterator.UpdateCurrentFunc,
		endFunc chainIterator.EndIterFunc,
	) error {
		endHeight := end.Number.Uint64()

		iterOntake, err := taikoL1.FilterBlockProposedV2(
			&bind.FilterOpts{Start: start.Number.Uint64(), End: &endHeight, Context: ctx},
			nil,
		)
		if err != nil {
			return err
		}
		defer iterOntake.Close()

		for iterOntake.Next() {
			event := iterOntake.Event

			if err := callback(ctx, metadata.NewTaikoDataBlockMetadataOntake(event), eventIter.end); err != nil {
				return err
			}

			if eventIter.isEnd {
				endFunc()
				return nil
			}

			current, err := client.HeaderByHash(ctx, event.Raw.BlockHash)
			if err != nil {
				return err
			}

			updateCurrentFunc(current)
		}

		iterPacaya, err := taikoInbox.FilterBatchProposed(
			&bind.FilterOpts{Start: start.Number.Uint64(), End: &endHeight, Context: ctx},
		)
		if err != nil {
			return err
		}
		defer iterPacaya.Close()

		for iterOntake.Next() {
			event := iterOntake.Event

			if err := callback(ctx, metadata.NewTaikoDataBlockMetadataOntake(event), eventIter.end); err != nil {
				return err
			}

			if eventIter.isEnd {
				endFunc()
				return nil
			}

			current, err := client.HeaderByHash(ctx, event.Raw.BlockHash)
			if err != nil {
				return err
			}

			updateCurrentFunc(current)
		}

		// Check if there is any error during the iteration.
		if iterOntake.Error() != nil {
			return iterOntake.Error()
		}
		if iterPacaya.Error() != nil {
			return iterPacaya.Error()
		}

		return nil
	}
}
