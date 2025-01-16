package blob

import (
	"context"
	"math/big"
	"os"
	"testing"
	"time"

	"github.com/ethereum-optimism/optimism/op-service/txmgr"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/crypto"
	"github.com/stretchr/testify/suite"

	"github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/metadata"
	ontakeBindings "github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/ontake"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/driver/chain_syncer/beaconsync"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/driver/state"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/internal/testutils"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/pkg/config"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/pkg/jwt"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/pkg/rpc"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/proposer"
)

type BlobSyncerTestSuite struct {
	testutils.ClientTestSuite
	s *Syncer
	p testutils.Proposer
}

func (s *BlobSyncerTestSuite) SetupTest() {
	s.ClientTestSuite.SetupTest()

	state2, err := state.New(context.Background(), s.RPCClient)
	s.Nil(err)

	syncer, err := NewSyncer(
		context.Background(),
		s.RPCClient,
		state2,
		beaconsync.NewSyncProgressTracker(s.RPCClient.L2, 1*time.Hour),
		0,
		nil,
		nil,
	)
	s.Nil(err)
	s.s = syncer

	s.initProposer()
}

// TODO: fix this test case
// func (s *BlobSyncerTestSuite) TestBlobSyncRobustness() {
// 	ctx := context.Background()

// 	meta := s.ProposeAndInsertValidBlock(s.p, s.s)

// 	block, err := s.RPCClient.L2.BlockByNumber(ctx, meta.GetBlockID())
// 	s.Nil(err)

// 	lastVerifiedBlockInfo, err := s.s.rpc.GetLastVerifiedBlock(ctx)
// 	s.Nil(err)

// 	txListBytes, err := rlp.EncodeToBytes(block.Transactions())
// 	s.Nil(err)

// 	parent, err := s.RPCClient.L2ParentByBlockID(context.Background(), meta.GetBlockID())
// 	s.Nil(err)

// 	// Reset l2 chain.
// 	s.Nil(rpc.SetHead(ctx, s.RPCClient.L2, common.Big0))

// 	attributes := &engine.PayloadAttributes{
// 		Timestamp:             meta.GetTimestamp(),
// 		Random:                meta.GetDifficulty(),
// 		SuggestedFeeRecipient: meta.GetCoinbase(),
// 		Withdrawals:           make([]*types.Withdrawal, 0),
// 		BlockMetadata: &engine.BlockMetadata{
// 			Beneficiary: meta.GetCoinbase(),
// 			GasLimit:    uint64(meta.GetGasLimit()) + taiko.AnchorGasLimit,
// 			Timestamp:   meta.GetTimestamp(),
// 			TxList:      txListBytes,
// 			MixHash:     meta.GetDifficulty(),
// 			ExtraData:   meta.GetExtraData(),
// 		},
// 		BaseFeePerGas: block.BaseFee(),
// 		L1Origin: &rawdb.L1Origin{
// 			BlockID:       meta.GetBlockID(),
// 			L2BlockHash:   common.Hash{}, // Will be set by taiko-geth.
// 			L1BlockHeight: meta.GetRawBlockHeight(),
// 			L1BlockHash:   meta.GetRawBlockHash(),
// 		},
// 	}

// 	step0 := func() *engine.ForkChoiceResponse {
// 		fcRes, err := s.RPCClient.L2Engine.ForkchoiceUpdate(
// 			ctx,
// 			&engine.ForkchoiceStateV1{HeadBlockHash: parent.Hash()},
// 			attributes,
// 		)
// 		s.Nil(err)
// 		s.Equal(engine.VALID, fcRes.PayloadStatus.Status)
// 		s.True(true, fcRes.PayloadID != nil)
// 		return fcRes
// 	}

// 	step1 := func(fcRes *engine.ForkChoiceResponse) *engine.ExecutableData {
// 		payload, err := s.RPCClient.L2Engine.GetPayload(ctx, fcRes.PayloadID)
// 		s.Nil(err)
// 		return payload
// 	}

