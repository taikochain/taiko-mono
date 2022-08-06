// SPDX-License-Identifier: MIT
//
// ╭━━━━╮╱╱╭╮╱╱╱╱╱╭╮╱╱╱╱╱╭╮
// ┃╭╮╭╮┃╱╱┃┃╱╱╱╱╱┃┃╱╱╱╱╱┃┃
// ╰╯┃┃┣┻━┳┫┃╭┳━━╮┃┃╱╱╭━━┫╰━┳━━╮
// ╱╱┃┃┃╭╮┣┫╰╯┫╭╮┃┃┃╱╭┫╭╮┃╭╮┃━━┫
// ╱╱┃┃┃╭╮┃┃╭╮┫╰╯┃┃╰━╯┃╭╮┃╰╯┣━━┃
// ╱╱╰╯╰╯╰┻┻╯╰┻━━╯╰━━━┻╯╰┻━━┻━━╯
pragma solidity ^0.8.9;

import "../../common/EssentialContract.sol";
import "./IProtoBroker.sol";

abstract contract ProtoBrokerBase is IProtoBroker, EssentialContract {
    uint256 public unsettledProverFeeThreshold;
    uint256 public unsettledProverFee;
    uint128 internal _suggestedGasPrice;

    uint256[47] private __gap;

    event FeeCharged(
        uint256 indexed blockId,
        address indexed account,
        uint256 amount
    );
    event FeePaid(
        uint256 indexed blockId,
        address indexed account,
        uint256 amount,
        uint256 uncleId
    );

    function chargeProposer(
        uint256 blockId,
        address proposer,
        uint128 gasLimit,
        uint64 numUnprovenBlocks
    ) public virtual override returns (uint128 gasFeeReceived) {
        gasFeeReceived = getProposerGasFee(gasLimit, numUnprovenBlocks);

        require(_chargeFee(proposer, gasFeeReceived), "failed to charge");
        emit FeeCharged(blockId, proposer, gasFeeReceived);
    }

    function payProver(
        uint256 blockId,
        address prover,
        uint256 uncleId,
        uint64 proposedAt,
        uint64 provenAt,
        uint128 gasFeeReceived
    ) public virtual override returns (uint128 gasFeePaid) {
        gasFeePaid = _calculateGasFeePaid(
            gasFeeReceived,
            provenAt - proposedAt
        );

        for (uint256 i = 0; i < uncleId; i++) {
            gasFeePaid /= 2;
        }

        if (gasFeePaid > 0) {
            if (!_payFee(prover, gasFeePaid)) {
                unsettledProverFee += gasFeePaid;
            }

            if (unsettledProverFee > unsettledProverFeeThreshold) {
                if (_payFee(resolve("dao_vault"), unsettledProverFee - 1)) {
                    unsettledProverFee = 1;
                }
            }
        }

        emit FeePaid(blockId, prover, gasFeePaid, uncleId);
    }

    function getProposerGasFee(uint128 gasLimit, uint64 numUnprovenBlocks)
        public
        view
        virtual
        override
        returns (uint128)
    {
        uint128 gasPrice = _getProposerGasPrice(numUnprovenBlocks);
        return _calculateGasFee(gasPrice, gasLimit);
    }

    function gasLimitBase() public pure virtual returns (uint128);

    /// @dev Initializer to be called after being deployed behind a proxy.
    function _init(
        address _addressManager,
        uint256 _unsettledProverFeeThreshold
    ) internal virtual {
        require(_unsettledProverFeeThreshold > 0, "threshold too small");
        EssentialContract._init(_addressManager);
        unsettledProverFeeThreshold = _unsettledProverFeeThreshold;
    }

    function _calculateGasFeePaid(
        uint128 gasFeeReceived,
        uint64 /*provingDelay*/
    ) internal virtual returns (uint128) {
        return gasFeeReceived;
    }

    function _payFee(
        address, /*recipient*/
        uint256 /*amount*/
    )
        internal
        virtual
        returns (
            bool /*success*/
        );

    function _chargeFee(
        address, /*recipient*/
        uint256 /*amount*/
    )
        internal
        virtual
        returns (
            bool /*success*/
        );

    function _getProposerGasPrice(
        uint64 /*numUnprovenBlocks*/
    ) public view virtual returns (uint128);

    function _calculateGasFee(uint128 gasPrice, uint128 gasLimit)
        private
        pure
        returns (uint128)
    {
        return gasPrice * (gasLimit + gasLimitBase());
    }
}
