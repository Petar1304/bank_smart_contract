// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

contract Bank is  Ownable {

    IERC20 token;

    uint256 R;
    uint256 public R1;
    uint256 public R2;
    uint256 public R3;
    // check if it is cheaper to store T2, T3, T4 separately rather then multiplying each time
    uint256 T;
    uint256 t0;

    // uint256 rewardPoolTotal;

    uint256 totalStake;

    mapping(address => uint256) staked; // mapping addresses to amounts staked (time of the deposit is not imported)

    // Events for deposit and withdrawal
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    // TODO: fix approval mechanism
    constructor(address _token, uint256 _rewards, uint256 _T) Ownable(msg.sender)  {
        // require(msg.value > 0, "Error: No Tokens deposited")
        token = IERC20(_token);
        t0 = block.timestamp;
        T = _T;
        R = _rewards;
        _splitRewards(_rewards);
        // bool success = token.transferFrom(owner(), address(this), _rewards);
        // require(success, "Error: Initial deposit failed");
    }

    // deposit tokens on deployment
    function deposit(uint256 _amount) external {
        // do the checks
        require(block.timestamp <= t0 + T, "Error: deposit period elapsed");
        // require(token.balanceOf((address(this))) == (totalStake + rewardPoolTotal + _amount), "Error: not enough tokens supplied"); // do it with appoval and transfer from
        require(token.allowance(msg.sender, address(this)) >= _amount, "Error: amount is bigger then allowance");

        totalStake += _amount;
        staked[msg.sender] += _amount;

        bool success = token.transferFrom(msg.sender, address(this), _amount);
        require(success, "Error: token transfer failed");

        emit Deposit(msg.sender, _amount); 
    }

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

    // TODO: fix this
    function bankWithdrawal() external onlyOwner {
        require(block.timestamp >= 4*T + t0, "Error: not enough time passed");
        require(totalStake == 0, "Error: not all staked tokens are withdrawn");

        require((R1 + R2 + R3) > 0, "Error: no tokens remaining");
        bool success = token.transfer(owner(), R1 + R2 + R3);
        require(success, "Error: token transfer failed");
    }

    function _calculateRewards(uint256 _staked) internal returns(uint256) {
        require(_staked > 0, "Error: no tokens staked");
        uint256 reward;

        // time checks
        if (block.timestamp < t0 + 3 * T) {
            reward = (_staked * R1) / totalStake;
            R -= reward;
            R1 -= reward;
            return reward;
        }
        else if (block.timestamp >= t0 + 3 * T && block.timestamp < t0 + 4 * T) {
            uint256 rewardR1 = (_staked * R1) / totalStake;
            uint256 rewardR2 = (_staked * R2) / totalStake;
            reward = rewardR1 + rewardR2;
            R1 -= rewardR1;
            R2 -= rewardR2;
            R -= reward;
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
            R -= reward;
            return reward;
        }
        else {
            return 0;
        }
    }

    // try this without separate function and measure gas
    function _splitRewards(uint256 _rewards) internal {
        R1 = (20 * _rewards) / 100;
        R2 = (30 * _rewards) / 100;
        R3 = (50 * _rewards) / 100;
    }
}
