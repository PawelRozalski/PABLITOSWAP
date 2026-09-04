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


    function test_Fuzz_AddLiquidity_FirstLP(uint256 amountA, uint256 amountB) public {

        amountA = bound(amountA, 1e18, 1000000e18);
        amountB = bound(amountB, 1e6, 1000000e6);

        deal(address(tokenA), address(this), amountA);
        deal(address(tokenB), address(this), amountB);

        IERC20(tokenA).approve(address(calc), amountA);
        IERC20(tokenB).approve(address(calc), amountB);

        calc.addLiquidity(amountA, amountB);

        assertEq(calc.reserveA(), amountA);
        assertEq(calc.reserveB(), amountB);

    }


    function test_Fuzz_AddLiquidity_NextLP(uint256 amountA, uint256 amountB, uint256 amountAA) public {

        amountA = bound(amountA, 1e18, 1000000e18);
        amountB = bound(amountB, 1e6, 1000000e6);

        deal(address(tokenA), address(this), amountA);
        deal(address(tokenB), address(this), amountB);

        IERC20(tokenA).approve(address(calc), amountA);
        IERC20(tokenB).approve(address(calc), amountB);

        calc.addLiquidity(amountA, amountB);

        uint256 reserveA = calc.reserveA();
        uint256 reserveB = calc.reserveB();

        // drawing in the range
        vm.assume(amountAA > 1e18 && amountAA < 1000000e18);
        deal(address(tokenA), address(this), amountAA);
        IERC20(tokenA).approve(address(calc), amountAA);
        
        uint256 amountBB = (amountAA * reserveB + reserveA - 1) / reserveA;
        deal(address(tokenB), address(this), amountBB);
        IERC20(tokenB).approve(address(calc), amountBB);

        calc.addLiquidity(amountAA, amountBB);

        assertEq(calc.reserveA(), reserveA + amountAA);
        assertEq(calc.reserveB(), reserveB + amountBB);

    }


    function test_Fuzz_removeLiquidity_Whole(uint256 amountA, uint256 amountB, uint256 liquidity) public {

        amountA = bound(amountA, 1e18, 1000000e18);
        amountB = bound(amountB, 1e6, 1000000e6);

        deal(address(tokenA), address(this), amountA);
        deal(address(tokenB), address(this), amountB);

        IERC20(tokenA).approve(address(calc), amountA);
        IERC20(tokenB).approve(address(calc), amountB);

        calc.addLiquidity(amountA, amountB);

        vm.startPrank(address(this));

        liquidity = calc.userLiquidity(address(this));

        calc.removeLiquidity(liquidity);

        vm.stopPrank();

        assertEq(calc.userLiquidity(address(this)), 0);
        assertEq(calc.totalLiquidity(), 0);
    
        assertEq(calc.reserveA(), 0);
        assertEq(calc.reserveB(), 0);

    }


    function test_Fuzz_removeLiquidity_Part(uint256 amountA, uint256 amountB, uint256 liquidity) public {

        amountA = bound(amountA, 1e18, 1000000e18);
        amountB = bound(amountB, 1e6, 1000000e6);

        deal(address(tokenA), address(this), amountA);
        deal(address(tokenB), address(this), amountB);

        IERC20(tokenA).approve(address(calc), amountA);
        IERC20(tokenB).approve(address(calc), amountB);

        calc.addLiquidity(amountA, amountB);

        vm.startPrank(address(this));

        uint256 reserveABefore = calc.reserveA();
        uint256 reserveBBefore = calc.reserveB();
        uint256 userLiquidityBefore = calc.userLiquidity(address(this));
        uint256 totalLiquidityBefore = calc.totalLiquidity();

        vm.assume(userLiquidityBefore >= 2);

        liquidity = bound(liquidity, 1, userLiquidityBefore - 1);

        calc.removeLiquidity(liquidity);

        vm.stopPrank();

        assertLt(calc.userLiquidity(address(this)), userLiquidityBefore);
        assertLt(calc.totalLiquidity(), totalLiquidityBefore);
    
        assertLe(calc.reserveA(), reserveABefore);
        assertLe(calc.reserveB(), reserveBBefore);
        
    }



}