package indexer

import (
	"context"
	"database/sql"
	"fmt"
	"log/slog"
	"math/big"
	"time"

	"github.com/cyberhorsey/errors"
	"github.com/ethereum/go-ethereum"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/labstack/echo/v4"
	"github.com/labstack/gommon/log"
	"github.com/taikoxyz/taiko-mono/packages/relayer"
	"github.com/taikoxyz/taiko-mono/packages/relayer/bindings/bridge"
	"github.com/taikoxyz/taiko-mono/packages/relayer/bindings/taikol1"
	"github.com/taikoxyz/taiko-mono/packages/relayer/indexer/http"
	"github.com/taikoxyz/taiko-mono/packages/relayer/queue"
	"github.com/taikoxyz/taiko-mono/packages/relayer/repo"
	"github.com/urfave/cli/v2"
	"golang.org/x/sync/errgroup"
	"gorm.io/gorm"
)

var (
	ZeroAddress = common.HexToAddress("0x0000000000000000000000000000000000000000")
)

var (
	eventName = relayer.EventNameMessageSent
)

type WatchMode string

var (
	Filter             WatchMode = "filter"
	Subscribe          WatchMode = "subscribe"
	FilterAndSubscribe WatchMode = "filter-and-subscribe"
	WatchModes                   = []WatchMode{Filter, Subscribe, FilterAndSubscribe}
)

type SyncMode string

var (
	Sync   SyncMode = "sync"
	Resync SyncMode = "resync"
	Modes           = []SyncMode{Sync, Resync}
)

type ethClient interface {
	ChainID(ctx context.Context) (*big.Int, error)
	HeaderByNumber(ctx context.Context, number *big.Int) (*types.Header, error)
	SubscribeNewHead(ctx context.Context, ch chan<- *types.Header) (ethereum.Subscription, error)
}

type DB interface {
	DB() (*sql.DB, error)
	GormDB() *gorm.DB
}

type Indexer struct {
	eventRepo    relayer.EventRepository
	blockRepo    relayer.BlockRepository
	srcEthClient ethClient

	processingBlockHeight uint64

	bridge     relayer.Bridge
	destBridge relayer.Bridge

	blockBatchSize      uint64
	numGoroutines       int
	subscriptionBackoff time.Duration

	taikol1 *taikol1.TaikoL1

	queue queue.Queue

	srcChainId *big.Int

	watchMode WatchMode
	syncMode  SyncMode

	srv      *http.Server
	httpPort uint64
}

func (i *Indexer) InitFromCli(ctx context.Context, c *cli.Context) error {
	cfg, err := NewConfigFromCliContext(c)
	if err != nil {
		return err
	}

	return InitFromConfig(ctx, i, cfg)
}

func InitFromConfig(ctx context.Context, i *Indexer, cfg *Config) (err error) {
	db, err := cfg.OpenDBFunc()
	if err != nil {
		return err
	}

	eventRepository, err := repo.NewEventRepository(db)
	if err != nil {
		return err
	}

	blockRepository, err := repo.NewBlockRepository(db)
	if err != nil {
		return err
	}

	srcEthClient, err := ethclient.Dial(cfg.SrcRPCUrl)
	if err != nil {
		return err
	}

	destEthClient, err := ethclient.Dial(cfg.DestRPCUrl)
	if err != nil {
		return err
	}

	srv, err := http.NewServer(http.NewServerOpts{
		EventRepo:     eventRepository,
		Echo:          echo.New(),
		CorsOrigins:   cfg.CORSOrigins,
		SrcEthClient:  srcEthClient,
		DestEthClient: destEthClient,
		BlockRepo:     blockRepository,
	})
	if err != nil {
		return err
	}

	q, err := cfg.OpenQueueFunc()
	if err != nil {
		return err
	}

	srcBridge, err := bridge.NewBridge(cfg.SrcBridgeAddress, srcEthClient)
	if err != nil {
		return errors.Wrap(err, "bridge.NewBridge")
	}

	destBridge, err := bridge.NewBridge(cfg.DestBridgeAddress, destEthClient)
	if err != nil {
		return errors.Wrap(err, "bridge.NewBridge")
	}

	var taikoL1 *taikol1.TaikoL1
	if cfg.SrcTaikoAddress != ZeroAddress {
		taikoL1, err = taikol1.NewTaikoL1(cfg.SrcTaikoAddress, srcEthClient)
		if err != nil {
			return errors.Wrap(err, "taikol1.NewTaikoL1")
		}
	}

	chainID, err := srcEthClient.ChainID(context.Background())
	if err != nil {
		return errors.Wrap(err, "cfg.EthClient.ChainID")
	}

	i.blockRepo = blockRepository
	i.eventRepo = eventRepository
	i.srcEthClient = srcEthClient

	i.bridge = srcBridge
	i.destBridge = destBridge
	i.taikol1 = taikoL1

	i.blockBatchSize = cfg.BlockBatchSize
	i.numGoroutines = int(cfg.NumGoroutines)
	i.subscriptionBackoff = time.Duration(cfg.SubscriptionBackoff) * time.Second

	i.queue = q

	i.srv = srv
	i.httpPort = cfg.HTTPPort

	i.srcChainId = chainID

	i.syncMode = cfg.SyncMode
	i.watchMode = cfg.WatchMode

	return nil
}

