// SPDX-License-Identifier: MIT
//
// ╭━━━━╮╱╱╭╮╱╱╱╱╱╭╮╱╱╱╱╱╭╮
// ┃╭╮╭╮┃╱╱┃┃╱╱╱╱╱┃┃╱╱╱╱╱┃┃
// ╰╯┃┃┣┻━┳┫┃╭┳━━╮┃┃╱╱╭━━┫╰━┳━━╮
// ╱╱┃┃┃╭╮┣┫╰╯┫╭╮┃┃┃╱╭┫╭╮┃╭╮┃━━┫
// ╱╱┃┃┃╭╮┃┃╭╮┫╰╯┃┃╰━╯┃╭╮┃╰╯┣━━┃
// ╱╱╰╯╰╯╰┻┻╯╰┻━━╯╰━━━┻╯╰┻━━┻━━╯
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/utils/math/SafeCastUpgradeable.sol";

import "../common/EssentialContract.sol";
import "../libs/LibMath.sol";
import "../thirdparty/ERC20Upgradeable.sol";
import "./IBroker.sol";

abstract contract AbstractBroker is IBroker, EssentialContract {
    using SafeCastUpgradeable for uint256;

    uint256 public constant BLOCK_GAS_LIMIT_EXTRA = 1000000; // TODO
    uint256 public constant ETH_TRANSFER_GAS_LIMIT = 25000;
    uint256 unsettledProverFeeThreshold;
    uint256 unsettledProverFee;
    uint256 gasPriceNow;

    event FeeTransacted(
        uint256 indexed blockId,
        address indexed account,
        uint256 amount,
        bool inbound
    );

    /// @dev Initializer to be called after being deployed behind a proxy.
    function _init(
        address _addressManager,
        uint256 _gasPriceNow,
        uint256 _unsettledProverFeeThreshold
    ) internal initializer {
        require(_unsettledProverFeeThreshold > 0, "threshold too small");
        EssentialContract._init(_addressManager);
        gasPriceNow = _gasPriceNow;
        unsettledProverFeeThreshold = _unsettledProverFeeThreshold;
    }

    function currentGasPrice() public view override returns (uint256) {
        return gasPriceNow;
    }

    function estimateFee(uint256 gasLimit)
        public
        view
        override
        returns (uint256)
    {
        return gasPriceNow * (gasLimit + BLOCK_GAS_LIMIT_EXTRA);
    }

    function chargeProposer(
        uint256 blockId,
        address proposer,
        uint256 gasLimit
    ) external override onlyFromNamed("taiko") {
        uint256 fee = estimateFee(gasLimit);
        require(charge(proposer, fee), "failed to charge");
        emit FeeTransacted(blockId, proposer, fee, false);
    }

    function payProver(
        uint256 blockId,
        address prover,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 provingDelay,
        uint256 uncleId
    ) external override onlyFromNamed("taiko") {
        uint256 prepaid = gasPrice * (gasLimit + BLOCK_GAS_LIMIT_EXTRA);
        uint256 fee;

        if (fee > 0) {
            if (!pay(prover, fee)) {
                unsettledProverFee += fee;
            }
        }

        if (unsettledProverFee > unsettledProverFeeThreshold) {
            if (pay(resolve("dao_vault"), unsettledProverFee - 1)) {
                unsettledProverFee = 1;
            }
        }

        emit FeeTransacted(blockId, prover, fee, false);
    }

    function pay(address recipient, uint256 amount)
        internal
        virtual
        returns (bool success);

    function charge(address recipient, uint256 amount)
        internal
        virtual
        returns (bool success);
}

// IMintableERC20(resolve("tai_token")).mint(
//     resolve("dao_vault"),
//     daoReward
// );
