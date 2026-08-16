// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;


// import test library from Foundry
import "forge-std/Test.sol";

import "../src/PablitoSwapLP.sol";
import "../src/MockERC20.sol";


contract PablitoSwapLPTestFuzz is Test {

    // contract like a variable for calculate 
    PablitoSwapLP public calc;

        uint256 amountA = 1e18;                         // ETH
        uint256 amountB = 1500e6;                       // USDC

        MockERC20 public tokenA;        // fake token A
        MockERC20 public tokenB;        // fake token B





}