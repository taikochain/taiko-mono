package preconfapi

import (
	"time"

	"github.com/ethereum/go-ethereum/common"
	"github.com/urfave/cli/v2"

	"github.com/taikoxyz/taiko-mono/packages/taiko-client/cmd/flags"
)

type Config struct {
	TaikoL1Address         common.Address
	BlobAllowed            bool
	HTTPPort               uint64
	ProposeBlockTxGasLimit uint64
	PollingInterval        time.Duration
	L2HTTPEndpoint         string
	DBPath                 string
	CORSOrigins            []string
}

// NewConfigFromCliContext initializes a Config instance from
// command line flags.
func NewConfigFromCliContext(c *cli.Context) (*Config, error) {
	return &Config{
		TaikoL1Address:         common.HexToAddress(c.String(flags.TaikoL1Address.Name)),
		BlobAllowed:            c.Bool(flags.BlobAllowed.Name),
		HTTPPort:               c.Uint64(flags.PreconfAPIHTTPServerPort.Name),
		ProposeBlockTxGasLimit: c.Uint64(flags.TxGasLimit.Name),
		PollingInterval:        c.Duration(flags.PollingInterval.Name),
		L2HTTPEndpoint:         c.String(flags.L2HTTPEndpoint.Name),
		DBPath:                 c.String(flags.DBPath.Name),
		CORSOrigins:            c.StringSlice(flags.CORSOrigins.Name),
	}, nil
}
