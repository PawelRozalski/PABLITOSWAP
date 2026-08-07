// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;


// import test library from Foundry
import "forge-std/Test.sol";

import "../src/PablitoSwap.sol";
import "../src/MockERC20.sol";


contract PablitoSwapTest is Test {

    // contract like a variable for calculate 
    PablitoSwap public caller;
    PablitoSwapLP public calc;

        uint256 amountA = 1e18;                         // ETH
        uint256 amountB = 1500e6;                       // USDC

        MockERC20 public tokenA;        // fake token A
        MockERC20 public tokenB;        // fake token B


    // SETUP: deploy  
    function setUp() public {

        tokenA = new MockERC20();       // create fake token A
        tokenB = new MockERC20();       // create fake token B

        calc = new PablitoSwapLP(address(tokenA), address(tokenB));                                     // add data from constructor for tests

        caller = new PablitoSwap(address(tokenA), address(tokenB), address(calc));                      // add data from constructor for tests

        // taked tokens:
        deal(address(tokenA), address(this), amountA);
        deal(address(tokenB), address(this), amountB);

        // approval tokens:
        IERC20(tokenA).approve(address(caller), amountA);
        IERC20(tokenB).approve(address(caller), amountB);

    }



}