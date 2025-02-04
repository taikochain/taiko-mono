package rpc

import (
	"context"

	"github.com/cenkalti/backoff/v4"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/event"
	"github.com/ethereum/go-ethereum/log"

	ontakeBindings "github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/ontake"
	pacayaBindings "github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/pacaya"
)

// SubscribeEvent creates a event subscription, will retry if the established subscription failed.
func SubscribeEvent(
	eventName string,
	handler func(ctx context.Context) (event.Subscription, error),
) event.Subscription {
	return event.ResubscribeErr(
		backoff.DefaultMaxInterval,
		func(ctx context.Context, err error) (event.Subscription, error) {
			if err != nil {
				log.Warn("Failed to subscribe protocol event, try resubscribing", "event", eventName, "error", err)
			}

			return handler(ctx)
		},
	)
}

// SubscribeBlockVerifiedV2 subscribes the protocol's BlockVerifiedV2 events.
func SubscribeBlockVerifiedV2(
	taikoL1 *ontakeBindings.TaikoL1Client,
	ch chan *ontakeBindings.TaikoL1ClientBlockVerifiedV2,
) event.Subscription {
	return SubscribeEvent("BlockVerifiedV2", func(ctx context.Context) (event.Subscription, error) {
		sub, err := taikoL1.WatchBlockVerifiedV2(nil, ch, nil, nil)
		if err != nil {
			log.Error("Create TaikoL1.BlockVerifiedV2 subscription error", "error", err)
			return nil, err
		}

		defer sub.Unsubscribe()

		return waitSubErr(ctx, sub)
	})
}

// SubscribeBatchesVerifiedPacaya subscribes the Pacaya protocol's BatchesVerified events.
func SubscribeBatchesVerifiedPacaya(
	taikoInbox *pacayaBindings.TaikoInboxClient,
	ch chan *pacayaBindings.TaikoInboxClientBatchesVerified,
) event.Subscription {
	return SubscribeEvent("BatchesVerified", func(ctx context.Context) (event.Subscription, error) {
		sub, err := taikoInbox.WatchBatchesVerified(nil, ch)
		if err != nil {
			log.Error("Create TaikoInbox.BatchesVerified subscription error", "error", err)
			return nil, err
		}

		defer sub.Unsubscribe()

		return waitSubErr(ctx, sub)
	})
}

// SubscribeBlockProposedV2 subscribes the protocol's BlockProposedV2 events.
func SubscribeBlockProposedV2(
	taikoL1 *ontakeBindings.TaikoL1Client,
	ch chan *ontakeBindings.TaikoL1ClientBlockProposedV2,
) event.Subscription {
	return SubscribeEvent("BlockProposedV2", func(ctx context.Context) (event.Subscription, error) {
		sub, err := taikoL1.WatchBlockProposedV2(nil, ch, nil)
		if err != nil {
			log.Error("Create TaikoL1.BlockProposedV2 subscription error", "error", err)
			return nil, err
		}

		defer sub.Unsubscribe()

		return waitSubErr(ctx, sub)
	})
}

// SubscribeBatchProposedPacaya subscribes the Pacaya protocol's BatchProposed events.
func SubscribeBatchProposedPacaya(
	taikoInbox *pacayaBindings.TaikoInboxClient,
	ch chan *pacayaBindings.TaikoInboxClientBatchProposed,
) event.Subscription {
	return SubscribeEvent("BatchProposed", func(ctx context.Context) (event.Subscription, error) {
		sub, err := taikoInbox.WatchBatchProposed(nil, ch)
		if err != nil {
			log.Error("Create TaikoInbox.BatchProposed subscription error", "error", err)
			return nil, err
		}

		defer sub.Unsubscribe()

		return waitSubErr(ctx, sub)
	})
}

// SubscribeTransitionProvedV2 subscribes the protocol's TransitionProvedV2 events.
func SubscribeTransitionProvedV2(
	taikoL1 *ontakeBindings.TaikoL1Client,
	ch chan *ontakeBindings.TaikoL1ClientTransitionProvedV2,
) event.Subscription {
	return SubscribeEvent("TransitionProvedV2", func(ctx context.Context) (event.Subscription, error) {
		sub, err := taikoL1.WatchTransitionProvedV2(nil, ch, nil)
		if err != nil {
			log.Error("Create TaikoL1.TransitionProvedV2 subscription error", "error", err)
			return nil, err
		}

		defer sub.Unsubscribe()

		return waitSubErr(ctx, sub)
	})
}

// SubscribeBatchesProvedPacaya subscribes the Pacaya protocol's BatchesProved events.
func SubscribeBatchesProvedPacaya(
	taikoInbox *pacayaBindings.TaikoInboxClient,
	ch chan *pacayaBindings.TaikoInboxClientBatchesProved,
) event.Subscription {
	return SubscribeEvent("BatchesProved", func(ctx context.Context) (event.Subscription, error) {
		sub, err := taikoInbox.WatchBatchesProved(nil, ch)
		if err != nil {
			log.Error("Create TaikoInbox.BatchesProved subscription error", "error", err)
			return nil, err
		}

		defer sub.Unsubscribe()

		return waitSubErr(ctx, sub)
	})
}

// SubscribeTransitionContestedV2 subscribes the protocol's TransitionContestedV2 events.
func SubscribeTransitionContestedV2(
	taikoL1 *ontakeBindings.TaikoL1Client,
	ch chan *ontakeBindings.TaikoL1ClientTransitionContestedV2,
) event.Subscription {
	return SubscribeEvent("TransitionContestedV2", func(ctx context.Context) (event.Subscription, error) {
		sub, err := taikoL1.WatchTransitionContestedV2(nil, ch, nil)
		if err != nil {
			log.Error("Create TaikoL1.TransitionContestedV2 subscription error", "error", err)
			return nil, err
		}

		defer sub.Unsubscribe()

		return waitSubErr(ctx, sub)
	})
}

// SubscribeChainHead subscribes the new chain heads.
func SubscribeChainHead(
	client *EthClient,
	ch chan *types.Header,
) event.Subscription {
	return SubscribeEvent("ChainHead", func(ctx context.Context) (event.Subscription, error) {
		sub, err := client.SubscribeNewHead(ctx, ch)
		if err != nil {
			log.Error("Create chain head subscription error", "error", err)
			return nil, err
		}

		defer sub.Unsubscribe()

		return waitSubErr(ctx, sub)
	})
}

// waitSubErr keeps waiting until the given subscription failed.
func waitSubErr(ctx context.Context, sub event.Subscription) (event.Subscription, error) {
	select {
	case err := <-sub.Err():
		return sub, err
	case <-ctx.Done():
		return sub, ctx.Err()
	}
}