// 	step2 := func(payload *engine.ExecutableData) *engine.ExecutableData {
// 		execStatus, err := s.RPCClient.L2Engine.NewPayload(ctx, payload)
// 		s.Nil(err)
// 		s.Equal(engine.VALID, execStatus.Status)
// 		return payload
// 	}

// 	step3 := func(payload *engine.ExecutableData) {
// 		fcRes, err := s.RPCClient.L2Engine.ForkchoiceUpdate(ctx, &engine.ForkchoiceStateV1{
// 			HeadBlockHash:      payload.BlockHash,
// 			SafeBlockHash:      lastVerifiedBlockInfo.BlockHash,
// 			FinalizedBlockHash: lastVerifiedBlockInfo.BlockHash,
// 		}, nil)
// 		s.Nil(err)
// 		s.Equal(engine.VALID, fcRes.PayloadStatus.Status)
// 	}

// 	loopSize := 10
// 	for i := 0; i < loopSize; i++ {
// 		step0()
// 	}

// 	for i := 0; i < loopSize; i++ {
// 		step1(step0())
// 	}

// 	for i := 0; i < loopSize; i++ {
// 		step2(step1(step0()))
// 	}

// 	step3(step2(step1(step0())))
// }

func (s *BlobSyncerTestSuite) TestProcessL1Blocks() {
	s.Nil(s.s.ProcessL1Blocks(context.Background()))
}

func (s *BlobSyncerTestSuite) TestProcessL1BlocksReorg() {
	s.ProposeAndInsertEmptyBlocks(s.p, s.s)
	s.Nil(s.s.ProcessL1Blocks(context.Background()))
}

func (s *BlobSyncerTestSuite) TestOnBlockProposed() {
	s.Nil(s.s.onBlockProposed(
		context.Background(),
		&metadata.TaikoDataBlockMetadataOntake{TaikoDataBlockMetadataV2: ontakeBindings.TaikoDataBlockMetadataV2{Id: 0}},
		func() {},
	))
	s.NotNil(s.s.onBlockProposed(
		context.Background(),
		&metadata.TaikoDataBlockMetadataOntake{TaikoDataBlockMetadataV2: ontakeBindings.TaikoDataBlockMetadataV2{Id: 1}},
		func() {},
	))
}

// TODO: fix this test case
// func (s *BlobSyncerTestSuite) TestInsertNewHead() {
// 	parent, err := s.s.rpc.L2.HeaderByNumber(context.Background(), nil)
// 	s.Nil(err)
// 	l1Head, err := s.s.rpc.L1.BlockByNumber(context.Background(), nil)
// 	s.Nil(err)
// 	protocolConfigs, err := s.s.rpc.OntakeClients.TaikoL1.GetConfig(nil)
// 	s.Nil(err)
// 	_, err = s.s.insertNewHead(
// 		context.Background(),
// 		&metadata.TaikoDataBlockMetadataOntake{
// 			TaikoDataBlockMetadataV2: ontakeBindings.TaikoDataBlockMetadataV2{
// 				Id:              1,
// 				AnchorBlockId:   l1Head.NumberU64(),
// 				AnchorBlockHash: l1Head.Hash(),
// 				Coinbase:        common.BytesToAddress(testutils.RandomBytes(1024)),
// 				BlobHash:        testutils.RandomHash(),
// 				Difficulty:      testutils.RandomHash(),
// 				GasLimit:        utils.RandUint32(nil),
// 				Timestamp:       uint64(time.Now().Unix()),
// 				BaseFeeConfig:   protocolConfigs.BaseFeeConfig,
// 			},
// 			Log: types.Log{
// 				BlockNumber: l1Head.Number().Uint64(),
// 				BlockHash:   l1Head.Hash(),
// 			},
// 		},
// 		parent,
// 		[]byte{},
// 		&rawdb.L1Origin{
// 			BlockID:       common.Big1,
// 			L1BlockHeight: common.Big1,
// 			L1BlockHash:   testutils.RandomHash(),
// 		},
// 	)
// 	s.Nil(err)
// }

