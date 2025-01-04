package rpc

import (
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/taikoxyz/taiko-mono/packages/taiko-client/internal/testutils"
)

func TestSetHead(t *testing.T) {
	require.Nil(t, testutils.ResetNode(newTestClient(t)))
}

func TestStringToBytes32(t *testing.T) {
	require.Equal(t, [32]byte{}, StringToBytes32(""))
	require.Equal(t, [32]byte{0x61, 0x62, 0x63}, StringToBytes32("abc"))
}
