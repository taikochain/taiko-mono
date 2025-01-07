package softblocks

import (
	"context"
	"testing"

	"github.com/ethereum/go-ethereum/log"
	"github.com/stretchr/testify/suite"

	"github.com/taikoxyz/taiko-mono/packages/taiko-client/internal/testutils"
)

type SoftBlockAPIServerTestSuite struct {
	testutils.ClientTestSuite
	s *SoftBlockAPIServer
}

func (s *SoftBlockAPIServerTestSuite) SetupTest() {
	s.ClientTestSuite.SetupTest()
	server, err := New("*", nil, nil, s.RPCClient, true)
	s.Nil(err)
	s.s = server
	go func() {
		s.NotPanics(func() {
			log.Error("Start test soft block server", "error", s.s.Start(uint64(testutils.RandomPort())))
		})
	}()
}

func (s *SoftBlockAPIServerTestSuite) TestShutdown() {
	s.Nil(s.s.Shutdown(context.Background()))
}

func TestSoftBlockAPIServerTestSuite(t *testing.T) {
	suite.Run(t, new(SoftBlockAPIServerTestSuite))
}
