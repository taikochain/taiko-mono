package message

import (
	"context"
	"time"

	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/pkg/errors"
	log "github.com/sirupsen/logrus"
	"github.com/taikoxyz/taiko-mono/packages/relayer/contracts"
)

func (p *Processor) waitHeaderSynced(ctx context.Context, event *contracts.BridgeMessageSent) error {
	ticker := time.NewTicker(time.Duration(p.headerSyncIntervalSeconds) * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
			// get latest synced header since not every header is synced from L1 => L2,
			// and later blocks still have the storage trie proof from previous blocks.
			latestSyncedHeader, err := p.destHeaderSyncer.GetLatestSyncedHeader(&bind.CallOpts{})
			if err != nil {
				return errors.Wrap(err, "p.destHeaderSyncer.GetLatestSyncedHeader")
			}

			block, err := p.srcEthClient.BlockByHash(ctx, latestSyncedHeader)
			if err != nil {
				return errors.Wrap(err, "p.destHeaderSyncer.GetLatestSyncedHeader")
			}

			// header is caught up and processible
			if block.NumberU64() >= event.Raw.BlockNumber {
				log.Infof(
					"signal: %v is processable. occured in block %v, latestSynced is block %v",
					common.Hash(event.Signal).Hex(),
					event.Raw.BlockNumber,
					block.NumberU64(),
				)

				return nil
			}

			log.Infof(
				"signal: %v waiting to be processable. occured in block %v, latestSynced is block %v",
				common.Hash(event.Signal).Hex(),
				event.Raw.BlockNumber,
				block.NumberU64(),
			)
		}
	}
}
