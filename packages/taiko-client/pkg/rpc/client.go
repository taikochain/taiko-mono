package rpc

import (
	"context"
	"fmt"
	"os"
	"time"

	"github.com/cenkalti/backoff/v4"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/log"

	"github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings"
)

const (
	defaultTimeout = 1 * time.Minute
)

// Client contains all L1/L2 RPC clients that a driver needs.
type Client struct {
	// Geth ethclient clients
	L1           *EthClient
	L2           *EthClient
	L2CheckPoint *EthClient
	// Geth Engine API clients
	L2Engine *EngineClient
	// Beacon clients
	L1Beacon *BeaconClient
	// Protocol contracts clients
	TaikoL1                *bindings.TaikoL1Client
	LibProposing           *bindings.LibProposing
	TaikoL2                *bindings.TaikoL2Client
	TaikoToken             *bindings.TaikoToken
	GuardianProverMajority *bindings.GuardianProver
	GuardianProverMinority *bindings.GuardianProver
	ProverSet              *bindings.ProverSet
}

// ClientConfig contains all configs which will be used to initializing an
// RPC client. If not providing L2EngineEndpoint or JwtSecret, then the L2Engine client
// won't be initialized.
type ClientConfig struct {
	L1Endpoint                    string
	L2Endpoint                    string
	L1BeaconEndpoint              string
	L2CheckPoint                  string
	TaikoL1Address                common.Address
	TaikoL2Address                common.Address
	TaikoTokenAddress             common.Address
	GuardianProverMinorityAddress common.Address
	GuardianProverMajorityAddress common.Address
	ProverSetAddress              common.Address
	L2EngineEndpoint              string
	JwtSecret                     string
	Timeout                       time.Duration
}

