// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Bank is  Ownable {

    IERC20 token;

    uint256 R1;
    uint256 R2;
    uint256 R3;
    uint256 T;
    uint256 t0;

    uint256 rewardPoolTotal;

    uint256 totalStake;

    struct StakedToken {
        // IERC20 token;
        uint256 amount;
        uint256 timestamp;
    } 

    mapping(address => StakedToken) staked;

    constructor(address _token, uint256 _rewards, uint256 _T) Ownable(msg.sender)  {
        // require(msg.value > 0, "Error: No Tokens deposited")
        t0 = block.timestamp;
        T = _T;
        rewardPoolTotal = _rewards;
        _splitRewards(_rewards);
    }

    // deposit tokens on deployment
    function deposit() external {
        // do the checks
        // require(token.balanceOf((address(this))) == (totalStake + rewardPoolTotal + _amount), "Error: not enough tokens supplied"); // do it with appoval and transfer from
        // 
        require(token.allowance(msg.sender, address(this)) >= _amount, "Error: amount is bigger then allowance");
        bool success = token.transferFrom(msg.sender, address(this), _amount);
        require(success, "Error: token transfer failed");
        totalStake += _amountl
        StakedToken memory deposited = StakedToken(amount, block.timestamp);
        staked[msg.sender] = deposited;
        
    }

    function withdraw() external {
        require(staked[msg.sender].amount > 0, "Error: no tokens staked");
        uint256 reward = _calculateRewards(msg.sender);
        bool success = token.transferFrom(address(this), msg.sender, reward);
        require(success, "Error: token transfer failed");
 
    }

    function _splitRewards(uint256 _rewards) internal {
        require(_rewards > 0, "Error: no rewards deposited");
        R1 = (_rewards * 20) / 100;
        R2 = (_rewards * 30) / 100;
        R3 = (_rewards * 50) / 100;
    }

    function _calculateRewards(address _user) internal {
        StakedToken storage _stake = staked[address];
        require(_stake.amount > 0, "Error: no tokens staked");


    }
}
