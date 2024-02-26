package proof

import (
	"context"
	"fmt"
	"math/big"

	"log/slog"

	"github.com/taikoxyz/taiko-mono/packages/relayer"
	"github.com/taikoxyz/taiko-mono/packages/relayer/pkg/encoding"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/common/hexutil"
	"github.com/pkg/errors"
)

type HopParams struct {
	ChainID              *big.Int
	SignalServiceAddress common.Address
	SignalService        relayer.SignalService
	Key                  [32]byte
	Blocker              blocker
	Caller               relayer.Caller
	BlockNumber          uint64
}

func (p *Prover) EncodedSignalProofWithHops(
	ctx context.Context,
	hopParams []HopParams,
) ([]byte, error) {
	return p.abiEncodeSignalProofWithHops(ctx,
		hopParams,
	)
}

func (p *Prover) abiEncodeSignalProofWithHops(ctx context.Context,
	hopParams []HopParams,
) ([]byte, error) {
	hopProofs := []encoding.HopProof{}

	for _, hop := range hopParams {
		slog.Info("generating hop proof")

		block, err := hop.Blocker.BlockByNumber(
			ctx,
			new(big.Int).SetUint64(hop.BlockNumber),
		)
		if err != nil {
			return nil, errors.Wrap(err, "p.blockHeader")
		}

		ethProof, err := p.getProof(
			ctx,
			hop.Caller,
			hop.SignalServiceAddress,
			common.Bytes2Hex(hop.Key[:]),
			int64(hop.BlockNumber),
		)
		if err != nil {
			return nil, errors.Wrap(err, "hop p.getEncodedMerkleProof")
		}

		slog.Info("generated hop proof",
			"chainID", hop.ChainID.Uint64(),
			"blockID", block.NumberU64(),
			"rootHash", block.Root(),
		)

		hopProofs = append(hopProofs, encoding.HopProof{
			BlockID:      block.NumberU64(),
			ChainID:      hop.ChainID.Uint64(),
			RootHash:     block.Root(),
			CacheOption:  uint8(0),
			AccountProof: ethProof.AccountProof,
			StorageProof: ethProof.StorageProof[0].Proof,
		},
		)
	}

	encodedSignalProof, err := encoding.EncodeHopProofs(hopProofs)
	if err != nil {
		return nil, errors.Wrap(err, "enoding.EncodeHopProofs")
	}

	slog.Info("proof", "proof", common.Bytes2Hex(encodedSignalProof))

	return encodedSignalProof, nil
}

// getProof rlp and abi encodes a proof for SignalService,
// where `proof` is an rlp and abi encoded (bytes, bytes) consisting of storageProof.Proofs[0]
// response from `eth_getProof`, and returns the storageHash to be used as the signalRoot.
func (p *Prover) getProof(
	ctx context.Context,
	c relayer.Caller,
	signalServiceAddress common.Address,
	key string,
	blockNumber int64,
) (*StorageProof, error) {
	var ethProof StorageProof

	slog.Info("getting proof",
		"signalServiceAddress", signalServiceAddress.Hex(),
		"key", key,
		"blockNum", blockNumber,
	)

	err := c.CallContext(ctx,
		&ethProof,
		"eth_getProof",
		signalServiceAddress,
		[]string{key},
		hexutil.EncodeBig(new(big.Int).SetInt64(blockNumber)),
	)
	if err != nil {
		return nil, errors.Wrap(err, "c.CallContext")
	}

	slog.Info("proof generated",
		"value", common.Bytes2Hex(ethProof.StorageProof[0].Value),
	)

	slog.Info("key", "key", key)

	slog.Info("storageRoot", "root", ethProof.StorageHash.Hex())

	for i, pr := range ethProof.AccountProof {
		slog.Info("accountProof", fmt.Sprintf("%v", i), common.Bytes2Hex(pr))
	}

	for i, pr := range ethProof.StorageProof[0].Proof {
		slog.Info("storageProof", fmt.Sprintf("%v", i), common.Bytes2Hex(pr))
	}

	if new(big.Int).SetBytes(ethProof.StorageProof[0].Value).Int64() == int64(0) {
		return nil, errors.New("proof will not be valid, expected storageProof to not be 0 but was not")
	}

	return &ethProof, nil
}
