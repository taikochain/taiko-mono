package repo

import (
	"context"
	"net/http"

	"github.com/morkid/paginate"
	"github.com/pkg/errors"
	"github.com/taikoxyz/taiko-mono/packages/eventindexer"
	"gorm.io/gorm"
)

type NFTMetadataRepository struct {
	db eventindexer.DB
}

func NewNFTMetadataRepository(db eventindexer.DB) (*NFTMetadataRepository, error) {
	if db == nil {
		return nil, eventindexer.ErrNoDB
	}

	return &NFTMetadataRepository{
		db: db,
	}, nil
}

func (r *NFTMetadataRepository) SaveNFTMetadata(
	ctx context.Context,
	metadata *eventindexer.NFTMetadata,
) (*eventindexer.NFTMetadata, error) {
	err := r.db.GormDB().Save(metadata).Error
	if err != nil {
		return nil, errors.Wrap(err, "r.db.Save")
	}

	return metadata, nil
}

func (r *NFTMetadataRepository) GetNFTMetadata(
	ctx context.Context,
	contractAddress string,
	tokenID string,
) (*eventindexer.NFTMetadata, error) {
	metadata := &eventindexer.NFTMetadata{}

	err := r.db.GormDB().
		Where("contract_address = ?", contractAddress).
		Where("token_id = ?", tokenID).
		First(metadata).
		Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return nil, nil
		}
		return nil, errors.Wrap(err, "r.db.First")
	}

	return metadata, nil
}

func (r *NFTMetadataRepository) FindByContractAddress(
	ctx context.Context,
	req *http.Request,
	contractAddress string,
) (paginate.Page, error) {
	pg := paginate.New(&paginate.Config{
		DefaultSize: 100,
	})

	q := r.db.GormDB().
		Raw("SELECT * FROM nft_metadata WHERE contract_address = ?", contractAddress)

	reqCtx := pg.With(q)

	page := reqCtx.Request(req).Response(&[]eventindexer.NFTMetadata{})

	return page, nil
}
