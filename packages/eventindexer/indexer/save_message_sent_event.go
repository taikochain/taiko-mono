package indexer

import (
	"context"
	"encoding/json"
	"math/big"
	"time"

	"log/slog"

	"github.com/ethereum/go-ethereum/common"
	"github.com/pkg/errors"
	"github.com/taikoxyz/taiko-mono/packages/eventindexer"
	"github.com/taikoxyz/taiko-mono/packages/eventindexer/contracts/bridge"
)

var (
	minEthAmount = new(big.Int).SetUint64(150000000000000000)
	zeroHash     = common.HexToHash("0x0000000000000000000000000000000000000000000000000000000000000000")
)

func (indxr *Indexer) saveMessageSentEvents(
	ctx context.Context,
	chainID *big.Int,
	events *bridge.BridgeMessageSentIterator,
) error {
	if !events.Next() || events.Event == nil {
		slog.Info("no MessageSent events")
		return nil
	}

	for {
		event := events.Event

		slog.Info("new messageSent event", "owner", event.Message.From.Hex())

		if err := indxr.saveMessageSentEvent(ctx, chainID, event); err != nil {
			eventindexer.MessageSentEventsProcessedError.Inc()

			return errors.Wrap(err, "indxr.saveMessageSentEvent")
		}

		if !events.Next() {
			return nil
		}
	}
}

func (indxr *Indexer) saveMessageSentEvent(
	ctx context.Context,
	chainID *big.Int,
	event *bridge.BridgeMessageSent,
) error {
	marshaled, err := json.Marshal(event)
	if err != nil {
		return errors.Wrap(err, "json.Marshal(event)")
	}

	block, err := indxr.ethClient.BlockByNumber(ctx, new(big.Int).SetUint64(event.Raw.BlockNumber))
	if err != nil {
		return errors.Wrap(err, "indxr.ethClient.BlockByNumber")
	}

	_, err = indxr.eventRepo.Save(ctx, eventindexer.SaveEventOpts{
		Name:         eventindexer.EventNameMessageSent,
		Data:         string(marshaled),
		ChainID:      chainID,
		Event:        eventindexer.EventNameMessageSent,
		Address:      event.Message.From.Hex(),
		TransactedAt: time.Unix(int64(block.Time()), 0),
	})
	if err != nil {
		return errors.Wrap(err, "indxr.eventRepo.Save")
	}

	eventindexer.MessageSentEventsProcessed.Inc()

	return nil
}
