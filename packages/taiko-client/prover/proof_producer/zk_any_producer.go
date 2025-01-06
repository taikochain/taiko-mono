package producer

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"math/big"
	"net/http"
	"time"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/core/types"
	"github.com/ethereum/go-ethereum/log"

	"github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/encoding"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/metadata"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/internal/metrics"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/pkg/rpc"
)

var (
	ErrNotSupported = errors.New("currently not supported")
)

// ZKAnyProofProducer generates a ZK proof for the given block.
type ZKAnyProofProducer struct {
	RaikoHostEndpoint   string
	RaikoRequestTimeout time.Duration
	Risc0Verifier       common.Address
	SP1Verifier         common.Address
	JWT                 string // JWT provided by Raiko
	Dummy               bool
	DummyProofProducer
}

// RequestProof implements the ProofProducer interface.
func (s *ZKAnyProofProducer) RequestProof(
	ctx context.Context,
	opts *ProofRequestOptions,
	blockID *big.Int,
	meta metadata.TaikoBlockMetaData,
	header *types.Header,
	requestAt time.Time,
) (*ProofWithHeader, error) {
	log.Info(
		"Request zk proof from raiko-host service",
		"blockID", blockID,
		"coinbase", meta.GetCoinbase(),
		"hash", header.Hash(),
		"time", time.Since(requestAt),
	)

	if s.Dummy {
		return s.DummyProofProducer.RequestProof(opts, blockID, meta, header, s.Tier(), requestAt)
	}

	proof, err := s.callProverDaemon(ctx, opts, requestAt)
	if err != nil {
		return nil, err
	}

	// TODO: count according to response
	if s.ZKProofType == ZKProofTypeR0 {
		metrics.ProverR0ProofGeneratedCounter.Add(1)
	} else if s.ZKProofType == ZKProofTypeSP1 {
		metrics.ProverSp1ProofGeneratedCounter.Add(1)
	}

	return &ProofWithHeader{
		BlockID: blockID,
		Header:  header,
		Meta:    meta,
		Proof:   proof,
		Opts:    opts,
		Tier:    s.Tier(),
	}, nil
}

// RequestCancel implements the ProofProducer interface to cancel the proof generating progress.
func (s *ZKAnyProofProducer) RequestCancel(
	ctx context.Context,
	opts *ProofRequestOptions,
) error {
	return s.requestCancel(ctx, opts)
}

// Aggregate implements the ProofProducer interface to aggregate a batch of proofs.
func (s *ZKAnyProofProducer) Aggregate(
	_ context.Context,
	_ []*ProofWithHeader,
	_ time.Time,
) (*BatchProofs, error) {
	return nil, ErrNotSupported
}

// callProverDaemon keeps polling the proverd service to get the requested proof.
func (s *ZKAnyProofProducer) callProverDaemon(
	ctx context.Context,
	opts *ProofRequestOptions,
	requestAt time.Time,
) ([]byte, error) {
	var (
		proof []byte
	)

	zkCtx, zkCancel := rpc.CtxWithTimeoutOrDefault(ctx, s.RaikoRequestTimeout)
	defer zkCancel()

	output, err := s.requestProof(zkCtx, opts)
	if err != nil {
		log.Error("Failed to request proof", "blockID", opts.BlockID, "error", err, "endpoint", s.RaikoHostEndpoint)
		return nil, err
	}

	if output.Data.Status == ErrProofInProgress.Error() {
		return nil, ErrProofInProgress
	}
	if output.Data.Status == StatusRegistered {
		return nil, ErrRetry
	}

	if !opts.Compressed {
		if len(output.Data.Proof.Proof) == 0 {
			return nil, errEmptyProof
		}
		proof = common.Hex2Bytes(output.Data.Proof.Proof[2:])
	}
	log.Info(
		"Proof generated",
		"blockID", opts.BlockID,
		"time", time.Since(requestAt),
		"producer", "ZKAnyProofProducer",
	)

	// TODO: record generation time according to response
	if s.ZKProofType == ZKProofTypeR0 {
		metrics.ProverR0ProofGenerationTime.Set(float64(time.Since(requestAt).Seconds()))
	} else if s.ZKProofType == ZKProofTypeSP1 {
		metrics.ProverSP1ProofGenerationTime.Set(float64(time.Since(requestAt).Seconds()))
	}

	return proof, nil
}