func (s *BlobSyncerTestSuite) TestTreasuryIncomeAllAnchors() {
	// TODO: Temporarily skip this test case when using l2_reth node.
	if os.Getenv("L2_NODE") == "l2_reth" {
		s.T().Skip()
	}
	treasury := common.HexToAddress(os.Getenv("TREASURY"))
	s.NotZero(treasury.Big().Uint64())

	balance, err := s.RPCClient.L2.BalanceAt(context.Background(), treasury, nil)
	s.Nil(err)

	headBefore, err := s.RPCClient.L2.BlockNumber(context.Background())
	s.Nil(err)

	s.ProposeAndInsertEmptyBlocks(s.p, s.s)

	headAfter, err := s.RPCClient.L2.BlockNumber(context.Background())
	s.Nil(err)

	balanceAfter, err := s.RPCClient.L2.BalanceAt(context.Background(), treasury, nil)
	s.Nil(err)

	s.Greater(headAfter, headBefore)
	s.Equal(1, balanceAfter.Cmp(balance))
}

func (s *BlobSyncerTestSuite) TestTreasuryIncome() {
	// TODO: Temporarily skip this test case when using l2_reth node.
	if os.Getenv("L2_NODE") == "l2_reth" {
		s.T().Skip()
	}
	treasury := common.HexToAddress(os.Getenv("TREASURY"))
	s.NotZero(treasury.Big().Uint64())

	balance, err := s.RPCClient.L2.BalanceAt(context.Background(), treasury, nil)
	s.Nil(err)

	headBefore, err := s.RPCClient.L2.BlockNumber(context.Background())
	s.Nil(err)

	s.ProposeAndInsertEmptyBlocks(s.p, s.s)
	s.ProposeAndInsertValidBlock(s.p, s.s)

	headAfter, err := s.RPCClient.L2.BlockNumber(context.Background())
	s.Nil(err)

	balanceAfter, err := s.RPCClient.L2.BalanceAt(context.Background(), treasury, nil)
	s.Nil(err)

	s.Greater(headAfter, headBefore)
	s.True(balanceAfter.Cmp(balance) > 0)

	var hasNoneAnchorTxs bool
	chainConfig := config.NewChainConfig(
		s.RPCClient.L2.ChainID,
		s.RPCClient.OntakeClients.ForkHeight,
		s.RPCClient.PacayaClients.ForkHeight,
	)

	cfg, err := s.RPCClient.GetProtocolConfigs(nil)
	s.Nil(err)

	for i := headBefore + 1; i <= headAfter; i++ {
		block, err := s.RPCClient.L2.BlockByNumber(context.Background(), new(big.Int).SetUint64(i))
		s.Nil(err)
		s.GreaterOrEqual(block.Transactions().Len(), 1)
		s.Greater(block.BaseFee().Uint64(), uint64(0))

		for j, tx := range block.Transactions() {
			if j == 0 {
				continue
			}

			hasNoneAnchorTxs = true
			receipt, err := s.RPCClient.L2.TransactionReceipt(context.Background(), tx.Hash())
			s.Nil(err)

			fee := new(big.Int).Mul(block.BaseFee(), new(big.Int).SetUint64(receipt.GasUsed))
			if chainConfig.IsOntake(block.Number()) {
				feeCoinbase := new(big.Int).Div(
					new(big.Int).Mul(fee, new(big.Int).SetUint64(uint64(cfg.BaseFeeConfig().SharingPctg))),
					new(big.Int).SetUint64(100),
				)
				feeTreasury := new(big.Int).Sub(fee, feeCoinbase)
				balance = new(big.Int).Add(balance, feeTreasury)
			} else {
				balance = new(big.Int).Add(balance, fee)
			}
		}
	}

	s.True(hasNoneAnchorTxs)
	s.Zero(balanceAfter.Cmp(balance))
}

