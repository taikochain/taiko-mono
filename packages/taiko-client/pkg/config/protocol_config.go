package config

import (
	"fmt"
	"math/big"
	"time"

	ontakeBindings "github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/ontake"
	pacayaBindings "github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/pacaya"
)

// Configs is an interface that provides Taiko protocol specific configurations.
type ProtocolConfigs interface {
	BaseFeeConfig() *pacayaBindings.LibSharedDataBaseFeeConfig
	BlockMaxGasLimit() uint32
	ForkHeightsOntake() uint64
	ForkHeightsPacaya() uint64
	LivenessBond() *big.Int
	MaxProposals() uint64
	ProvingWindow() (time.Duration, error)
}

// OntakeProtocolConfigs is the configuration for the Ontake fork protocol.
type OntakeProtocolConfigs struct {
	configs          *ontakeBindings.TaikoDataConfig
	pacayaForkHeight uint64
}

// NewOntakeProtocolConfigs creates a new OntakeProtocolConfigs instance.
func NewOntakeProtocolConfigs(configs *ontakeBindings.TaikoDataConfig, pacayaForkHeight uint64) *OntakeProtocolConfigs {
	return &OntakeProtocolConfigs{
		configs:          configs,
		pacayaForkHeight: pacayaForkHeight,
	}
}

// BaseFeeConfig implements the ProtocolConfigs interface.
func (c *OntakeProtocolConfigs) BaseFeeConfig() *pacayaBindings.LibSharedDataBaseFeeConfig {
	return &pacayaBindings.LibSharedDataBaseFeeConfig{
		AdjustmentQuotient:     c.configs.BaseFeeConfig.AdjustmentQuotient,
		SharingPctg:            c.configs.BaseFeeConfig.SharingPctg,
		GasIssuancePerSecond:   c.configs.BaseFeeConfig.GasIssuancePerSecond,
		MinGasExcess:           c.configs.BaseFeeConfig.MinGasExcess,
		MaxGasIssuancePerBlock: c.configs.BaseFeeConfig.MaxGasIssuancePerBlock,
	}
}

// ForkHeightsOntake implements the ProtocolConfigs interface.
func (c *OntakeProtocolConfigs) BlockMaxGasLimit() uint32 {
	return c.configs.BlockMaxGasLimit
}

// ForkHeightsOntake implements the ProtocolConfigs interface.
func (c *OntakeProtocolConfigs) ForkHeightsOntake() uint64 {
	return c.configs.OntakeForkHeight
}

// ForkHeightsPacaya implements the ProtocolConfigs interface.
func (c *OntakeProtocolConfigs) ForkHeightsPacaya() uint64 {
	return c.pacayaForkHeight
}

// LivenessBond implements the ProtocolConfigs interface.
func (c *OntakeProtocolConfigs) LivenessBond() *big.Int {
	return c.configs.LivenessBond
}

// MaxProposals implements the ProtocolConfigs interface.
func (c *OntakeProtocolConfigs) MaxProposals() uint64 {
	return c.configs.BlockMaxProposals
}

// ProvingWindow implements the ProtocolConfigs interface.
func (c *OntakeProtocolConfigs) ProvingWindow() (time.Duration, error) {
	return 0, fmt.Errorf("proving window is not supported in Ontake protocol configs")
}

// PacayaProtocolConfigs is the configuration for the Pacaya fork protocol.
type PacayaProtocolConfigs struct {
	configs *pacayaBindings.ITaikoInboxConfig
}

// NewPacayaProtocolConfigs creates a new PacayaProtocolConfigs instance.
func NewPacayaProtocolConfigs(configs *pacayaBindings.ITaikoInboxConfig) *PacayaProtocolConfigs {
	return &PacayaProtocolConfigs{configs: configs}
}

// BaseFeeConfig implements the ProtocolConfigs interface.
func (c *PacayaProtocolConfigs) BaseFeeConfig() *pacayaBindings.LibSharedDataBaseFeeConfig {
	return &c.configs.BaseFeeConfig
}

// ForkHeightsOntake implements the ProtocolConfigs interface.
func (c *PacayaProtocolConfigs) BlockMaxGasLimit() uint32 {
	return c.configs.BlockMaxGasLimit
}

// ForkHeightsOntake implements the ProtocolConfigs interface.
func (c *PacayaProtocolConfigs) ForkHeightsOntake() uint64 {
	return c.configs.ForkHeights.Ontake
}

// ForkHeightsPacaya implements the ProtocolConfigs interface.
func (c *PacayaProtocolConfigs) ForkHeightsPacaya() uint64 {
	return c.configs.ForkHeights.Pacaya
}

// MaxProposals implements the ProtocolConfigs interface.
func (c *PacayaProtocolConfigs) LivenessBond() *big.Int {
	return c.configs.LivenessBondBase // TODO: add livenessBondPerBlock
}

// MaxProposals implements the ProtocolConfigs interface.
func (c *PacayaProtocolConfigs) MaxProposals() uint64 {
	return c.configs.MaxBatchProposals
}

// ProvingWindow implements the ProtocolConfigs interface.
func (c *PacayaProtocolConfigs) ProvingWindow() (time.Duration, error) {
	return time.Duration(c.configs.ProvingWindow) * time.Second, nil
}
