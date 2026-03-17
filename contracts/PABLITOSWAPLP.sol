SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract PABLITOSWAPLP {


    struct User {
        uint256 amount_tokenA;
        uint256 amount_tokenB;
        uint256 reward_liquidity;
    }

    mapping(address => uint256) public liquidity_pool;


}