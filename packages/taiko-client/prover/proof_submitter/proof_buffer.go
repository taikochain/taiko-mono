package submitter

import (
	"errors"
	"sync"
	"time"

	producer "github.com/taikoxyz/taiko-mono/packages/taiko-client/prover/proof_producer"
)

var (
	errBufferOverflow = errors.New("proof buffer overflow")
	errNotEnoughProof = errors.New("not enough proof")
)

// ProofBuffer caches all single proof with a fixed size.
type ProofBuffer struct {
	MaxLength     uint64
	buffer        []*producer.ProofWithHeader
	firstItemTime time.Time
	isAggregating bool
	mutex         sync.RWMutex
}

// NewProofBuffer creates a new ProofBuffer instance.
func NewProofBuffer(maxLength uint64) *ProofBuffer {
	return &ProofBuffer{
		buffer:        make([]*producer.ProofWithHeader, 0, maxLength),
		firstItemTime: time.Now(),
		MaxLength:     maxLength,
	}
}

// Write adds new item to the buffer.
func (pb *ProofBuffer) Write(item *producer.ProofWithHeader) (int, error) {
	pb.mutex.Lock()
	defer pb.mutex.Unlock()

	if len(pb.buffer)+1 > int(pb.MaxLength) {
		return len(pb.buffer), errBufferOverflow
	}
	if len(pb.buffer) == 0 {
		pb.firstItemTime = time.Now()
	}

	pb.buffer = append(pb.buffer, item)
	return len(pb.buffer), nil
}

// Read returns the content with given length in the buffer.
func (pb *ProofBuffer) Read(length int) ([]*producer.ProofWithHeader, error) {
	pb.mutex.RLock()
	defer pb.mutex.RUnlock()
	if length > len(pb.buffer) {
		return nil, errNotEnoughProof
	}

	data := make([]*producer.ProofWithHeader, length)
	copy(data, pb.buffer[:length])
	return data, nil
}

// ReadAll returns all the content in the buffer.
func (pb *ProofBuffer) ReadAll() ([]*producer.ProofWithHeader, error) {
	return pb.Read(pb.Len())
}

// Len returns current length of the buffer.
func (pb *ProofBuffer) Len() int {
	pb.mutex.RLock()
	defer pb.mutex.RUnlock()
	return len(pb.buffer)
}

// FirstItemTime returns the first item updated time of the buffer.
func (pb *ProofBuffer) FirstItemTime() time.Time {
	return pb.firstItemTime
}

// ClearItems clears items that has given block ids in the buffer.
func (pb *ProofBuffer) ClearItems(blockIDs ...uint64) int {
	pb.mutex.Lock()
	defer pb.mutex.Unlock()

	clearMap := make(map[uint64]bool)
	for _, blockID := range blockIDs {
		clearMap[blockID] = true
	}

	newBuffer := make([]*producer.ProofWithHeader, 0, len(pb.buffer))
	clearedCount := 0

	for _, b := range pb.buffer {
		if !clearMap[b.Meta.GetBlockID().Uint64()] {
			newBuffer = append(newBuffer, b)
		} else {
			clearedCount++
		}
	}

	pb.buffer = newBuffer
	pb.isAggregating = false
	return clearedCount
}

// MarkAggregating marks the proofs in this buffer are aggregating.
func (pb *ProofBuffer) MarkAggregating() {
	pb.isAggregating = true
}

// IsAggregating returns if the proofs in this buffer are aggregating.
func (pb *ProofBuffer) IsAggregating() bool {
	return pb.isAggregating
}

// Enabled returns if the buffer is enabled.
func (pb *ProofBuffer) Enabled() bool {
	return pb.MaxLength > 1
}
