// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
// import "hardhat/console.sol";


contract Bank {

    struct Token {
        address tokenAddress;
    }

    mapping(address => Token) tokens;
    mapping(address => uint256) times;

    constructor() {

    }


}
