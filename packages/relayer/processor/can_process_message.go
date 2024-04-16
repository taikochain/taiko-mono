package processor

import (
	"context"
	"log/slog"
	"math/big"

	"github.com/ethereum/go-ethereum/common"
	"github.com/taikoxyz/taiko-mono/packages/relayer"
)

// canProcessMessage determines whether a message is processable by the relayer.
// There are several conditions under which it would not be processable, including:
// - the event status is New, and the GasLimit is 0, which means only the user who
// sent the message can process it.
// - the event status is not New, which means it is either already processed and succeeded,
// or it is processed, failed, and is in Retriable or Failed state, where the user
// should finish manually.
func canProcessMessage(
	ctx context.Context,
	eventStatus relayer.EventStatus,
	messageOwner common.Address,
	relayerAddress common.Address,
	gasLimit *big.Int,
) bool {
	// We cannot process, exit early.
	if eventStatus == relayer.EventStatusNew && gasLimit == nil || gasLimit.Cmp(common.Big0) == 0 {
		if messageOwner != relayerAddress {
			slog.Info("gasLimit == 0 and owner is not the current relayer key, can not process.")
			return false
		}

		return true
	}

	if eventStatus == relayer.EventStatusNew {
		return true
	}

	slog.Info("cant process message", "eventStatus", eventStatus.String())

	return false
}
