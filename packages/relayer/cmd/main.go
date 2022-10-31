package main

import (
	"context"
	"fmt"
	"os"

	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/rpc"

	"github.com/ethereum/go-ethereum/ethclient"
	"github.com/joho/godotenv"
	"github.com/pkg/errors"
	log "github.com/sirupsen/logrus"
	"github.com/taikochain/taiko-mono/packages/relayer"
	"github.com/taikochain/taiko-mono/packages/relayer/indexer"
	"github.com/taikochain/taiko-mono/packages/relayer/repo"
	"gorm.io/driver/mysql"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

func main() {
	if err := loadAndValidateEnv(); err != nil {
		log.Fatal(err)
	}

	log.SetFormatter(&log.JSONFormatter{})

	db := openDBConnection(relayer.DBConnectionOpts{
		Name:     os.Getenv("MYSQL_USER"),
		Password: os.Getenv("MYSQL_PASSWORD"),
		Database: os.Getenv("MYSQL_DATABASE"),
		Host:     os.Getenv("MYSQL_HOST"),
	})

	sqlDB, err := db.DB()
	if err != nil {
		log.Fatal(err)
	}
	defer sqlDB.Close()

	eventRepository, err := repo.NewEventRepository(db)
	if err != nil {
		log.Fatal(err)
	}

	blockRepository, err := repo.NewBlockRepository(db)
	if err != nil {
		log.Fatal(err)
	}

	l1EthClient, err := ethclient.Dial(os.Getenv("L1_RPC_URL"))
	if err != nil {
		log.Fatal(err)
	}
	defer l1EthClient.Close()

	l2EthClient, err := ethclient.Dial(os.Getenv("L2_RPC_URL"))
	if err != nil {
		log.Fatal(err)
	}
	defer l2EthClient.Close()

	l1RpcClient, err := rpc.DialContext(context.Background(), os.Getenv("L1_RPC_URL"))
	if err != nil {
		log.Fatal(err)
	}

	l2RpcClient, err := rpc.DialContext(context.Background(), os.Getenv("L2_RPC_URL"))
	if err != nil {
		log.Fatal(err)
	}

	i, err := indexer.NewService(indexer.NewServiceOpts{
		EventRepo:           eventRepository,
		BlockRepo:           blockRepository,
		CrossLayerEthClient: l2EthClient,
		EthClient:           l1EthClient,
		RPCClient:           l1RpcClient,
		CrossLayerRPCClient: l2RpcClient,

		ECDSAKey:                os.Getenv("RELAYER_ECDSA_KEY"),
		BridgeAddress:           common.HexToAddress(os.Getenv("L1_BRIDGE_ADDRESS")),
		CrossLayerBridgeAddress: common.HexToAddress(os.Getenv("L2_BRIDGE_ADDRESS")),
	})
	if err != nil {
		log.Fatal(err)
	}

	forever := make(chan struct{})

	go func() {
		if err := i.FilterThenSubscribe(context.Background()); err != nil {
			log.Fatal(err)
		}
	}()

	<-forever
}

func openDBConnection(opts relayer.DBConnectionOpts) *gorm.DB {
	dsn := fmt.Sprintf(
		"%v:%v@tcp(%v)/%v?charset=utf8mb4&parseTime=True&loc=Local",
		opts.Name,
		opts.Password,
		opts.Host,
		opts.Database,
	)

	db, err := gorm.Open(mysql.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Silent),
	})
	if err != nil {
		log.Fatal(err)
	}

	return db
}

func loadAndValidateEnv() error {
	_ = godotenv.Load()

	missing := make([]string, 0)
	envVars := []string{
		"HTTP_PORT",
		"L1_BRIDGE_ADDRESS",
		"L2_BRIDGE_ADDRESS",
		"L1_RPC_URL",
		"L2_RPC_URL",
		"MYSQL_USER",
		"MYSQL_DATABASE",
		"MYSQL_PASSWORD",
		"MYSQL_HOST",
		"RELAYER_ECDSA_KEY",
	}

	for _, v := range envVars {
		e := os.Getenv(v)
		if e == "" {
			missing = append(missing, v)
		}
	}

	if len(missing) == 0 {
		return nil
	}

	return errors.Errorf("Missing env vars: %v", missing)
}
