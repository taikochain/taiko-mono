package relayer

import (
	"math/big"

	"github.com/ethereum/go-ethereum/common"
)

type BlockHeader struct {
	ParentHash       common.Hash
	OmmersHash       common.Hash
	Beneficiary      common.Address
	StateRoot        common.Hash
	TransactionsRoot common.Hash
	ReceiptsRoot     common.Hash
	Difficulty       *big.Int
	Height           *big.Int
	GasLimit         uint64
	GasUsed          uint64
	Timestamp        uint64
	ExtraData        []byte
	MixHash          common.Hash
	Nonce            uint64
}

type SignalProof struct {
	Header BlockHeader
	Proof  []byte
}
