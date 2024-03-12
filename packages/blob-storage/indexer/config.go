package indexer

import (
	"database/sql"

	"github.com/ethereum/go-ethereum/common"
	"github.com/taikoxyz/taiko-mono/packages/blob-storage/cmd/flags"
	"github.com/taikoxyz/taiko-mono/packages/blob-storage/pkg/db/db"
	"github.com/urfave/cli/v2"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

// DB is a local interface that lets us narrow down a database type for testing.
type DB interface {
	DB() (*sql.DB, error)
	GormDB() *gorm.DB
}

type Config struct {
	StartingBlockID         *uint64
	RPCURL                  string
	BeaconURL               string
	ContractAddress         common.Address
	DatabaseUsername        string
	DatabasePassword        string
	DatabaseName            string
	DatabaseHost            string
	DatabaseMaxIdleConns    uint64
	DatabaseMaxOpenConns    uint64
	DatabaseMaxConnLifetime uint64
	OpenDBFunc              func() (DB, error)
}

// NewConfigFromCliContext creates a new config instance from command line flags.
func NewConfigFromCliContext(c *cli.Context) (*Config, error) {
	var startBlockId *uint64

	if c.IsSet(flags.StartingBlockID.Name) {
		b := c.Uint64(flags.StartingBlockID.DefaultText)
		startBlockId = &b
	}

	return &Config{
		DatabaseHost:            c.String(flags.DBHost.Name),
		DatabaseUsername:        c.String(flags.DBUsername.Name),
		DatabasePassword:        c.String(flags.DBPassword.Name),
		DatabaseName:            c.String(flags.DBDatabase.Name),
		DatabaseMaxIdleConns:    c.Uint64(flags.DatabaseMaxIdleConns.Name),
		DatabaseMaxOpenConns:    c.Uint64(flags.DatabaseMaxOpenConns.Name),
		DatabaseMaxConnLifetime: c.Uint64(flags.DatabaseConnMaxLifetime.Name),
		StartingBlockID:         startBlockId,
		RPCURL:                  c.String(flags.RPCUrl.Name),
		BeaconURL:               c.String(flags.BeaconURL.Name),
		ContractAddress:         common.HexToAddress(c.String(flags.ContractAddress.Name)),
		OpenDBFunc: func() (DB, error) {
			return db.OpenDBConnection(db.DBConnectionOpts{
				Name:            c.String(flags.DatabaseUsername.Name),
				Password:        c.String(flags.DatabasePassword.Name),
				Database:        c.String(flags.DatabaseName.Name),
				Host:            c.String(flags.DatabaseHost.Name),
				MaxIdleConns:    c.Uint64(flags.DatabaseMaxIdleConns.Name),
				MaxOpenConns:    c.Uint64(flags.DatabaseMaxOpenConns.Name),
				MaxConnLifetime: c.Uint64(flags.DatabaseConnMaxLifetime.Name),
				OpenFunc: func(dsn string) (*db.DB, error) {
					gormDB, err := gorm.Open(mysql.Open(dsn), &gorm.Config{
						Logger: logger.Default.LogMode(logger.Silent),
					})
					if err != nil {
						return nil, err
					}

					return db.New(gormDB), nil
				},
			})
		},
	}, nil
}
