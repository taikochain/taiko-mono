package handler

import (
	"github.com/ethereum/go-ethereum/core/types"

	ontakeBindings "github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/ontake"
	"github.com/taikoxyz/taiko-mono/packages/taiko-client/internal/testutils"
)

func (s *EventHandlerTestSuite) TestBlockVerifiedHandle() {
	handler := &BlockVerifiedEventHandler{}
	id := testutils.RandomHash().Big().Uint64()
	s.NotPanics(func() {
		handler.Handle(&ontakeBindings.TaikoL1ClientBlockVerifiedV2{
			BlockId: testutils.RandomHash().Big(),
			Raw: types.Log{
				BlockHash:   testutils.RandomHash(),
				BlockNumber: id,
			},
		})
	})
}
