package builder

import (
	"context"
	"os"
	"testing"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/stretchr/testify/suite"

	"github.com/taikoxyz/taiko-mono/packages/taiko-client/internal/testutils"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/pkg/config"
)

type TransactionBuilderTestSuite struct {
	testutils.ClientTestSuite
	calldataTxBuilder *CalldataTransactionBuilder
	blobTxBuiler      *BlobTransactionBuilder
}

func (s *TransactionBuilderTestSuite) SetupTest() {
	s.ClientTestSuite.SetupTest()

	l1ProposerPrivKey, err := crypto.ToECDSA(common.FromHex(os.Getenv("L1_PROPOSER_PRIVATE_KEY")))
	s.Nil(err)

	chainConfig := config.NewChainConfig(s.RPCClient.L2.ChainID, testutils.RandomHash().Big())

	s.calldataTxBuilder = NewCalldataTransactionBuilder(
		s.RPCClient,
		l1ProposerPrivKey,
		common.HexToAddress(os.Getenv("TAIKO_L2_ADDRESS")),
		common.HexToAddress(os.Getenv("TAIKO_L1_ADDRESS")),
		common.Address{},
		0,
		"test",
		chainConfig,
	)
	s.blobTxBuiler = NewBlobTransactionBuilder(
		s.RPCClient,
		l1ProposerPrivKey,
		common.HexToAddress(os.Getenv("TAIKO_L1_ADDRESS")),
		common.Address{},
		common.HexToAddress(os.Getenv("TAIKO_L2_ADDRESS")),
		10_000_000,
		"test",
		chainConfig,
	)
}

func (s *TransactionBuilderTestSuite) TestGetParentMetaHash() {
	metahash, err := getParentMetaHash(context.Background(), s.RPCClient)
	s.Nil(err)
	s.NotEmpty(metahash)
}

func TestTransactionBuilderTestSuite(t *testing.T) {
	suite.Run(t, new(TransactionBuilderTestSuite))
}
