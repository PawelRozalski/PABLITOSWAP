SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

using SafeERC20 for IERC20;



contract PABLITOSWAPLP {

    uint256 public reserveA;                    // WETH
    uint256 public reserveB;                    // USDC
    uint256 public fee = 3;                     // 0.3%


}