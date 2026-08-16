// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;


// import test library from Foundry
import "forge-std/Test.sol";

import "../src/PablitoSwapLP.sol";
import "../src/MockERC20.sol";


contract PablitoSwapLPTestFuzz is Test {

    // contract like a variable for calculate 
    PablitoSwapLP public calc;

        MockERC20 public tokenA;        // fake token A
        MockERC20 public tokenB;        // fake token B


    // SETUP: deploy  
    function setUp() public {

        tokenA = new MockERC20();       // create fake token A
        tokenB = new MockERC20();       // create fake token B

        MockERC20(tokenA).mint(address(this), 1e18);        // new token mint for 1 value with e18 for ETH simulation
        MockERC20(tokenB).mint(address(this), 1500e6);      // new token mint for 1500 value with e6 for USDC simulation

        calc = new PablitoSwapLP(address(tokenA), address(tokenB));                      // add data from constructor for tests

    }


    function test_Fuzz_AddLiquidity(uint256 amountA, uint256 amountB) public {

        vm.assume(amountA > 1000e6 && amountA < 1000000e18);
        vm.assume(amountB > 1000e6 && amountB < 1000000e18);

        deal(address(tokenA), address(this), amountA);
        deal(address(tokenB), address(this), amountB);

        IERC20(tokenA).approve(address(calc), amountA);
        IERC20(tokenB).approve(address(calc), amountB);

        uint256 generatedLP = calc.addLiquidity(amountA, amountB);

        assertGt(generatedLP, 0);
        assertEq(calc.reserveA(), amountA);
        assertEq(calc.reserveB(), amountB);

    }


}