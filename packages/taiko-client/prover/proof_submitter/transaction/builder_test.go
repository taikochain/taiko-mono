package transaction

import (
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"

	"github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/metadata"
)

func (s *TransactionTestSuite) TestBuildTxs() {
	_, err := s.builder.Build(
		common.Big256,
		&metadata.TaikoDataBlockMetadataOntake{TaikoDataBlockMetadataV2: bindings.TaikoDataBlockMetadataV2{
			AnchorBlockHash: [32]byte{},
			Difficulty:      [32]byte{},
			BlobHash:        [32]byte{},
			ExtraData:       [32]byte{},
			ParentMetaHash:  [32]byte{},
			LivenessBond:    common.Big0,
		}},
		&bindings.TaikoDataTransition{},
		&bindings.TaikoDataTierProof{},
		1,
	)(&bind.TransactOpts{Nonce: common.Big0, GasLimit: 0, GasTipCap: common.Big0})
	s.Nil(err)
}
