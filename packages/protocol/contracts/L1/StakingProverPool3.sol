//  _____     _ _         _         _
// |_   _|_ _(_) |_____  | |   __ _| |__ ___
//   | |/ _` | | / / _ \ | |__/ _` | '_ (_-<
//   |_|\__,_|_|_\_\___/ |____\__,_|_.__/__/

pragma solidity ^0.8.20;

import { AddressResolver } from "../common/AddressResolver.sol";
import { EssentialContract } from "../common/EssentialContract.sol";
import { TaikoToken } from "./TaikoToken.sol";
import { Proxied } from "../common/Proxied.sol";

contract ProverPoolImpl is EssentialContract {
    struct Staker {
        uint8 id; // [0-31]
        address prover;
        uint64 exitTs;
        uint32 stakedAmount; // unit is 10^8, this means a max of
        // 429496729500000000 tokens, 2.3283%  of total supply
        uint16 rewardPerGas; // expected rewardPerGas
        uint16 capacity; // maximum capacity (parallel blocks)
    }

    // Then we define a mapping from id => Staker
    mapping(uint8 id => Staker) public stakers;
    // We need an address to id mapping
    mapping(address prover => uint8 id) public proverToId;

    // Keeping track of the 'lowest barrier to entry' by checking who is on the
    // bottom of the top32 list.
    // Top32: Pure staked TKO based !
    uint256 public minimumStake;
    uint8 minimumStakerId;
    uint8 currentIdIdx;

    // Then we use a fixed size byte array to represnet the top 32 provers.
    // For each prover, we only need to keep its stakedAmount, and rewardPerGas,
    // together they takes 32+32=64 bits, or 8 bytes.

    // This is 1/4 slot
    struct Prover {
        uint32 stakedAmount; // this value will change when we slash the prover
        uint16 rewardPerGas;
    }
    // uint16 capacity; // if we add this, we should use a bytes array
    // instead of Prover array below. The capacity must be greater than a
    // threshold.

    Prover[32] public provers; // 32/4 = 8 slots

    uint256 public constant EXIT_PERIOD = 1 weeks;
    uint256 public constant SLASH_AMOUNT_IN_BP = 500; // means 5% if 10_000 is
        // 100%

    uint256[100] private __gap;

    event ProverEntered(
        address prover,
        uint32 stakedAmount,
        uint16 rewardPerGas,
        uint16 capacity
    );

    event ProverStakedMoreTokens(
        address prover, uint32 amount, uint32 totalStaked
    );

    event ProverChangedExpectedReward(address prover, uint16 newReward);

    event ProverAdjustedCapacity(address prover, uint16 newCapacity);

    event ProverExitRequested(address prover, uint64 timestamp);

    event ProverExitRequestReverted(address prover, uint64 timestamp);

    event ProverExited(address prover, uint64 timestamp);

    event ProverSlashed(address prover, uint32 newBalance);

    modifier onlyProtocol() {
        require(
            AddressResolver(this).resolve("taiko", false) != msg.sender,
            "Only Taiko L1 can call this function"
        );
        _;
    }

    modifier onlyProver(address prover) {
        require(
            stakers[proverToId[prover]].prover != address(0),
            "Only provers can call this function"
        );
        _;
    }

    /**
     * Initialize the rollup.
     *
     * @param _addressManager The AddressManager address.
     */
    function init(address _addressManager) external initializer {
        EssentialContract._init(_addressManager);
    }

    // @Daniel's comment: Adjust the staking. Users can use this funciton to
    // stake, re-stake, exit,
    // and change parameters.
    // @Dani: Most prob. not for exit and modify, because it would require extra
    // logic and cases. Let handle
    // modification in a separate function
    function stake(
        uint32 totalAmount,
        uint16 rewardPerGas,
        uint16 capacity
    )
        external
        nonReentrant
    {
        // Cannot enter the pool below the minimum
        require(minimumStake < totalAmount, "Cannot enter below minimum");
        require(rewardPerGas > 0, "Cannot be less than 1");
        // Prover shall always be sender and in case of
        // lending/cooperation/delegate
        // it shall be done off-chain or at least outside of this pool contract.
        address prover = _msgSender();
        // The list of 32 is not full yet so kind of everybody can enter into
        // the pool
        if (_anyEmptyStakingSlots()) {
            stakers[currentIdIdx] = Staker(
                currentIdIdx, prover, 0, totalAmount, rewardPerGas, capacity
            );
            provers[currentIdIdx] = Prover(totalAmount, rewardPerGas);
            proverToId[prover] = currentIdIdx;

            // This would not overflow the 32 because of:
            // provers[31].stakedAmount == 0
            unchecked {
                ++currentIdIdx;
            }

            // If we just filled up the last place in the array (so means full -
            // we can
            // determine which is the staker in risk)
            if (provers[31].stakedAmount != 0) {
                (minimumStakerId, minimumStake) = _determineLowestStaker();
            }
        } else {
            // List is full, we need to check which position we need to put them
            // into
            (minimumStakerId,) = _determineLowestStaker();

            // We need to overwrite it's place
            stakers[minimumStakerId] = Staker(
                minimumStakerId, prover, 0, totalAmount, rewardPerGas, capacity
            );
            provers[minimumStakerId] = Prover(totalAmount, rewardPerGas);
            proverToId[prover] = minimumStakerId;

            // Need to determine again who is the last / lowest staker
            (minimumStakerId, minimumStake) = _determineLowestStaker();
        }

        TaikoToken(AddressResolver(this).resolve("taiko_token", false)).burn(
            prover, totalAmount
        );

        emit ProverEntered(prover, totalAmount, rewardPerGas, capacity);
    }

    // Increases the staked amount (decrease will be with exit())
    function stakeMoreTokens(uint32 amount) external onlyProver(_msgSender()) {
        require(amount > 0, "Must stake a positive amount of tokens");

        provers[proverToId[_msgSender()]].stakedAmount += amount;
        stakers[proverToId[_msgSender()]].stakedAmount += amount;

        // Need to determine again who is the last / lowest staker
        (minimumStakerId, minimumStake) = _determineLowestStaker();

        emit ProverStakedMoreTokens(
            _msgSender(), amount, provers[proverToId[_msgSender()]].stakedAmount
        );
    }

    // Adjusts the expected reward per gas
    function adjustExpectedRewardPerGas(uint16 newRewardPerGas)
        external
        onlyProver(_msgSender())
    {
        require(newRewardPerGas > 0, "Must be above 0");

        provers[proverToId[_msgSender()]].rewardPerGas = newRewardPerGas;
        stakers[proverToId[_msgSender()]].rewardPerGas = newRewardPerGas;

        emit ProverChangedExpectedReward(_msgSender(), newRewardPerGas);
    }

    // Sets new capacity
    function adjustCapacity(uint16 newCapacity)
        external
        onlyProver(_msgSender())
    {
        require(newCapacity > 0, "Must be above 0");

        stakers[proverToId[_msgSender()]].capacity = newCapacity;

        emit ProverAdjustedCapacity(_msgSender(), newCapacity);
    }

    // Can 'toggle' exit status
    function setExitStatus(bool exitRequested)
        external
        onlyProver(_msgSender())
    {
        uint64 timestamp = uint64(block.timestamp);

        if (exitRequested) {
            stakers[proverToId[_msgSender()]].exitTs = timestamp;
            emit ProverExitRequested(_msgSender(), timestamp);
        } else if (
            stakers[proverToId[_msgSender()]].exitTs + EXIT_PERIOD > timestamp
        ) {
            // Only allow to revert the exiting mechanism in case timestamp is
            // within the range
            stakers[proverToId[_msgSender()]].exitTs = 0;
            emit ProverExitRequestReverted(_msgSender(), timestamp);
        }
    }

    function exit() external onlyProver(_msgSender()) {
        require(
            stakers[proverToId[_msgSender()]].exitTs != 0
                && stakers[proverToId[_msgSender()]].exitTs + EXIT_PERIOD
                    < block.timestamp,
            "Cannot yet exit"
        );

        // Reimburse rewards and staked TKO
        TaikoToken(AddressResolver(this).resolve("taiko_token", false)).mint(
            msg.sender, stakers[proverToId[_msgSender()]].stakedAmount
        );

        // Delete mappings and empty staker position in the array
        delete provers[proverToId[_msgSender()]];
        stakers[proverToId[_msgSender()]] =
            Staker(proverToId[_msgSender()], address(0), 0, 0, 0, 0);

        delete proverToId[_msgSender()];

        // Need to determine again who is the last / lowest staker
        (minimumStakerId, minimumStake) = _determineLowestStaker();

        emit ProverExited(_msgSender(), uint64(block.timestamp));
    }

    function slashProver(address prover)
        external
        onlyProtocol
        onlyProver(prover)
    {
        uint32 currentStaked = provers[proverToId[_msgSender()]].stakedAmount;
        uint32 afterSlash = uint32(
            currentStaked * uint256(10_000 - SLASH_AMOUNT_IN_BP) / 10_000
        );

        provers[proverToId[_msgSender()]].stakedAmount = afterSlash;
        stakers[proverToId[_msgSender()]].stakedAmount = afterSlash;

        emit ProverSlashed(prover, afterSlash);
    }

    // A demo how to optimize the getProver by using only 8 slots. It's still
    // a lot of slots tough.
    function getProver(
        uint256 blockId,
        uint32 currentFeePerGas
    )
        external
        returns (address prover, uint32 rewardPerGas)
    {
        // readjust each prover's rate
        uint256[32] memory weights;
        uint256 totalWeight;
        uint8 i;
        for (; i < provers.length; ++i) {
            weights[i] = _calcWeight(i, provers[i], currentFeePerGas);
            if (weights[i] == 0) break;
            totalWeight += weights[i];
        }

        if (totalWeight == 0) {
            return (address(0), 2 * currentFeePerGas);
        }

        // Determine prover idx
        uint256 rand = uint256(blockhash(block.number - 1));
        uint8 proverIdx = _pickRandomProverIdx(weights, totalWeight, rand);

        Staker memory proverData = stakers[proverIdx];

        // If prover's capacity is at it's full, pick another one
        if (stakers[proverIdx].capacity == 0) {
            proverIdx = _pickRandomProverIdx(
                weights,
                totalWeight,
                uint256(
                    keccak256(
                        abi.encodePacked(
                            currentFeePerGas, block.timestamp, rand
                        )
                    )
                )
            );
            proverData = stakers[proverIdx];
        }

        // If second prover's capacity is at full as well, return address(0)
        if (proverData.capacity == 0) {
            return (address(0), 2 * currentFeePerGas);
        }

        // If the reward is 2x then the current average, then cap it
        if (proverData.rewardPerGas * 2 > currentFeePerGas) {
            //Decrease capacity
            stakers[proverIdx].capacity--;
            return (proverData.prover, 2 * currentFeePerGas);
        }

        stakers[proverIdx].capacity--;
        return (proverData.prover, proverData.rewardPerGas);
    }

    // Increases the capacity of the prover
    function releaseResource(address prover) external onlyProtocol {
        if (
            stakers[proverToId[prover]].prover != address(0)
                && stakers[proverToId[prover]].capacity < type(uint16).max
        ) {
            stakers[proverToId[prover]].capacity++;
        }
    }

    // Determine the minimum required TKO to be in the pool
    function lowestStakedAmountToEnter()
        external
        view
        returns (uint32 minStakeRequired)
    {
        (, minStakeRequired) = _determineLowestStaker();

        return (minStakeRequired + 1);
    }

    // The weight is dynamic based on fee per gas.
    function _calcWeight(
        uint8 proverIdx,
        Prover memory prover,
        uint32 currentFeePerGas
    )
        private
        view
        returns (uint256)
    {
        // If staker requested an exit, set his/her weight to 0
        if (stakers[proverIdx].exitTs != 0) {
            return 0;
        }
        // Just a demo that the weight depends on the current fee per gas,
        // the prover's expected fee per gas, as well as the staking amount
        return (
            uint256(prover.stakedAmount) * currentFeePerGas * currentFeePerGas
        ) / prover.rewardPerGas / prover.rewardPerGas;
    }

    // Determine staker with the least amount of token staked
    function _determineLowestStaker()
        private
        view
        returns (uint8 stakerId, uint32 minStake)
    {
        Prover[32] memory mProvers = provers;
        stakerId = 0;
        minStake = mProvers[0].stakedAmount;

        // Find the index to insert the new staker based on their balance
        for (uint8 i = 1; i < mProvers.length; i++) {
            if (mProvers[i].stakedAmount < minStake) {
                stakerId = i;
                minStake = mProvers[i].stakedAmount;
            }
        }
    }

    // Determine if there are any empty staking slots
    function _anyEmptyStakingSlots() private view returns (bool result) {
        // Find the index to insert the new staker based on their balance
        for (uint8 i = 0; i < provers.length; i++) {
            if (provers[i].stakedAmount == 0) {
                return true;
            }
        }
    }

    // Pick a random prover
    function _pickRandomProverIdx(
        uint256[32] memory weights,
        uint256 totalWeight,
        uint256 rand
    )
        private
        pure
        returns (uint8 i)
    {
        uint256 r = rand % totalWeight;
        uint256 z;
        while (z < r && i < 32) {
            z += weights[i++];
        }
    }
}

contract ProxiedStakingProverPool is Proxied, ProverPoolImpl { }
