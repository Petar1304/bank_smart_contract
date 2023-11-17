// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Bank is  Ownable {

    IERC20 token;

    uint256 R;
    // check if it is cheaper to store T2, T3, T4 separately rather then multiplying each time
    uint256 T;
    uint256 t0;

    uint256 rewardPoolTotal;

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
        bool success = token.transferFrom(owner(), address(this), _rewards);
        require(success, "Error: Initial deposit failed");
        // _splitRewards(_rewards);
    }

    // deposit tokens on deployment
    function deposit(uint256 _amount) external {
        // do the checks
        require(block.timestamp <= t0 + T, "Error: deposit period elapsed");
        // require(token.balanceOf((address(this))) == (totalStake + rewardPoolTotal + _amount), "Error: not enough tokens supplied"); // do it with appoval and transfer from
        // 
        require(token.allowance(msg.sender, address(this)) >= _amount, "Error: amount is bigger then allowance");
        bool success = token.transferFrom(msg.sender, address(this), _amount);
        require(success, "Error: token transfer failed");
        totalStake += _amount;
        staked[msg.sender] += _amount;
        emit Deposit(msg.sender, _amount); 
    }

    function withdraw() external {
        require(block.timestamp >= t0 + 2 * T, "Error: you are not able to withdraw tokens until lock period elapses");
        require(staked[msg.sender] > 0, "Error: no tokens staked");
        uint256 reward = _calculateRewards(msg.sender);

        bool success = token.transferFrom(address(this), msg.sender, staked[msg.sender] + reward);
        require(success, "Error: token transfer failed");
        emit Withdraw(msg.sender, reward + staked[msg.sender]);
    }

    function bankWithdrawal() external onlyOwner {
        // TODO: check this
        require(block.timestamp >= 4*T + t0, "Error: not enough time passed");

        require(R > 0, "Error: no tokens remaining");
        bool success = token.transfer(owner(), R);
        require(success, "Error: token transfer failed");
 
    }

    function _calculateRewards(address _user) internal view returns(uint256) {
        uint256 stakedAmount = staked[_user]; 
        require(stakedAmount > 0, "Error: no tokens staked");

        uint256 ratio = stakedAmount / totalStake; 

        // time checks
        if (block.timestamp < t0 + 3 * T) {
            return ratio * ((R * 20) / 100);
        }
        else if (block.timestamp < t0 + 4 * T) {
            return ratio * (R / 2);
        }
        else if (block.timestamp > t0 + 4 * T) {
            return ratio * R;
        } 
        return 10;
    }
}
