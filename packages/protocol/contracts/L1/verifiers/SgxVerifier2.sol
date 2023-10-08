// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.20;

import { ECDSAUpgradeable } from "@ozu/utils/cryptography/ECDSAUpgradeable.sol";

import { EssentialContract } from "../../common/EssentialContract.sol";
import { Proxied } from "../../common/Proxied.sol";
import { LibBytesUtils } from "../../thirdparty/LibBytesUtils.sol";

import { TaikoData } from "../TaikoData.sol";

import { IVerifier } from "./IVerifier.sol";

/// @title SgxVerifier2
contract SgxVerifier2 is EssentialContract, IVerifier {
    using ECDSAUpgradeable for bytes32;

    uint256 public constant INSTANCE_EXPIRY = 180 days;

    mapping(address instance => uint256 registeredAt) public instances;

    uint256[49] private __gap;

    event InstanceRegistered(address indexed instance, uint256 registeredAt);

    event InstanceDeleted(address indexed instance, uint256 deletedAt);

    error SGX_INSTANCE_NOT_FOUND();
    error SGX_INSTANCE_REGISTERED();
    error SGX_INVALID_INSTANCE();
    error SGX_INVALID_PROOF_SIZE();

    /// @notice Initializes the contract with the provided address manager.
    /// @param _addressManager The address of the address manager contract.
    function init(address _addressManager) external initializer {
        EssentialContract._init(_addressManager);
    }

    function registerInstance(address instance) external onlyOwner {
        _registerInstance(instance);
    }

    function updateInstance(
        address[] calldata newInstances,
        bytes memory signature
    )
        external
    {
        address oldInstance = keccak256(
            abi.encode("REGISTER_SGX_INSTANCE", newInstances)
        ).recover(signature);

        _deregisterInstance(oldInstance);

        for (uint256 i; i < newInstances.length; ++i) {
            _registerInstance(newInstances[i]);
        }
    }

    /// @inheritdoc IVerifier
    function verifyProof(
        uint64,
        address prover,
        bool isContesting,
        TaikoData.BlockEvidence calldata evidence
    )
        external
        onlyFromNamed("taiko")
    {
        // Do not run proof verification to contest an existing proof
        if (isContesting) return;

        // Size is: 87 bytes
        // 2 bytes + 20 bytes + 65 bytes = 87
        if (evidence.proof.length <= 20) {
            revert SGX_INVALID_PROOF_SIZE();
        }

        address newInstance =
            address(bytes20(LibBytesUtils.slice(evidence.proof, 0, 20)));

        bytes memory signature = LibBytesUtils.slice(evidence.proof, 20);

        address oldInstance =
            getSignedHash(evidence, prover, newInstance).recover(signature);

        _deregisterInstance(oldInstance);
        _registerInstance(newInstance);
    }

    function isInstanceValid(address instance) public view returns (bool) {
        return instances[instance] + INSTANCE_EXPIRY > block.timestamp;
    }

    function getSignedHash(
        TaikoData.BlockEvidence memory evidence,
        address prover,
        address newAddress
    )
        public
        pure
        returns (bytes32 signedHash)
    {
        return keccak256(
            abi.encode(
                evidence.metaHash,
                evidence.parentHash,
                evidence.blockHash,
                evidence.signalRoot,
                evidence.graffiti,
                prover,
                newAddress
            )
        );
    }

    function _deregisterInstance(address instance) private {
        if (instance == address(0)) revert SGX_INVALID_INSTANCE();
        if (!isInstanceValid(instance)) revert SGX_INSTANCE_NOT_FOUND();
        instances[instance] = 1;
        emit InstanceDeleted(instance, block.timestamp);
    }

    function _registerInstance(address instance) private {
        if (instance == address(0)) revert SGX_INVALID_INSTANCE();
        if (instances[instance] != 0) revert SGX_INSTANCE_REGISTERED();

        instances[instance] = block.timestamp;
        emit InstanceRegistered(instance, block.timestamp);
    }
}

/// @title ProxiedSgxVerifier2
/// @notice Proxied version of the parent contract.
contract ProxiedSgxVerifier2 is Proxied, SgxVerifier2 { }
