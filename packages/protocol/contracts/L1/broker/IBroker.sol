// SPDX-License-Identifier: MIT
//
// ╭━━━━╮╱╱╭╮╱╱╱╱╱╭╮╱╱╱╱╱╭╮
// ┃╭╮╭╮┃╱╱┃┃╱╱╱╱╱┃┃╱╱╱╱╱┃┃
// ╰╯┃┃┣┻━┳┫┃╭┳━━╮┃┃╱╱╭━━┫╰━┳━━╮
// ╱╱┃┃┃╭╮┣┫╰╯┫╭╮┃┃┃╱╭┫╭╮┃╭╮┃━━┫
// ╱╱┃┃┃╭╮┃┃╭╮┫╰╯┃┃╰━╯┃╭╮┃╰╯┣━━┃
// ╱╱╰╯╰╯╰┻┻╯╰┻━━╯╰━━━┻╯╰┻━━┻━━╯
pragma solidity ^0.8.9;

/// @author dantaik <dan@taiko.xyz>
interface IBroker {
    function gasLimitBase() external view returns (uint128);

    function currentGasPrice() external view returns (uint128);

    function feeToken() external view returns (address);

    function estimateFee(uint128 gasLimit) external view returns (uint128);

    function chargeProposer(
        uint256 blockId,
        address proposer,
        uint128 gasLimit
    ) external returns (uint128 gasPrice);

    function payProver(
        uint256 blockId,
        uint256 uncleId,
        address prover,
        uint128 gasPriceAtProposal,
        uint128 gasLimit,
        uint64 provingDelay
    ) external;
}
