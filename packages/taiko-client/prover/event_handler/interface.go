package handler

import (
	"context"

	"github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/metadata"
	eventIterator "github.com/taikoxyz/taiko-mono/packages/taiko-client/pkg/chain_iterator/event_iterator"
)

// BlockProposedHandler is the interface for handling `TaikoL1.BlockProposed` events.
type BlockProposedHandler interface {
	Handle(ctx context.Context,
		meta metadata.TaikoBlockMetaData,
		end eventIterator.EndBlockProposedEventIterFunc,
	) error
}

// TransitionContestedHandler is the interface for handling `TaikoL1.TransitionContestedV2` events.
type TransitionContestedHandler interface {
	Handle(ctx context.Context, event *bindings.TaikoL1ClientTransitionContestedV2) error
}

// TransitionProvedHandler is the interface for handling `TaikoL1.TransitionProvedV2` events.
type TransitionProvedHandler interface {
	Handle(ctx context.Context, event *bindings.TaikoL1ClientTransitionProvedV2) error
}

// BlockVerifiedHandler is the interface for handling `TaikoL1.BlockVerifiedV2` events.
type BlockVerifiedHandler interface {
	Handle(e *bindings.TaikoL1ClientBlockVerifiedV2)
}

// AssignmentExpiredHandler is the interface for handling the proof assignment expiration.
type AssignmentExpiredHandler interface {
	Handle(ctx context.Context, meta metadata.TaikoBlockMetaData) error
}
