SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract PABLITOSWAP {

    address public immutable tokenA;
    address public immutable tokenB;

    constructor (address _tokenA, address _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }
}