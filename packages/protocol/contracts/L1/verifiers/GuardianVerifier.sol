// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.20;

import { EssentialContract } from "../../common/EssentialContract.sol";
import { Proxied } from "../../common/Proxied.sol";

import { TaikoData } from "../TaikoData.sol";

import { IVerifier } from "./IVerifier.sol";

/// @title GuardianVerifier
contract GuardianVerifier is EssentialContract, IVerifier {
    uint256[50] private __gap;

    error PERMISSION_DENIED();

    /// @notice Initializes the contract with the provided address manager.
    /// @param _addressManager The address of the address manager contract.
    function init(address _addressManager) external initializer {
        EssentialContract._init(_addressManager);
    }

    /// @inheritdoc IVerifier
    function verifyProof(
        uint64, /*blockId*/
        address prover,
        bool, /*isContesting*/
        TaikoData.BlockEvidence calldata /*evidence*/
    )
        external
        view
    {
        if (prover != resolve("guardian", false)) revert PERMISSION_DENIED();
    }
}

/// @title ProxiedGuardianVerifier
/// @notice Proxied version of the parent contract.
contract ProxiedGuardianVerifier is Proxied, GuardianVerifier { }