// NewClient initializes all RPC clients used by Taiko client software.
func NewClient(ctx context.Context, cfg *ClientConfig) (*Client, error) {
	log.Debug("Initializing new RPC client")
	var (
		l1Client       *EthClient
		l2Client       *EthClient
		l1BeaconClient *BeaconClient
		l2CheckPoint   *EthClient
		err            error
	)

	// Keep retrying to connect to the RPC endpoints until success or context is cancelled.
	if err := backoff.Retry(func() error {
		log.Debug("Attempting to connect to RPC endpoints")
		ctxWithTimeout, cancel := CtxWithTimeoutOrDefault(ctx, defaultTimeout)
		defer cancel()

		if l1Client, err = NewEthClient(ctxWithTimeout, cfg.L1Endpoint, cfg.Timeout); err != nil {
			log.Error("Failed to connect to L1 endpoint, retrying", "endpoint", cfg.L1Endpoint, "err", err)
			return err
		}
		log.Debug("Successfully connected to L1 endpoint", "endpoint", cfg.L1Endpoint)

		if l2Client, err = NewEthClient(ctxWithTimeout, cfg.L2Endpoint, cfg.Timeout); err != nil {
			log.Error("Failed to connect to L2 endpoint, retrying", "endpoint", cfg.L2Endpoint, "err", err)
			return err
		}
		log.Debug("Successfully connected to L2 endpoint", "endpoint", cfg.L2Endpoint)

		// NOTE: when running tests, we do not have a L1 beacon endpoint.
		if cfg.L1BeaconEndpoint != "" && os.Getenv("RUN_TESTS") == "" {
			if l1BeaconClient, err = NewBeaconClient(cfg.L1BeaconEndpoint, defaultTimeout); err != nil {
				log.Error("Failed to connect to L1 beacon endpoint, retrying", "endpoint", cfg.L1BeaconEndpoint, "err", err)
				return err
			}
			log.Debug("Successfully connected to L1 beacon endpoint", "endpoint", cfg.L1BeaconEndpoint)
		}

		if cfg.L2CheckPoint != "" {
			l2CheckPoint, err = NewEthClient(ctxWithTimeout, cfg.L2CheckPoint, cfg.Timeout)
			if err != nil {
				log.Error("Failed to connect to L2 checkpoint endpoint, retrying", "endpoint", cfg.L2CheckPoint, "err", err)
				return err
			}
			log.Debug("Successfully connected to L2 checkpoint endpoint", "endpoint", cfg.L2CheckPoint)
		}

		return nil
	}, backoff.WithContext(backoff.NewExponentialBackOff(), ctx)); err != nil {
		return nil, err
	}

	log.Debug("Initializing contract clients")
	ctxWithTimeout, cancel := CtxWithTimeoutOrDefault(ctx, defaultTimeout)
	defer cancel()

	taikoL1, err := bindings.NewTaikoL1Client(cfg.TaikoL1Address, l1Client)
	if err != nil {
		return nil, fmt.Errorf("failed to initialize TaikoL1 client: %w", err)
	}
	log.Debug("TaikoL1 client initialized", "address", cfg.TaikoL1Address)

	libProposing, err := bindings.NewLibProposing(cfg.TaikoL1Address, l1Client)
	if err != nil {
		return nil, fmt.Errorf("failed to initialize LibProposing: %w", err)
	}

	taikoL2, err := bindings.NewTaikoL2Client(cfg.TaikoL2Address, l2Client)
	if err != nil {
		return nil, fmt.Errorf("failed to initialize TaikoL2 client: %w", err)
	}
	log.Debug("TaikoL2 client initialized", "address", cfg.TaikoL2Address)

	var (
		taikoToken             *bindings.TaikoToken
		guardianProverMajority *bindings.GuardianProver
		guardianProverMinority *bindings.GuardianProver
		proverSet              *bindings.ProverSet
	)
	if cfg.TaikoTokenAddress.Hex() != ZeroAddress.Hex() {
		if taikoToken, err = bindings.NewTaikoToken(cfg.TaikoTokenAddress, l1Client); err != nil {
			return nil, fmt.Errorf("failed to initialize TaikoToken: %w", err)
		}
		log.Debug("TaikoToken initialized", "address", cfg.TaikoTokenAddress)
	}
	if cfg.GuardianProverMinorityAddress.Hex() != ZeroAddress.Hex() {
		if guardianProverMinority, err = bindings.NewGuardianProver(cfg.GuardianProverMinorityAddress, l1Client); err != nil {
			return nil, fmt.Errorf("failed to initialize GuardianProverMinority: %w", err)
		}
	}
	if cfg.GuardianProverMajorityAddress.Hex() != ZeroAddress.Hex() {
		if guardianProverMajority, err = bindings.NewGuardianProver(cfg.GuardianProverMajorityAddress, l1Client); err != nil {
			return nil, fmt.Errorf("failed to initialize GuardianProverMajority: %w", err)
		}
	}
	if cfg.ProverSetAddress.Hex() != ZeroAddress.Hex() {
		if proverSet, err = bindings.NewProverSet(cfg.ProverSetAddress, l1Client); err != nil {
			return nil, fmt.Errorf("failed to initialize ProverSet: %w", err)
		}
	}

	// If not providing L2EngineEndpoint or JwtSecret, then the L2Engine client
	// won't be initialized.
	var l2AuthClient *EngineClient
	if len(cfg.L2EngineEndpoint) != 0 && len(cfg.JwtSecret) != 0 {
		log.Debug("Initializing L2 Engine client", "endpoint", cfg.L2EngineEndpoint)
		l2AuthClient, err = NewJWTEngineClient(cfg.L2EngineEndpoint, cfg.JwtSecret)
		if err != nil {
			return nil, fmt.Errorf("failed to initialize L2 Engine client: %w", err)
		}
	}

	client := &Client{
		L1:                     l1Client,
		L1Beacon:               l1BeaconClient,
		L2:                     l2Client,
		L2CheckPoint:           l2CheckPoint,
		L2Engine:               l2AuthClient,
		TaikoL1:                taikoL1,
		LibProposing:           libProposing,
		TaikoL2:                taikoL2,
		TaikoToken:             taikoToken,
		GuardianProverMajority: guardianProverMajority,
		GuardianProverMinority: guardianProverMinority,
		ProverSet:              proverSet,
	}

	if err := client.ensureGenesisMatched(ctxWithTimeout); err != nil {
		return nil, fmt.Errorf("genesis mismatch detected: %w", err)
	}

	log.Debug("RPC client initialization completed successfully")
	return client, nil
}
