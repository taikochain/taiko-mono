// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.18;

import { AddressResolver } from "../common/AddressResolver.sol";
import { EssentialContract } from "../common/EssentialContract.sol";
import { Proxied } from "../common/Proxied.sol";
import { LibVerifyZKP } from "./libs/proofTypes/LibVerifyZKP.sol";
import { IProofVerifier } from "./IProofVerifier.sol";

/// @custom:security-contact hello@taiko.xyz
contract ProofVerifier is EssentialContract, IProofVerifier {
    uint256[50] private __gap;

    function init(address _addressManager) external initializer {
        EssentialContract._init(_addressManager);
    }

    /**
     * Verifying proofs
     *
     * @param blockProofs Raw bytes of proof(s)
     */
    function verifyProofs(
        uint256, //Can be used later when supporting different types of proofs
        bytes calldata blockProofs
    )
    external
    view
    {
        uint16 verifierId = uint16(bytes2(blockProofs[0:2]));
        // For now, only ZK
        LibVerifyZKP.verifyProof(
            AddressResolver(address(this)),
            blockProofs[2:],
            verifierId
        );
    }
}

contract ProxiedProofVerifier is Proxied, ProofVerifier {}
