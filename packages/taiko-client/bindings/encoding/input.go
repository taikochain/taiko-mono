package encoding

import (
	"errors"
	"fmt"

	"github.com/ethereum/go-ethereum/accounts/abi"
	"github.com/ethereum/go-ethereum/log"

	"github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/metadata"
	ontakeBindings "github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/ontake"
	pacayaBindings "github.com/taikoxyz/taiko-mono/packages/taiko-client/bindings/pacaya"
)

// ABI arguments marshaling components.
var (
<<<<<<< HEAD
	blockMetadataV2Components = []abi.ArgumentMarshaling{
=======
	BlockMetadataV2Components = []abi.ArgumentMarshaling{
>>>>>>> f4e64dc17 (feat: update bindings)
		{
			Name: "anchorBlockHash",
			Type: "bytes32",
		},
		{
			Name: "difficulty",
			Type: "bytes32",
		},
		{
			Name: "blobHash",
			Type: "bytes32",
		},
		{
			Name: "extraData",
			Type: "bytes32",
		},
		{
			Name: "coinbase",
			Type: "address",
		},
		{
			Name: "id",
			Type: "uint64",
		},
		{
			Name: "gasLimit",
			Type: "uint32",
		},
		{
			Name: "timestamp",
			Type: "uint64",
		},
		{
			Name: "anchorBlockId",
			Type: "uint64",
		},
		{
			Name: "minTier",
			Type: "uint16",
		},
		{
			Name: "blobUsed",
			Type: "bool",
		},
		{
			Name: "parentMetaHash",
			Type: "bytes32",
		},
		{
			Name: "proposer",
			Type: "address",
		},
		{
			Name: "livenessBond",
			Type: "uint96",
		},
		{
			Name: "proposedAt",
			Type: "uint64",
		},
		{
			Name: "proposedIn",
			Type: "uint64",
		},
		{
			Name: "blobTxListOffset",
			Type: "uint32",
		},
		{
			Name: "blobTxListLength",
			Type: "uint32",
		},
		{
			Name: "blobIndex",
			Type: "uint8",
		},
		{
			Name: "baseFeeConfig",
			Type: "tuple",
			Components: []abi.ArgumentMarshaling{
				{
					Name: "adjustmentQuotient",
					Type: "uint8",
				},
				{
					Name: "sharingPctg",
					Type: "uint8",
				},
				{
					Name: "gasIssuancePerSecond",
					Type: "uint32",
				},
				{
					Name: "minGasExcess",
					Type: "uint64",
				},
				{
					Name: "maxGasIssuancePerBlock",
					Type: "uint32",
				},
			},
		},
	}
	transitionComponents = []abi.ArgumentMarshaling{
		{
			Name: "parentHash",
			Type: "bytes32",
		},
		{
			Name: "blockHash",
			Type: "bytes32",
		},
		{
			Name: "stateRoot",
			Type: "bytes32",
		},
		{
			Name: "graffiti",
			Type: "bytes32",
		},
	}
	tierProofComponents = []abi.ArgumentMarshaling{
		{
			Name: "tier",
			Type: "uint16",
		},
		{
			Name: "data",
			Type: "bytes",
		},
	}
	blockParamsV2Components = []abi.ArgumentMarshaling{
		{
			Name: "proposer",
			Type: "address",
		},
		{
			Name: "coinbase",
			Type: "address",
		},
		{
			Name: "parentMetaHash",
			Type: "bytes32",
		},
		{
			Name: "anchorBlockId",
			Type: "uint64",
		},
		{
			Name: "timestamp",
			Type: "uint64",
		},
		{
			Name: "blobTxListOffset",
			Type: "uint32",
		},
		{
			Name: "blobTxListLength",
			Type: "uint32",
		},
		{
			Name: "blobIndex",
			Type: "uint8",
		},
	}
)

var (
	blockParamsV2ComponentsType, _   = abi.NewType("tuple", "TaikoData.BlockParamsV2", blockParamsV2Components)
	blockParamsV2ComponentsArgs      = abi.Arguments{{Name: "TaikoData.BlockParamsV2", Type: blockParamsV2ComponentsType}}
	blockMetadataV2ComponentsType, _ = abi.NewType("tuple", "TaikoData.BlockMetadataV2", blockMetadataV2Components)
	transitionComponentsType, _      = abi.NewType("tuple", "TaikoData.Transition", transitionComponents)
	tierProofComponentsType, _       = abi.NewType("tuple", "TaikoData.TierProof", tierProofComponents)
	proveOntakeBlockInputArgs        = abi.Arguments{
		{Name: "TaikoData.BlockMetadataV2", Type: blockMetadataV2ComponentsType},
		{Name: "TaikoData.Transition", Type: transitionComponentsType},
		{Name: "TaikoData.TierProof", Type: tierProofComponentsType},
	}
	proveBlocksInputArgs = abi.Arguments{
		{Name: "TaikoData.BlockMetadata", Type: blockMetadataV2ComponentsType},
		{Name: "TaikoData.Transition", Type: transitionComponentsType},
	}
	proveBlocksBatchProofArgs = abi.Arguments{
		{Name: "TaikoData.TierProof", Type: tierProofComponentsType},
	}
)

// Contract ABIs.
var (
	// Ontake fork
	TaikoL1ABI          *abi.ABI
	TaikoL2ABI          *abi.ABI
	TaikoTokenABI       *abi.ABI
	GuardianProverABI   *abi.ABI
	LibProposingABI     *abi.ABI
	LibProvingABI       *abi.ABI
	LibUtilsABI         *abi.ABI
	LibVerifyingABI     *abi.ABI
	SGXVerifierABI      *abi.ABI
	GuardianVerifierABI *abi.ABI
	ProverSetABI        *abi.ABI
	ForkManagerABI      *abi.ABI

	// Pacaya fork
	TaikoInboxABI        *abi.ABI
	TaikoAnchorABI       *abi.ABI
	ForkManagerPacayaABI *abi.ABI
	TaikoTokenPacayaABI  *abi.ABI
	ProverSetPavayaABI   *abi.ABI

	customErrorMaps []map[string]abi.Error
)

func init() {
	var err error

	if TaikoL1ABI, err = ontakeBindings.TaikoL1ClientMetaData.GetAbi(); err != nil {
		log.Crit("Get TaikoL1 ABI error", "error", err)
	}

	if TaikoL2ABI, err = ontakeBindings.TaikoL2ClientMetaData.GetAbi(); err != nil {
		log.Crit("Get TaikoL2 ABI error", "error", err)
	}

	if TaikoTokenABI, err = ontakeBindings.TaikoTokenMetaData.GetAbi(); err != nil {
		log.Crit("Get TaikoToken ABI error", "error", err)
	}

	if GuardianProverABI, err = ontakeBindings.GuardianProverMetaData.GetAbi(); err != nil {
		log.Crit("Get GuardianProver ABI error", "error", err)
	}

	if LibProposingABI, err = ontakeBindings.LibProposingMetaData.GetAbi(); err != nil {
		log.Crit("Get LibProposing ABI error", "error", err)
	}

	if LibProvingABI, err = ontakeBindings.LibProvingMetaData.GetAbi(); err != nil {
		log.Crit("Get LibProving ABI error", "error", err)
	}

	if LibUtilsABI, err = ontakeBindings.LibUtilsMetaData.GetAbi(); err != nil {
		log.Crit("Get LibUtils ABI error", "error", err)
	}

	if LibVerifyingABI, err = ontakeBindings.LibVerifyingMetaData.GetAbi(); err != nil {
		log.Crit("Get LibVerifying ABI error", "error", err)
	}

	if SGXVerifierABI, err = ontakeBindings.SgxVerifierMetaData.GetAbi(); err != nil {
		log.Crit("Get SGXVerifier ABI error", err)
	}

	if GuardianVerifierABI, err = ontakeBindings.GuardianVerifierMetaData.GetAbi(); err != nil {
		log.Crit("Get GuardianVerifier ABI error", "error", err)
	}

	if ProverSetABI, err = ontakeBindings.ProverSetMetaData.GetAbi(); err != nil {
		log.Crit("Get ProverSet ABI error", "error", err)
	}

	if ForkManagerABI, err = ontakeBindings.ForkManagerMetaData.GetAbi(); err != nil {
		log.Crit("Get ForkManager ABI error", "error", err)
	}

	if TaikoInboxABI, err = pacayaBindings.TaikoAnchorClientMetaData.GetAbi(); err != nil {
		log.Crit("Get TaikoInbox ABI error", "error", err)
	}

	if TaikoAnchorABI, err = pacayaBindings.TaikoAnchorClientMetaData.GetAbi(); err != nil {
		log.Crit("Get TaikoAnchor ABI error", "error", err)
	}

	if ForkManagerPacayaABI, err = pacayaBindings.ForkManagerMetaData.GetAbi(); err != nil {
		log.Crit("Get ForkManager ABI error", "error", err)
	}

	if TaikoTokenPacayaABI, err = pacayaBindings.TaikoTokenMetaData.GetAbi(); err != nil {
		log.Crit("Get TaikoToken ABI error", "error", err)
	}

	if ProverSetPavayaABI, err = pacayaBindings.ProverSetMetaData.GetAbi(); err != nil {
		log.Crit("Get ProverSet ABI error", "error", err)
	}

	customErrorMaps = []map[string]abi.Error{
		TaikoL1ABI.Errors,
		TaikoL2ABI.Errors,
		GuardianProverABI.Errors,
		LibProposingABI.Errors,
		LibProvingABI.Errors,
		LibUtilsABI.Errors,
		LibVerifyingABI.Errors,
		SGXVerifierABI.Errors,
		GuardianVerifierABI.Errors,
		ProverSetABI.Errors,
		ForkManagerABI.Errors,
		TaikoInboxABI.Errors,
		TaikoAnchorABI.Errors,
		ForkManagerPacayaABI.Errors,
		TaikoTokenPacayaABI.Errors,
		ProverSetPavayaABI.Errors,
	}
}

// EncodeBlockParamsOntake performs the solidity `abi.encode` for the given ontake blockParams.
func EncodeBlockParamsOntake(params *BlockParamsV2) ([]byte, error) {
	b, err := blockParamsV2ComponentsArgs.Pack(params)
	if err != nil {
		return nil, fmt.Errorf("failed to abi.encode ontake block params, %w", err)
	}
	return b, nil
}

// EncodeProveBlockInput performs the solidity `abi.encode` for the given TaikoL1.proveBlock input.
func EncodeProveBlockInput(
	meta metadata.TaikoBlockMetaData,
	transition *ontakeBindings.TaikoDataTransition,
	tierProof *ontakeBindings.TaikoDataTierProof,
) ([]byte, error) {
	var (
		b   []byte
		err error
	)
	if b, err = proveOntakeBlockInputArgs.Pack(
		meta.(*metadata.TaikoDataBlockMetadataOntake).InnerMetadata(),
		transition,
		tierProof,
	); err != nil {
		return nil, fmt.Errorf("failed to abi.encode TakoL1.proveBlock input after ontake fork, %w", err)
	}

	return b, nil
}

// EncodeProveBlocksInput performs the solidity `abi.encode` for the given TaikoL1.proveBlocks input.
func EncodeProveBlocksInput(
	metas []metadata.TaikoBlockMetaData,
	transitions []ontakeBindings.TaikoDataTransition,
) ([][]byte, error) {
	if len(metas) != len(transitions) {
		return nil, fmt.Errorf("both arrays of TaikoBlockMetaData and TaikoDataTransition must be equal in length")
	}
	b := make([][]byte, 0, len(metas))
	for i := range metas {
		input, err := proveBlocksInputArgs.Pack(
			metas[i].(*metadata.TaikoDataBlockMetadataOntake).InnerMetadata(),
			transitions[i],
		)
		if err != nil {
			return nil, fmt.Errorf("failed to abi.encode TaikoL1.proveBlocks input item after ontake fork, %w", err)
		}

		b = append(b, input)
	}

	return b, nil
}

// EncodeProveBlocksBatchProof performs the solidity `abi.encode` for the given TaikoL1.proveBlocks batchProof.
func EncodeProveBlocksBatchProof(
	tierProof *ontakeBindings.TaikoDataTierProof,
) ([]byte, error) {
	input, err := proveBlocksBatchProofArgs.Pack(
		tierProof,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to abi.encode TaikoL1.proveBlocks input item after ontake fork, %w", err)
	}
	return input, nil
}

// UnpackTxListBytes unpacks the input data of a TaikoL1.proposeBlock transaction, and returns the txList bytes.
func UnpackTxListBytes(txData []byte) ([]byte, error) {
	method, err := TaikoL1ABI.MethodById(txData)
	if err != nil {
		return nil, err
	}

	// Only check for safety.
	if method.Name != "proposeBlock" && method.Name != "proposeBlockV2" {
		return nil, fmt.Errorf("invalid method name: %s", method.Name)
	}

	args := map[string]interface{}{}

	if err := method.Inputs.UnpackIntoMap(args, txData[4:]); err != nil {
		return nil, err
	}

	inputs, ok := args["_txList"].([]byte)

	if !ok {
		return nil, errors.New("failed to get txList bytes")
	}

	return inputs, nil
}
