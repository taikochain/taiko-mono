package cli

// var (
// 	defaultBlockBatchSize                    = 2
// 	defaultNumGoroutines                     = 10
// 	defaultSubscriptionBackoff               = 600 * time.Second
// 	defaultConfirmations                     = 15
// 	defaultHeaderSyncIntervalSeconds     int = 60
// 	defaultConfirmationsTimeoutInSeconds     = 900
// )

// func Run(
// 	mode relayer.Mode,
// 	watchMode relayer.WatchMode,
// 	layer relayer.Layer,
// 	httpOnly relayer.HTTPOnly,
// 	profitableOnly relayer.ProfitableOnly,
// 	index relayer.Indexer,
// 	process relayer.Processor,
// ) {
// 	db, err := openDBConnection(relayer.DBConnectionOpts{
// 		Name:     os.Getenv("MYSQL_USER"),
// 		Password: os.Getenv("MYSQL_PASSWORD"),
// 		Database: os.Getenv("MYSQL_DATABASE"),
// 		Host:     os.Getenv("MYSQL_HOST"),
// 		OpenFunc: func(dsn string) (relayer.DB, error) {
// 			gormDB, err := gorm.Open(mysql.Open(dsn), &gorm.Config{
// 				Logger: logger.Default.LogMode(logger.Silent),
// 			})
// 			if err != nil {
// 				return nil, err
// 			}

// 			return db.New(gormDB), nil
// 		},
// 	})

// 	if err != nil {
// 		log.Fatal(err)
// 	}

// 	sqlDB, err := db.DB()
// 	if err != nil {
// 		log.Fatal(err)
// 	}

// 	l1EthClient, err := ethclient.Dial(os.Getenv("L1_RPC_URL"))
// 	if err != nil {
// 		log.Fatal(err)
// 	}

// 	l2EthClient, err := ethclient.Dial(os.Getenv("L2_RPC_URL"))
// 	if err != nil {
// 		log.Fatal(err)
// 	}

// 	srv, err := newHTTPServer(db, l1EthClient, l2EthClient)
// 	if err != nil {
// 		log.Fatal(err)
// 	}

// 	forever := make(chan struct{})

// 	go func() {
// 		if err := srv.Start(fmt.Sprintf(":%v", os.Getenv("HTTP_PORT"))); err != nil {
// 			log.Fatal(err)
// 		}
// 	}()

// 	if bool(index) && !bool(httpOnly) {
// 		indexers, closeFunc, err := makeIndexers(layer, db, profitableOnly)
// 		if err != nil {
// 			log.Fatal(err)
// 		}

// 		defer sqlDB.Close()
// 		defer closeFunc()

// 		for _, i := range indexers {
// 			go func(i *indexer.Indexer) {
// 				if err := i.Start(context.Background(), mode, watchMode); err != nil {
// 					log.Fatal(err)
// 				}
// 			}(i)
// 		}
// 	} else if bool(process) && !bool(httpOnly) {
// 		processors, closeFunc := makeProcessors(layer, db, profitableOnly)

// 		defer sqlDB.Close()
// 		defer closeFunc()

// 		for _, p := range processors {
// 			go func(p *processor.Processor) {
// 				if err := p.Start(context.Background()); err != nil {
// 					log.Fatal(err)
// 				}
// 			}(p)
// 		}
// 	}

// 	<-forever
// }

// func openQueue() (queue.Queue, error) {
// 	opts := queue.NewQueueOpts{
// 		Username: os.Getenv("QUEUE_USERNAME"),
// 		Password: os.Getenv("QUEUE_PASSWORD"),
// 		Host:     os.Getenv("QUEUE_HOST"),
// 		Port:     os.Getenv("QUEUE_PORT"),
// 	}

// 	q, err := rabbitmq.NewQueue(opts)
// 	if err != nil {
// 		log.Fatal(err)
// 	}

// 	return q, nil
// }

// func openDBConnection(opts relayer.DBConnectionOpts) (relayer.DB, error) {
// 	dsn := ""
// 	if opts.Password == "" {
// 		dsn = fmt.Sprintf(
// 			"%v@tcp(%v)/%v?charset=utf8mb4&parseTime=True&loc=Local",
// 			opts.Name,
// 			opts.Host,
// 			opts.Database,
// 		)
// 	} else {
// 		dsn = fmt.Sprintf(
// 			"%v:%v@tcp(%v)/%v?charset=utf8mb4&parseTime=True&loc=Local",
// 			opts.Name,
// 			opts.Password,
// 			opts.Host,
// 			opts.Database,
// 		)
// 	}