// requestProof sends a RPC request to proverd to try to get the requested proof.
func (s *ZKAnyProofProducer) requestProof(
	ctx context.Context,
	opts *ProofRequestOptions,
) (*RaikoRequestProofBodyResponseV2, error) {
	var (
		reqBody   RaikoRequestProofBody
		recursion string
	)
	if opts.Compressed {
		recursion = RecursionCompressed
	} else {
		recursion = RecursionPlonk
	}
	switch s.ZKProofType {
	case ZKProofTypeSP1:
		reqBody = RaikoRequestProofBody{
			Type:     s.ZKProofType,
			Block:    opts.BlockID,
			Prover:   opts.ProverAddress.Hex()[2:],
			Graffiti: opts.Graffiti,
			SP1: &SP1RequestProofBodyParam{
				Recursion: recursion,
				Prover:    "network",
				Verify:    true,
			},
		}
	default:
		reqBody = RaikoRequestProofBody{
			Type:     s.ZKProofType,
			Block:    opts.BlockID,
			Prover:   opts.ProverAddress.Hex()[2:],
			Graffiti: opts.Graffiti,
			RISC0: &RISC0RequestProofBodyParam{
				Bonsai:       true,
				Snark:        true,
				Profile:      false,
				ExecutionPo2: big.NewInt(20),
			},
		}
	}

	client := &http.Client{}

	jsonValue, err := json.Marshal(reqBody)
	if err != nil {
		return nil, err
	}

	req, err := http.NewRequestWithContext(ctx, "POST", s.RaikoHostEndpoint+"/v2/proof", bytes.NewBuffer(jsonValue))
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")
	if len(s.JWT) > 0 {
		req.Header.Set("Authorization", "Bearer "+base64.StdEncoding.EncodeToString([]byte(s.JWT)))
	}

	log.Debug(
		"Send zk any proof generation request",
		"blockID", opts.BlockID,
		"input", string(jsonValue),
	)

	res, err := client.Do(req)
	if err != nil {
		return nil, err
	}

	defer res.Body.Close()
	if res.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("failed to request proof, id: %d, statusCode: %d", opts.BlockID, res.StatusCode)
	}

	resBytes, err := io.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}

	log.Debug(
		"Proof zk any generation output",
		"blockID", opts.BlockID,
		"output", string(resBytes),
	)
	var output RaikoRequestProofBodyResponseV2
	if err := json.Unmarshal(resBytes, &output); err != nil {
		return nil, err
	}

	if len(output.ErrorMessage) > 0 || len(output.Error) > 0 {
		return nil, fmt.Errorf("failed to get zk any proof, err: %s, msg: %s, zkType: %s",
			output.Error,
			output.ErrorMessage,
		)
	}

	return &output, nil
}

func (s *ZKAnyProofProducer) requestCancel(
	ctx context.Context,
	opts *ProofRequestOptions,
) error {
	var (
		reqBody   RaikoRequestProofBody
		recursion string
	)
	if opts.Compressed {
		recursion = RecursionCompressed
	} else {
		recursion = RecursionPlonk
	}
	switch s.ZKProofType {
	case ZKProofTypeSP1:
		reqBody = RaikoRequestProofBody{
			Type:     s.ZKProofType,
			Block:    opts.BlockID,
			Prover:   opts.ProverAddress.Hex()[2:],
			Graffiti: opts.Graffiti,
			SP1: &SP1RequestProofBodyParam{
				Recursion: recursion,
				Prover:    "network",
				Verify:    true,
			},
		}
	default:
		reqBody = RaikoRequestProofBody{
			Type:     s.ZKProofType,
			Block:    opts.BlockID,
			Prover:   opts.ProverAddress.Hex()[2:],
			Graffiti: opts.Graffiti,
			RISC0: &RISC0RequestProofBodyParam{
				Bonsai:       true,
				Snark:        true,
				Profile:      false,
				ExecutionPo2: big.NewInt(20),
			},
		}
	}

	client := &http.Client{}

	jsonValue, err := json.Marshal(reqBody)
	if err != nil {
		return err
	}

	req, err := http.NewRequestWithContext(
		ctx,
		"POST",
		s.RaikoHostEndpoint+"/v2/proof/cancel",
		bytes.NewBuffer(jsonValue),
	)
	if err != nil {
		return err
	}
	req.Header.Set("Content-Type", "application/json")
	if len(s.JWT) > 0 {
		req.Header.Set("Authorization", "Bearer "+base64.StdEncoding.EncodeToString([]byte(s.JWT)))
	}

	res, err := client.Do(req)
	if err != nil {
		return err
	}

	defer res.Body.Close()
	if res.StatusCode != http.StatusOK {
		return fmt.Errorf("failed to cancel requesting proof, statusCode: %d", res.StatusCode)
	}

	return nil
}

// Tier implements the ProofProducer interface.
func (s *ZKAnyProofProducer) Tier() uint16 {
	return encoding.TierZkAnyID
}
