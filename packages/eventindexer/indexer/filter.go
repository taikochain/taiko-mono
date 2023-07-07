package indexer

import (
	"context"
	"math/big"

	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/pkg/errors"
)

type filterFunc func(
	ctx context.Context,
	chainID *big.Int,
	svc *Service,
	filterOpts *bind.FilterOpts,
) error

func L1FilterFunc(
	ctx context.Context,
	chainID *big.Int,
	svc *Service,
	filterOpts *bind.FilterOpts,
) error {
	blockProvenEvents, err := svc.taikol1.FilterBlockProven(filterOpts, nil)
	if err != nil {
		return errors.Wrap(err, "svc.taikol1.FilterBlockProven")
	}

	err = svc.saveBlockProvenEvents(ctx, chainID, blockProvenEvents)
	if err != nil {
		return errors.Wrap(err, "svc.saveBlockProvenEvents")
	}

	blockProposedEvents, err := svc.taikol1.FilterBlockProposed(filterOpts, nil)
	if err != nil {
		return errors.Wrap(err, "svc.taikol1.FilterBlockProposed")
	}

	err = svc.saveBlockProposedEvents(ctx, chainID, blockProposedEvents)
	if err != nil {
		return errors.Wrap(err, "svc.saveBlockProposedEvents")
	}

	blockVerifiedEvents, err := svc.taikol1.FilterBlockVerified(filterOpts, nil)
	if err != nil {
		return errors.Wrap(err, "svc.taikol1.FilterBlockVerified")
	}

	err = svc.saveBlockVerifiedEvents(ctx, chainID, blockVerifiedEvents)
	if err != nil {
		return errors.Wrap(err, "svc.saveBlockVerifiedEvents")
	}

	messagesSent, err := svc.bridge.FilterMessageSent(filterOpts, nil)
	if err != nil {
		return errors.Wrap(err, "svc.bridge.FilterMessageSent")
	}

	err = svc.saveMessageSentEvents(ctx, chainID, messagesSent)
	if err != nil {
		return errors.Wrap(err, "svc.saveMessageSentEvents")
	}

	return nil
}