// 	db, err := opts.OpenFunc(dsn)
// 	if err != nil {
// 		return nil, err
// 	}

// 	sqlDB, err := db.DB()
// 	if err != nil {
// 		return nil, err
// 	}

// 	var (
// 		defaultMaxIdleConns    = 50
// 		defaultMaxOpenConns    = 200
// 		defaultConnMaxLifetime = 10 * time.Second
// 	)

// 	maxIdleConns, err := strconv.Atoi(os.Getenv("MYSQL_MAX_IDLE_CONNS"))
// 	if err != nil || maxIdleConns <= 0 {
// 		maxIdleConns = defaultMaxIdleConns
// 	}

// 	maxOpenConns, err := strconv.Atoi(os.Getenv("MYSQL_MAX_OPEN_CONNS"))
// 	if err != nil || maxOpenConns <= 0 {
// 		maxOpenConns = defaultMaxOpenConns
// 	}

// 	var maxLifetime time.Duration

// 	connMaxLifetime, err := strconv.Atoi(os.Getenv("MYSQL_CONN_MAX_LIFETIME_IN_MS"))
// 	if err != nil || connMaxLifetime <= 0 {
// 		maxLifetime = defaultConnMaxLifetime
// 	} else {
// 		maxLifetime = time.Duration(connMaxLifetime)
// 	}

// 	// SetMaxOpenConns sets the maximum number of open connections to the database.
// 	sqlDB.SetMaxOpenConns(maxOpenConns)

// 	// SetMaxIdleConns sets the maximum number of connections in the idle connection pool.
// 	sqlDB.SetMaxIdleConns(maxIdleConns)

// 	// SetConnMaxLifetime sets the maximum amount of time a connection may be reused.
// 	sqlDB.SetConnMaxLifetime(maxLifetime)

// 	return db, nil
// }

// func newHTTPServer(db relayer.DB, l1EthClient relayer.EthClient, l2EthClient relayer.EthClient) (*http.Server, error) {
// 	eventRepo, err := repo.NewEventRepository(db)
// 	if err != nil {
// 		return nil, err
// 	}

// 	blockRepo, err := repo.NewBlockRepository(db)
// 	if err != nil {
// 		return nil, err
// 	}

// 	srv, err := http.NewServer(http.NewServerOpts{
// 		EventRepo:   eventRepo,
// 		Echo:        echo.New(),
// 		CorsOrigins: strings.Split(os.Getenv("CORS_ORIGINS"), ","),
// 		L1EthClient: l1EthClient,
// 		L2EthClient: l2EthClient,
// 		BlockRepo:   blockRepo,
// 	})
// 	if err != nil {
// 		return nil, err
// 	}

// 	return srv, nil
// }

// func makeProcessors(layer relayer.Layer,
// 	db relayer.DB,
// 	profitableOnly relayer.ProfitableOnly,
// ) ([]*processor.Processor, func()) {
// 	l1EthClient, err := ethclient.Dial(os.Getenv("L1_RPC_URL"))
// 	if err != nil {
// 		log.Fatal(err)
// 	}

// 	l2EthClient, err := ethclient.Dial(os.Getenv("L2_RPC_URL"))
// 	if err != nil {
// 		log.Fatal(err)
// 	}

// 	l1RpcClient, err := rpc.DialContext(context.Background(), os.Getenv("L1_RPC_URL"))
// 	if err != nil {
// 		log.Fatal(err)
// 	}

// 	l2RpcClient, err := rpc.DialContext(context.Background(), os.Getenv("L2_RPC_URL"))
// 	if err != nil {
// 		log.Fatal(err)
// 	}

// 	headerSyncIntervalInSeconds, err := strconv.Atoi(os.Getenv("HEADER_SYNC_INTERVAL_IN_SECONDS"))
// 	if err != nil || headerSyncIntervalInSeconds <= 0 {
// 		headerSyncIntervalInSeconds = defaultHeaderSyncIntervalSeconds
// 	}

// 	confirmations, err := strconv.Atoi(os.Getenv("CONFIRMATIONS_BEFORE_PROCESSING"))
// 	if err != nil || confirmations <= 0 {
// 		confirmations = defaultConfirmations
// 	}

