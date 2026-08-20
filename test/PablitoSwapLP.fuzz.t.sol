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

        // drawing in the range
        vm.assume(amountA > 1e18 && amountA < 1000000e18);
        vm.assume(amountB > 1e6 && amountB < 1000000e6);

        deal(address(tokenA), address(this), amountA);
        deal(address(tokenB), address(this), amountB);

        IERC20(tokenA).approve(address(calc), amountA);
        IERC20(tokenB).approve(address(calc), amountB);

        calc.addLiquidity(amountA, amountB);

        assertEq(calc.reserveA(), amountA);
        assertEq(calc.reserveB(), amountB);

    }


    function test_Fuzz_AddLiquidity_NextLP(uint256 amountA, uint256 amountB, uint256 amountAA) public {

        // drawing in the range
        vm.assume(amountA > 1e18 && amountA < 1000000e18);
        vm.assume(amountB > 1e6 && amountB < 1000000e6);

        deal(address(tokenA), address(this), amountA);
        deal(address(tokenB), address(this), amountB);

        IERC20(tokenA).approve(address(calc), amountA);
        IERC20(tokenB).approve(address(calc), amountB);

        calc.addLiquidity(amountA, amountB);

        uint256 reserveA = calc.reserveA();
        uint256 reserveB = calc.reserveB();

        console.log("reserveA:", reserveA);
        console.log("reserveB:", reserveB);

        // drawing in the range
        vm.assume(amountAA > 1e18 && amountAA < 1000000e18);
        deal(address(tokenA), address(this), amountAA);
        IERC20(tokenA).approve(address(calc), amountAA);
        
        uint256 amountBB = (amountAA * reserveB + reserveA - 1) / reserveA;
        deal(address(tokenB), address(this), amountBB);
        IERC20(tokenB).approve(address(calc), amountBB);

        console.log("amountAA:", amountAA);
        console.log("amountBB:", amountBB);

        calc.addLiquidity(amountAA, amountBB);

        assertEq(calc.reserveA(), reserveA + amountAA);
        assertEq(calc.reserveB(), reserveB + amountBB);

    }


}