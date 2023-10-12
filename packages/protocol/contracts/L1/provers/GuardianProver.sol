// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.20;

import { EssentialContract } from "../../common/EssentialContract.sol";
import { Proxied } from "../../common/Proxied.sol";

import { LibTiers } from "../tiers/ITierProvider.sol";
import { TaikoData } from "../TaikoData.sol";

/// @title GuardianProver
contract GuardianProver is EssentialContract {
    uint256 public constant NUM_GUARDIANS = 5;
    uint256 public constant REQUIRED_GUARDIANS = 3;

    event GuardiansUpdated(address[NUM_GUARDIANS]);
    event Approved(
        uint64 blockId,
        TaikoData.BlockEvidence evidence,
        uint256 approvalBits,
        bool proofSubmitted
    );

    address[NUM_GUARDIANS] public guardians;
    mapping(address guardian => uint256 id) public guardianIds;
    mapping(bytes32 => uint256 approvalBits) public approvals;

    uint256[47] private __gap;

    error INVALID_GUARDIAN();
    error INVALID_GUARDIAN_SET();
    error INVALID_PROOF();
    error PROVING_FAILED();

    /// @notice Initializes the contract with the provided address manager.
    /// @param _addressManager The address of the address manager contract.
    function init(address _addressManager) external initializer {
        EssentialContract._init(_addressManager);
    }

    /// @notice Set the set of guardians
    /// @param _guardians The new set of guardians
    function setGuardians(address[NUM_GUARDIANS] memory _guardians)
        external
        onlyOwner
    {
        // In case there is a pending 'approval' and we call setGuardians() with
        // an existing guardian but with different array position (id), then
        // accidentally 2 guardian signatures could lead to firing away a
        // proveBlock() transaction.
        if (!_correctOverlaps(_guardians)) {
            revert INVALID_GUARDIAN_SET();
        }

        for (uint256 i; i < NUM_GUARDIANS; ++i) {
            delete guardianIds[guardians[i]];

            address guardian = _guardians[i];
            if (guardian == address(0) || guardianIds[guardian] != 0) {
                revert INVALID_GUARDIAN();
            }

            guardianIds[guardian] = i + 1;
            guardians[i] = guardian;
        }

        emit GuardiansUpdated(_guardians);
    }

    /// @dev Called by guardians to approve a guardian proof
    function approveGuardianProof(
        uint64 blockId,
        TaikoData.BlockEvidence memory evidence
    )
        external
    {
        uint256 id = guardianIds[msg.sender];
        if (id == 0) revert INVALID_GUARDIAN();

        if (evidence.tier != LibTiers.TIER_GUARDIAN) revert INVALID_PROOF();

        bytes32 hash = keccak256(abi.encode(blockId, evidence));
        uint256 approvalBits = approvals[hash];

        approvalBits |= 1 << id;

        if (_isApproved(approvalBits)) {
            bytes memory data = abi.encodeWithSignature(
                "proveBlock(uint64,bytes)", blockId, abi.encode(evidence)
            );

            (bool success,) = resolve("taiko", false).call(data);

            if (!success) revert PROVING_FAILED();
            delete approvals[hash];

            emit Approved(blockId, evidence, approvalBits, true);
        } else {
            approvals[hash] = approvalBits;
            emit Approved(blockId, evidence, approvalBits, false);
        }
    }

    function _isApproved(uint256 approvalBits) private pure returns (bool) {
        uint256 count;
        uint256 bits = approvalBits >> 1;
        for (uint256 i; i < NUM_GUARDIANS; ++i) {
            if (bits & 1 == 1) ++count;
            if (count == REQUIRED_GUARDIANS) return true;
            bits >>= 1;
        }
        return false;
    }

    function _correctOverlaps(address[NUM_GUARDIANS] memory _guardians)
        private
        view
        returns (bool result)
    {
        // Basically going over the array and see if there is a duplicate and if
        // so, they are NOT in the same position, revert.
        for (uint256 i; i < NUM_GUARDIANS; ++i) {
            if (
                guardianIds[_guardians[i]] != 0 && guardians[i] != _guardians[i]
            ) {
                return false;
            }
        }
        result = true;
    }
}

/// @title ProxiedGuardianProver
/// @notice Proxied version of the parent contract.
contract ProxiedGuardianProver is Proxied, GuardianProver { }