// 	confirmationsTimeoutInSeconds, err := strconv.Atoi(os.Getenv("CONFIRMATIONS_TIMEOUT_IN_SECONDS"))
// 	if err != nil || confirmationsTimeoutInSeconds <= 0 {
// 		confirmationsTimeoutInSeconds = defaultConfirmationsTimeoutInSeconds
// 	}

// 	eventRepository, err := repo.NewEventRepository(db)
// 	if err != nil {
// 		log.Fatal(err)
// 	}

// 	q, err := openQueue()
// 	if err != nil {
// 		log.Fatal(err)
// 	}

// 	processors := make([]*processor.Processor, 0)

// 	if layer == relayer.L1 || layer == relayer.Both {
// 		prover, err := proof.New(l1EthClient)
// 		if err != nil {
// 			log.Fatal(err)
// 		}

// 		processor, err := processor.NewProcessor(processor.NewProcessorOpts{
// 			Prover:                        prover,
// 			ECDSAKey:                      os.Getenv("RELAYER_ECDSA_KEY"),
// 			RPCClient:                     l1RpcClient,
// 			SrcETHClient:                  l1EthClient,
// 			DestETHClient:                 l2EthClient,
// 			EventRepo:                     eventRepository,
// 			Queue:                         q,
// 			Confirmations:                 uint64(confirmations),
// 			ProfitableOnly:                profitableOnly,
// 			HeaderSyncIntervalInSeconds:   int64(headerSyncIntervalInSeconds),
// 			ConfirmationsTimeoutInSeconds: int64(confirmationsTimeoutInSeconds),
// 			DestBridgeAddress:             common.HexToAddress(os.Getenv("L2_BRIDGE_ADDRESS")),
// 			DestERC20VaultAddress:         common.HexToAddress(os.Getenv("L2_ERC20_VAULT_ADDRESS")),
// 			DestERC721VaultAddress:        common.HexToAddress(os.Getenv("L2_ERC721_VAULT_ADDRESS")),
// 			DestERC1155VaultAddress:       common.HexToAddress(os.Getenv("L2_ERC1155_VAULT_ADDRESS")),
// 			DestTaikoAddress:              common.HexToAddress(os.Getenv("L2_TAIKO_ADDRESS")),
// 			SrcSignalServiceAddress:       common.HexToAddress(os.Getenv("L1_SIGNAL_SERVICE_ADDRESS")),
// 		})
// 		if err != nil {
// 			log.Fatal(err)
// 		}

// 		processors = append(processors, processor)
// 	}

// 	if layer == relayer.L2 || layer == relayer.Both {
// 		prover, err := proof.New(l2EthClient)
// 		if err != nil {
// 			log.Fatal(err)
// 		}

// 		processor, err := processor.NewProcessor(processor.NewProcessorOpts{
// 			Prover:                        prover,
// 			ECDSAKey:                      os.Getenv("RELAYER_ECDSA_KEY"),
// 			RPCClient:                     l2RpcClient,
// 			SrcETHClient:                  l2EthClient,
// 			DestETHClient:                 l1EthClient,
// 			EventRepo:                     eventRepository,
// 			Queue:                         q,
// 			Confirmations:                 uint64(confirmations),
// 			ProfitableOnly:                profitableOnly,
// 			HeaderSyncIntervalInSeconds:   int64(headerSyncIntervalInSeconds),
// 			ConfirmationsTimeoutInSeconds: int64(confirmationsTimeoutInSeconds),
// 			DestBridgeAddress:             common.HexToAddress(os.Getenv("L1_BRIDGE_ADDRESS")),
// 			DestERC20VaultAddress:         common.HexToAddress(os.Getenv("L1_ERC20_VAULT_ADDRESS")),
// 			DestERC721VaultAddress:        common.HexToAddress(os.Getenv("L1_ERC721_VAULT_ADDRESS")),
// 			DestERC1155VaultAddress:       common.HexToAddress(os.Getenv("L1_ERC1155_VAULT_ADDRESS")),
// 			DestTaikoAddress:              common.HexToAddress(os.Getenv("L1_TAIKO_ADDRESS")),
// 			SrcSignalServiceAddress:       common.HexToAddress(os.Getenv("L2_SIGNAL_SERVICE_ADDRESS")),
// 		})
// 		if err != nil {
// 			log.Fatal(err)
// 		}

// 		processors = append(processors, processor)
// 	}

// 	closeFunc := func() {
// 		l1EthClient.Close()
// 		l2EthClient.Close()
// 		l1RpcClient.Close()
// 		l2RpcClient.Close()
// 	}

// 	return processors, closeFunc
// }
