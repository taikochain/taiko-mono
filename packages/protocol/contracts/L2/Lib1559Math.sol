// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "../thirdparty/solmate/LibFixedPointMath.sol";
import "../libs/LibMath.sol";

/// @title Lib1559Math
/// @notice Implements e^(x) based bonding curve for EIP-1559
/// @dev See https://ethresear.ch/t/make-eip-1559-more-like-an-amm-curve/9082 but some minor
/// difference as stated in docs/eip1559_on_l2.md.
/// @custom:security-contact security@taiko.xyz
library Lib1559Math {
    using LibMath for uint256;

    error EIP1559_INVALID_PARAMS();

    function calc1559BaseFee(
        uint256 _gasTarget,
        uint64 _gasExcess,
        uint64 _gasIssuance,
        uint32 _parentGasUsed
    )
        internal
        pure
        returns (uint256 basefee_, uint64 gasExcess_)
    {
        // We always add the gas used by parent block to the gas excess
        // value as this has already happened
        uint256 excess = uint256(_gasExcess) + _parentGasUsed;
        excess = excess > _gasIssuance ? excess - _gasIssuance : 1;
        gasExcess_ = uint64(excess.min(type(uint64).max));

        // The base fee per gas used by this block is the spot price at the
        // bonding curve, regardless the actual amount of gas used by this
        // block, however, this block's gas used will affect the next
        // block's base fee.
        basefee_ = basefee(gasExcess_, _gasTarget);
    }

    /// @dev Returns the new gas excess that will keep the basefee the same.
    /// `_newGasTarget * ln(_newGasTarget / _target) + _gasExcess * _newGasTarget / _target`
    function adjustExcess(
        uint64 _gasExcess,
        uint64 _gasTarget,
        uint64 _newGasTarget
    )
        internal
        pure
        returns (uint64)
    {
        if (_gasTarget == 0) revert EIP1559_INVALID_PARAMS();

        uint256 f = LibFixedPointMath.SCALING_FACTOR;
        uint256 ratio = f * _newGasTarget / _gasTarget;
        if (ratio > uint256(type(int256).max)) revert EIP1559_INVALID_PARAMS();

        int256 lnRatio = LibFixedPointMath.ln(int256(ratio)); // may be negative

        uint256 newGasExcess;
        assembly {
            newGasExcess := sdiv(add(mul(lnRatio, _newGasTarget), mul(ratio, _gasExcess)), f)
        }

        return uint64(newGasExcess.min(type(uint64).max));
    }

    /// @dev exp(_gasExcess / _gasTarget) / _gasTarget
    function basefee(uint256 _gasExcess, uint256 _gasTarget) internal pure returns (uint256) {
        uint256 fee = ethQty(_gasExcess, _gasTarget) / _gasTarget;
        return fee == 0 ? 1 : fee;
    }

    /// @dev exp(_gasExcess / _gasTarget)
    function ethQty(uint256 _gasExcess, uint256 _gasTarget) internal pure returns (uint256) {
        if (_gasTarget == 0) revert EIP1559_INVALID_PARAMS();

        uint256 input = LibFixedPointMath.SCALING_FACTOR * _gasExcess / _gasTarget;
        if (input > LibFixedPointMath.MAX_EXP_INPUT) {
            input = LibFixedPointMath.MAX_EXP_INPUT;
        }
        return uint256(LibFixedPointMath.exp(int256(input))) / LibFixedPointMath.SCALING_FACTOR;
    }
}