func (i *Indexer) Name() string {
	return "indexer"
}

// TODO
func (i *Indexer) Close(ctx context.Context) {
	if err := i.srv.Shutdown(ctx); err != nil {
		slog.Error("srv shutdown", "error", err)
	}
}

// nolint: funlen
func (i *Indexer) Start() error {
	go func() {
		if err := i.srv.Start(fmt.Sprintf(":%v", i.httpPort)); err != nil {
			slog.Error("http srv start", "error", err.Error())
		}
	}()

	ctx := context.Background()

	if err := i.queue.Start(ctx, i.queueName()); err != nil {
		return err
	}

	return i.filter(ctx)
}

func (i *Indexer) filter(ctx context.Context) error {
	chainID, err := i.srcEthClient.ChainID(ctx)
	if err != nil {
		return errors.Wrap(err, "i.srcEthClient.ChainID()")
	}

	go scanBlocks(ctx, i.srcEthClient, chainID)

	// if subscribing to new events, skip filtering and subscribe
	if i.watchMode == Subscribe {
		return i.subscribe(ctx, chainID)
	}

	if err := i.setInitialProcessingBlockByMode(ctx, i.syncMode, chainID); err != nil {
		return errors.Wrap(err, "i.setInitialProcessingBlockByMode")
	}

	header, err := i.srcEthClient.HeaderByNumber(ctx, nil)
	if err != nil {
		return errors.Wrap(err, "i.srcEthClient.HeaderByNumber")
	}

	if i.processingBlockHeight == header.Number.Uint64() {
		slog.Info("indexing caught up, subscribing to new incoming events", "chainID", chainID.Uint64())
		return i.subscribe(ctx, chainID)
	}

	slog.Info("fetching batch block events",
		"chainID", chainID.Uint64(),
		"startblock", i.processingBlockHeight,
		"endblock", header.Number.Int64(),
		"batchsize", i.blockBatchSize,
	)

	for j := i.processingBlockHeight; j < header.Number.Uint64(); j += i.blockBatchSize {
		end := i.processingBlockHeight + i.blockBatchSize
		// if the end of the batch is greater than the latest block number, set end
		// to the latest block number
		if end > header.Number.Uint64() {
			end = header.Number.Uint64()
		}

		// filter exclusive of the end block.
		// we use "end" as the next starting point of the batch, and
		// process up to end - 1 for this batch.
		filterEnd := end - 1

		fmt.Printf("block batch from %v to %v", j, filterEnd)
		fmt.Println()

		filterOpts := &bind.FilterOpts{
			Start:   i.processingBlockHeight,
			End:     &filterEnd,
			Context: ctx,
		}

		messageStatusChangedEvents, err := i.bridge.FilterMessageStatusChanged(filterOpts, nil)
		if err != nil {
			return errors.Wrap(err, "bridge.FilterMessageStatusChanged")
		}

		// we dont need to do anything with msgStatus events except save them to the DB.
		// we dont need to process them. they are for exposing via the API.

		err = i.saveMessageStatusChangedEvents(ctx, chainID, messageStatusChangedEvents)
		if err != nil {
			return errors.Wrap(err, "bridge.saveMessageStatusChangedEvents")
		}

		messageSentEvents, err := i.bridge.FilterMessageSent(filterOpts, nil)
		if err != nil {
			return errors.Wrap(err, "bridge.FilterMessageSent")
		}

		if !messageSentEvents.Next() || messageSentEvents.Event == nil {
			// use "end" not "filterEnd" here, because it will be used as the start
			// of the next batch.
			if err := i.handleNoEventsInBatch(ctx, chainID, int64(end)); err != nil {
				return errors.Wrap(err, "i.handleNoEventsInBatch")
			}

			continue
		}

		group, groupCtx := errgroup.WithContext(ctx)

		group.SetLimit(i.numGoroutines)

		for {
			event := messageSentEvents.Event

			group.Go(func() error {
				err := i.handleEvent(groupCtx, chainID, event)
				if err != nil {
					relayer.ErrorEvents.Inc()
					// log error but always return nil to keep other goroutines active
					log.Error(err.Error())
				}

				return nil
			})

			// if there are no more events
			if !messageSentEvents.Next() {
				// wait for the last of the goroutines to finish
				if err := group.Wait(); err != nil {
					return errors.Wrap(err, "group.Wait")
				}
				// handle no events remaining, saving the processing block and restarting the for
				// loop
				if err := i.handleNoEventsInBatch(ctx, chainID, int64(end)); err != nil {
					return errors.Wrap(err, "i.handleNoEventsInBatch")
				}

				break
			}
		}
	}

	slog.Info(
		"indexer fully caught up, checking latest block number to see if it's advanced",
	)

	latestBlock, err := i.srcEthClient.HeaderByNumber(ctx, nil)
	if err != nil {
		return errors.Wrap(err, "i.srcEthClient.HeaderByNumber")
	}

	if i.processingBlockHeight < latestBlock.Number.Uint64() {
		return i.Start()
	}

	// we are caught up and specified not to subscribe, we can return now
	if i.watchMode == Filter {
		return nil
	}

	return i.subscribe(ctx, chainID)
}

func (i *Indexer) queueName() string {
	return fmt.Sprintf("%v-queue", i.srcChainId.String())
}
