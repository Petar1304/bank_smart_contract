// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ERC20 Bank smart contract for trace labs 
 * @author Petar Kovacevic
 */
contract Bank is  Ownable {

    // global variables
    IERC20 public token;
    uint256 public R1;
    uint256 public R2;
    uint256 public R3;
    uint256 public T;
    uint256 public t0;
    uint256 private totalStake;

    mapping(address => uint256) staked; // mapping addresses to amounts staked (time of the deposit is not imported)

    // Events for deposit and withdrawal
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    constructor(address _token, uint256 _rewards, uint256 _T) Ownable(msg.sender)  {
        token = IERC20(_token);
        t0 = block.timestamp;
        T = _T;
        R1 = (20 * _rewards) / 100;
        R2 = (30 * _rewards) / 100;
        R3 = (50 * _rewards) / 100;
    }

    /**
     * @dev Deposit function used to deposit ERC20 tokens on smart contract
     *      tokens can be deposited only until t0 + T
     * @notice ERC20 token transfer should be approved before calling this function
     * @param _amount uint256 -> amount of tokens deposited
     */
    function deposit(uint256 _amount) external {
        require(block.timestamp <= t0 + T, "Error: deposit period elapsed");
        require(token.allowance(msg.sender, address(this)) >= _amount, "Error: amount is bigger then allowance");

        totalStake += _amount;
        staked[msg.sender] += _amount;

        bool success = token.transferFrom(msg.sender, address(this), _amount);
        require(success, "Error: token transfer failed");

        emit Deposit(msg.sender, _amount); 
    }

    /**
     * @dev Function used to withdraw staked ERC20 tokens from contract as well as rewards which are calculated according to contract specification
     */
    function withdraw() external {
        require(block.timestamp >= t0 + 2 * T, "Error: you are not able to withdraw tokens until lock period elapses");
        require(staked[msg.sender] > 0, "Error: no tokens staked");

        uint256 userStake = staked[msg.sender];
        uint256 reward = _calculateRewards(userStake);

        staked[msg.sender] = 0;
        totalStake -= userStake;

        bool success = token.transfer(msg.sender, userStake + reward);
        require(success, "Error: token transfer failed");

        emit Withdraw(msg.sender, reward + staked[msg.sender]);
    }

    /**
     * @dev Function used by contract owner to withdraw whats left in bank after 4T passed and all staked tokens are withdrawn
     */
    function bankWithdrawal() external onlyOwner {
        require(block.timestamp >= t0 + 4 * T, "Error: not enough time passed");
        require(totalStake == 0, "Error: not all staked tokens are withdrawn");
        require((R1 + R2 + R3) > 0, "Error: no tokens remaining");
        bool success = token.transfer(owner(), R1 + R2 + R3);
        require(success, "Error: token transfer failed");
    }

    /**
     * @dev Internal Function that calculates how much rewards user earned depending on time of the withdrawal
     * @param _staked uint256 -> amount of tokens staked by the user
     */
    function _calculateRewards(uint256 _staked) internal returns(uint256) {
        require(_staked > 0, "Error: no tokens staked");
        uint256 reward;

        if (block.timestamp < t0 + 3 * T) {
            reward = (_staked * R1) / totalStake;
            R1 -= reward;
            return reward;
        }
        else if (block.timestamp >= t0 + 3 * T && block.timestamp < t0 + 4 * T) {
            uint256 rewardR1 = (_staked * R1) / totalStake;
            uint256 rewardR2 = (_staked * R2) / totalStake;
            reward = rewardR1 + rewardR2;
            R1 -= rewardR1;
            R2 -= rewardR2;
            return reward;
        }
        else if (block.timestamp >= t0 + 4 * T) {
            uint256 rewardR1 = (_staked * R1) / totalStake;
            uint256 rewardR2 = (_staked * R2) / totalStake;
            uint256 rewardR3 = (_staked * R3) / totalStake;
            reward = rewardR1 + rewardR2 + rewardR3;
            R1 -= rewardR1;
            R2 -= rewardR2;
            R3 -= rewardR3;
            return reward;
        }
        else {
            return 0;
        }
    }
}
