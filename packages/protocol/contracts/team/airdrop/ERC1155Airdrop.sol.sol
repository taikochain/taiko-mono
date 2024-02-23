// SPDX-License-Identifier: MIT
//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/
//
//   Email: security@taiko.xyz
//   Website: https://taiko.xyz
//   GitHub: https://github.com/taikoxyz
//   Discord: https://discord.gg/taikoxyz
//   Twitter: https://twitter.com/taikoxyz
//   Blog: https://mirror.xyz/labs.taiko.eth
//   Youtube: https://www.youtube.com/@taikoxyz

pragma solidity 0.8.24;

import { IERC1155 } from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "./MerkleClaimable.sol";

/// @title ERC1155Airdrop
contract ERC1155Airdrop is MerkleClaimable {
    address public token;
    address public vault;
    uint256 public quantity;
    uint256[48] private __gap;

    function init(
        uint64 _claimStart,
        uint64 _claimEnd,
        bytes32 _merkleRoot,
        address _token,
        address _vault,
        uint256 _quantity
    )
        external
        initializer
    {
        __Essential_init();
        __MerkleClaimable_init(_claimStart, _claimEnd, _merkleRoot);

        token = _token;
        vault = _vault;
        quantity = _quantity;
    }

    function claim(
        address user,
        uint256[] calldata tokenIds,
        bytes32[] calldata proof,
        bytes calldata data
    )
        external
        nonReentrant
    {
        // Check if this can be claimed
        _verifyClaim(abi.encode(user, tokenIds), proof);

        // Transfer the tokens
        for (uint256 i; i < tokenIds.length; ++i) {
            IERC1155(token).safeTransferFrom(vault, user, tokenIds[i], quantity, data);
        }
    }
}
