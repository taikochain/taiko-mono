package repo

import (
	"context"
	"math/big"
	"time"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/pkg/errors"
	"github.com/shopspring/decimal"
	"github.com/taikoxyz/taiko-mono/packages/eventindexer"
)

type TransactionRepository struct {
	db eventindexer.DB
}

func NewTransactionRepository(db eventindexer.DB) (*TransactionRepository, error) {
	if db == nil {
		return nil, eventindexer.ErrNoDB
	}

	return &TransactionRepository{
		db: db,
	}, nil
}

func (r *TransactionRepository) Save(
	ctx context.Context,
	tx *types.Transaction,
	sender common.Address,
	blockID *big.Int,
	transactedAt time.Time,
) error {
	t := &eventindexer.Transaction{
		ChainID:      tx.ChainId().Int64(),
		Sender:       sender.Hex(),
		BlockID:      blockID.Int64(),
		GasPrice:     tx.GasPrice().String(),
		TransactedAt: transactedAt,
	}

	if to := tx.To(); to != nil {
		t.Recipient = to.Hex()
	}

	if tx.Value() != nil {
		v, err := decimal.NewFromString(tx.Value().String())
		if err != nil {
			return errors.Wrap(err, "decimal.NewFromString")
		}

		t.Amount = decimal.NullDecimal{
			Valid:   true,
			Decimal: v,
		}
	}

	if err := r.db.GormDB().Create(t).Error; err != nil {
		return errors.Wrap(err, "r.db.Create")
	}

	return nil
}
