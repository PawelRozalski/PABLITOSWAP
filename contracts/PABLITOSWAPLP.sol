SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

using SafeERC20 for IERC20;



contract PABLITOSWAPLP {

    uint256 public reserveA;                    // WETH
    uint256 public reserveB;                    // USDC
    uint256 public fee = 3;                     // 0.3%
    address public pablitoSwap;                 // main contract


    // these variables: are set once in deployment and can't be changed
    constructor (address _tokenA, address _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        pablitoSwap = msg.sender;
    }
}