func (s *BlobSyncerTestSuite) initProposer() {
	prop := new(proposer.Proposer)
	l1ProposerPrivKey, err := crypto.ToECDSA(common.FromHex(os.Getenv("L1_PROPOSER_PRIVATE_KEY")))
	s.Nil(err)

	jwtSecret, err := jwt.ParseSecretFromFile(os.Getenv("JWT_SECRET"))
	s.Nil(err)
	s.NotEmpty(jwtSecret)

	s.Nil(prop.InitFromConfig(context.Background(), &proposer.Config{
		ClientConfig: &rpc.ClientConfig{
			L1Endpoint:        os.Getenv("L1_WS"),
			L2Endpoint:        os.Getenv("L2_WS"),
			L2EngineEndpoint:  os.Getenv("L2_AUTH"),
			JwtSecret:         string(jwtSecret),
			TaikoL1Address:    common.HexToAddress(os.Getenv("TAIKO_L1")),
			TaikoL2Address:    common.HexToAddress(os.Getenv("TAIKO_L2")),
			TaikoTokenAddress: common.HexToAddress(os.Getenv("TAIKO_TOKEN")),
		},
		L1ProposerPrivKey:          l1ProposerPrivKey,
		L2SuggestedFeeRecipient:    common.HexToAddress(os.Getenv("L2_SUGGESTED_FEE_RECIPIENT")),
		ProposeInterval:            1024 * time.Hour,
		MaxProposedTxListsPerEpoch: 1,
		TxmgrConfigs: &txmgr.CLIConfig{
			L1RPCURL:                  os.Getenv("L1_WS"),
			NumConfirmations:          0,
			SafeAbortNonceTooLowCount: txmgr.DefaultBatcherFlagValues.SafeAbortNonceTooLowCount,
			PrivateKey:                common.Bytes2Hex(crypto.FromECDSA(l1ProposerPrivKey)),
			FeeLimitMultiplier:        txmgr.DefaultBatcherFlagValues.FeeLimitMultiplier,
			FeeLimitThresholdGwei:     txmgr.DefaultBatcherFlagValues.FeeLimitThresholdGwei,
			MinBaseFeeGwei:            txmgr.DefaultBatcherFlagValues.MinBaseFeeGwei,
			MinTipCapGwei:             txmgr.DefaultBatcherFlagValues.MinTipCapGwei,
			ResubmissionTimeout:       txmgr.DefaultBatcherFlagValues.ResubmissionTimeout,
			ReceiptQueryInterval:      1 * time.Second,
			NetworkTimeout:            txmgr.DefaultBatcherFlagValues.NetworkTimeout,
			TxSendTimeout:             txmgr.DefaultBatcherFlagValues.TxSendTimeout,
			TxNotInMempoolTimeout:     txmgr.DefaultBatcherFlagValues.TxNotInMempoolTimeout,
		},
		PrivateTxmgrConfigs: &txmgr.CLIConfig{
			L1RPCURL:                  os.Getenv("L1_WS"),
			NumConfirmations:          0,
			SafeAbortNonceTooLowCount: txmgr.DefaultBatcherFlagValues.SafeAbortNonceTooLowCount,
			PrivateKey:                common.Bytes2Hex(crypto.FromECDSA(l1ProposerPrivKey)),
			FeeLimitMultiplier:        txmgr.DefaultBatcherFlagValues.FeeLimitMultiplier,
			FeeLimitThresholdGwei:     txmgr.DefaultBatcherFlagValues.FeeLimitThresholdGwei,
			MinBaseFeeGwei:            txmgr.DefaultBatcherFlagValues.MinBaseFeeGwei,
			MinTipCapGwei:             txmgr.DefaultBatcherFlagValues.MinTipCapGwei,
			ResubmissionTimeout:       txmgr.DefaultBatcherFlagValues.ResubmissionTimeout,
			ReceiptQueryInterval:      1 * time.Second,
			NetworkTimeout:            txmgr.DefaultBatcherFlagValues.NetworkTimeout,
			TxSendTimeout:             txmgr.DefaultBatcherFlagValues.TxSendTimeout,
			TxNotInMempoolTimeout:     txmgr.DefaultBatcherFlagValues.TxNotInMempoolTimeout,
		},
	}, nil, nil))

	s.p = prop
}

func TestBlobSyncerTestSuite(t *testing.T) {
	suite.Run(t, new(BlobSyncerTestSuite))
}
