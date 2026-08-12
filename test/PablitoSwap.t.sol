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

    }


    function test_Constructor() public {

        assertEq(caller.tokenA(), address(tokenA));
        assertEq(caller.tokenB(), address(tokenB));

        address actualPablitoSwap;
        address expectedPablitoSwap;

        actualPablitoSwap = caller.owner();
        expectedPablitoSwap = address(this);

        assertEq(actualPablitoSwap, expectedPablitoSwap);

        address actualPablitoSwapLP;
        address expectedPablitoSwapLP;

        actualPablitoSwapLP = address(caller.lpContract());
        expectedPablitoSwapLP = address(calc);

        assertEq(actualPablitoSwapLP, expectedPablitoSwapLP);

    }


    function test_Integration_AddLiquidity() public {

        vm.startPrank(address(caller));

        deal(address(tokenA), address(caller), amountA);
        deal(address(tokenB), address(caller), amountB);

        IERC20(tokenA).approve(address(calc), amountA);
        IERC20(tokenB).approve(address(calc), amountB);

        caller.addLiquidityToLP(1e18, 1500e6);

        vm.stopPrank();
        
        assertEq(calc.reserveA(), 1e18);
        assertEq(calc.reserveB(), 1500e6);

    }


    function test_Integration_RemoveLiquidity() public {

        vm.startPrank(address(caller));

        deal(address(tokenA), address(caller), amountA);
        deal(address(tokenB), address(caller), amountB);

        IERC20(tokenA).approve(address(calc), amountA);
        IERC20(tokenB).approve(address(calc), amountB);

        caller.addLiquidityToLP(1e18, 1500e6);

        // calc (LP) read userLiquidity state for caller (main)
        uint256 amountLiquidity = calc.userLiquidity(address(caller));
        // result: 38729833462074

        vm.stopPrank();

        assertEq(amountLiquidity, 38729833462074);

        assertEq(amountA, 1e18);
        assertEq(amountB, 1500e6);

    }




}