package transaction

import (
	"errors"
	"fmt"
	"math/big"

	"github.com/ethereum-optimism/optimism/op-service/txmgr"
	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/log"

	"github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/encoding"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/metadata"
	ontakeBindings "github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/ontake"
	pacayaBindings "github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/pacaya"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/pkg/rpc"
	proofProducer "github.com/taikoxyz/taiko-mono/packages/taiko-client/prover/proof_producer"
)

var (
	ErrUnretryableSubmission = errors.New("unretryable submission error")
	ZeroAddress              common.Address
)

// TxBuilder will build a transaction with the given nonce.
type TxBuilder func(txOpts *bind.TransactOpts) (*txmgr.TxCandidate, error)

// ProveBlockTxBuilder is responsible for building ProveBlock transactions.
type ProveBlockTxBuilder struct {
	rpc                           *rpc.Client
	taikoL1Address                common.Address
	proverSetAddress              common.Address
	guardianProverMajorityAddress common.Address
	guardianProverMinorityAddress common.Address
}

// NewProveBlockTxBuilder creates a new ProveBlockTxBuilder instance.
func NewProveBlockTxBuilder(
	rpc *rpc.Client,
	taikoL1Address common.Address,
	proverSetAddress common.Address,
	guardianProverMajorityAddress common.Address,
	guardianProverMinorityAddress common.Address,
) *ProveBlockTxBuilder {
	return &ProveBlockTxBuilder{
		rpc,
		taikoL1Address,
		proverSetAddress,
		guardianProverMajorityAddress,
		guardianProverMinorityAddress,
	}
}

// Build creates a new TaikoL1.ProveBlock transaction with the given nonce.
func (a *ProveBlockTxBuilder) Build(
	blockID *big.Int,
	meta metadata.TaikoProposalMetaData,
	transition *ontakeBindings.TaikoDataTransition,
	tierProof *ontakeBindings.TaikoDataTierProof,
	tier uint16,
) TxBuilder {
	return func(txOpts *bind.TransactOpts) (*txmgr.TxCandidate, error) {
		var (
			data     []byte
			to       common.Address
			err      error
			guardian = tier >= encoding.TierGuardianMinorityID
		)

		log.Info(
			"Build proof submission transaction",
			"blockID", blockID,
			"gasLimit", txOpts.GasLimit,
			"guardian", guardian,
		)

		if !guardian {
			input, err := encoding.EncodeProveBlockInput(meta, transition, tierProof)
			if err != nil {
				return nil, err
			}

			if a.proverSetAddress != ZeroAddress {
				if data, err = encoding.ProverSetABI.Pack(
					"proveBlocks",
					[]uint64{blockID.Uint64()},
					[][]byte{input},
					[]byte{},
				); err != nil {
					return nil, err
				}
				to = a.proverSetAddress
			} else {
				if data, err = encoding.TaikoL1ABI.Pack(
					"proveBlocks",
					[]uint64{blockID.Uint64()},
					[][]byte{input},
					[]byte{},
				); err != nil {
					return nil, err
				}
				to = a.taikoL1Address
			}
		} else {
			if tier > encoding.TierGuardianMinorityID {
				to = a.guardianProverMajorityAddress
			} else if tier == encoding.TierGuardianMinorityID && a.guardianProverMinorityAddress != ZeroAddress {
				to = a.guardianProverMinorityAddress
			} else {
				return nil, fmt.Errorf("tier %d need set guardianProverMinorityAddress", tier)
			}

			if data, err = encoding.GuardianProverABI.Pack(
				"approveV2",
				meta.(*metadata.TaikoDataBlockMetadataOntake).InnerMetadata(),
				*transition,
				*tierProof,
			); err != nil {
				return nil, err
			}
		}

		return &txmgr.TxCandidate{
			TxData:   data,
			To:       &to,
			Blobs:    nil,
			GasLimit: txOpts.GasLimit,
			Value:    txOpts.Value,
		}, nil
	}
}

// BuildProveBlocks creates a new TaikoL1.ProveBlocks transaction.
func (a *ProveBlockTxBuilder) BuildProveBlocks(
	batchProof *proofProducer.BatchProofs,
	graffiti [32]byte,
) TxBuilder {
	return func(txOpts *bind.TransactOpts) (*txmgr.TxCandidate, error) {
		var (
			data        []byte
			to          common.Address
			err         error
			metas       = make([]metadata.TaikoProposalMetaData, len(batchProof.ProofResponses))
			transitions = make([]ontakeBindings.TaikoDataTransition, len(batchProof.ProofResponses))
			blockIDs    = make([]uint64, len(batchProof.ProofResponses))
		)
		for i, proof := range batchProof.ProofResponses {
			metas[i] = proof.Meta
			transitions[i] = ontakeBindings.TaikoDataTransition{
				ParentHash: proof.Opts.OntakeOptions().ParentHash,
				BlockHash:  proof.Opts.OntakeOptions().BlockHash,
				StateRoot:  proof.Opts.OntakeOptions().StateRoot,
				Graffiti:   graffiti,
			}
			blockIDs[i] = proof.BlockID.Uint64()
		}
		log.Info(
			"Build batch proof submission transaction",
			"blockIDs", blockIDs,
			"gasLimit", txOpts.GasLimit,
		)
		input, err := encoding.EncodeProveBlocksInput(metas, transitions)
		if err != nil {
			return nil, err
		}
		tierProof, err := encoding.EncodeProveBlocksBatchProof(&ontakeBindings.TaikoDataTierProof{
			Tier: batchProof.Tier,
			Data: batchProof.BatchProof,
		})
		if err != nil {
			return nil, err
		}

		if a.proverSetAddress != ZeroAddress {
			if data, err = encoding.ProverSetABI.Pack(
				"proveBlocks",
				blockIDs,
				input,
				tierProof,
			); err != nil {
				return nil, err
			}
			to = a.proverSetAddress
		} else {
			if data, err = encoding.TaikoL1ABI.Pack(
				"proveBlocks",
				blockIDs,
				input,
				tierProof,
			); err != nil {
				return nil, err
			}
			to = a.taikoL1Address
		}

		return &txmgr.TxCandidate{
			TxData:   data,
			To:       &to,
			Blobs:    nil,
			GasLimit: txOpts.GasLimit,
			Value:    txOpts.Value,
		}, nil
	}
}

// BuildProveBatchesPacaya creates a new TaikoInbox.ProveBatches transaction.
func (a *ProveBlockTxBuilder) BuildProveBatchesPacaya(batchProof *proofProducer.BatchProofs) TxBuilder {
	return func(txOpts *bind.TransactOpts) (*txmgr.TxCandidate, error) {
		var (
			data        []byte
			to          common.Address
			err         error
			metas       = make([]metadata.TaikoProposalMetaData, len(batchProof.ProofResponses))
			transitions = make([]pacayaBindings.ITaikoInboxTransition, len(batchProof.ProofResponses))
			subProofs   = make([]encoding.SubProof, len(batchProof.ProofResponses))
			batchIDs    = make([]uint64, len(batchProof.ProofResponses))
		)
		// NOTE: op_verifier is the only verifier address for now.
		opVerifier, err := a.rpc.ResolvePacaya(&bind.CallOpts{Context: txOpts.Context}, "op_verifier")
		if err != nil {
			return nil, err
		}
		for i, proof := range batchProof.ProofResponses {
			metas[i] = proof.Meta
			transitions[i] = pacayaBindings.ITaikoInboxTransition{
				ParentHash: proof.Opts.PacayaOptions().Headers[i].ParentHash,
				BlockHash:  proof.Opts.PacayaOptions().Headers[i].Hash(),
				StateRoot:  proof.Opts.PacayaOptions().Headers[i].Root,
			}
			batchIDs[i] = proof.Meta.TaikoBatchMetaDataPacaya().GetBatchID().Uint64()
			subProofs[i] = encoding.SubProof{
				Verifier: opVerifier,
				Proof:    batchProof.BatchProof,
			}
		}
		log.Info(
			"Build batch proof submission transaction",
			"batchIDs", batchIDs,
			"gasLimit", txOpts.GasLimit,
		)
		input, err := encoding.EncodeProveBatchesInput(metas, transitions)
		if err != nil {
			return nil, err
		}
		encodedSubProofs, err := encoding.EncodeBatchesSubProofs(subProofs)
		if err != nil {
			return nil, err
		}

		if a.proverSetAddress != ZeroAddress {
			if data, err = encoding.ProverSetABI.Pack("proveBatches", input, encodedSubProofs); err != nil {
				return nil, encoding.TryParsingCustomError(err)
			}
			to = a.proverSetAddress
		} else {
			if data, err = encoding.TaikoInboxABI.Pack("proveBatches", input, encodedSubProofs); err != nil {
				return nil, encoding.TryParsingCustomError(err)
			}
			to = a.taikoL1Address
		}

		return &txmgr.TxCandidate{
			TxData:   data,
			To:       &to,
			Blobs:    nil,
			GasLimit: txOpts.GasLimit,
			Value:    txOpts.Value,
		}, nil
	}
}
