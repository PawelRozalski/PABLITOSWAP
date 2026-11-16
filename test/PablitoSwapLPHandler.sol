// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;


// import test library from Foundry
import "forge-std/Test.sol";

import "../src/PablitoSwapLP.sol";
import "../src/MockERC20.sol";


contract PablitoSwapLPHandler is Test {

    PablitoSwapLP public calc;
    
    MockERC20 public tokenA;
    MockERC20 public tokenB;

    address public Degen1 = address(0x1);
    address public Degen2 = address(0x2);
    address public Degen3 = address(0x3);
    address public Degen4 = address(0x4);


    constructor (PablitoSwapLP _calc, MockERC20 _tokenA, MockERC20 _tokenB) {

        calc = _calc;

        tokenA = _tokenA;
        tokenB = _tokenB;

    }


    function addLiquidity_Degen1(uint256 amountA, uint256 amountB) public {

        amountA = bound(amountA, 1e18, 1000000e18);
        amountB = bound(amountB, 1e6, 1000000e6);

        tokenA.mint(Degen1, amountA);
        tokenB.mint(Degen1, amountB);

        vm.startPrank(address(Degen1));

        // who can download tokens
        tokenA.approve(address(calc), amountA);
        tokenB.approve(address(calc), amountB);

        calc.addLiquidity(amountA, amountB);

        vm.stopPrank();

    }


    function swap (address tokenIn, uint256 amountIn, uint256 amountA, uint256 amountB, uint256 actorSeed) public { address[4] memory actors = [Degen1, Degen2, Degen3, Degen4];

        address actor = actors[bound(actorSeed, 0, 3)];

        MockERC20 tokenOut;
        uint256 reserveA;
        uint256 reserveB;
        uint256 reserveIn;
        uint256 reserveOut;



        if (tokenIn != address(tokenA) && tokenIn != address(tokenB)) return;



        amountA = bound(amountA, 1e18, 1000000e18);
        amountB = bound(amountB, 1e6, 1000000e6);

        tokenA.mint(actor, amountA);
        tokenB.mint(actor, amountB);


        vm.startPrank(actor);

        tokenA.approve(address(calc), amountA);
        tokenB.approve(address(calc), amountB);

        calc.addLiquidity(amountA, amountB);

        reserveA = calc.reserveA();
        reserveB = calc.reserveB();

        vm.stopPrank();


        // direction swap
        if (tokenIn == address(tokenA)) {
            tokenOut = tokenB;
            amountIn = bound(amountIn, 1e18, 1000000e18);
            reserveIn = reserveA;
            reserveOut = reserveB;
        } else {
            tokenOut = tokenA;
            amountIn = bound(amountIn, 1e6, 1000000e6);
            reserveIn = reserveB;
            reserveOut = reserveA;
        }

        if (tokenIn == address(tokenA)) {
            tokenA.mint(actor, amountIn);
        } else {
            tokenB.mint(actor, amountIn);
        }

        uint256 amountWithoutFee = amountIn * (1000 - 3) / 1000;
        uint256 amountOut = (amountWithoutFee * reserveOut) / (reserveIn + amountWithoutFee);


        if (amountOut == 0) return;


        vm.startPrank(actor);

        IERC20(tokenIn).approve(address(calc), amountIn);

        calc.swap(tokenIn, amountIn, amountOut);

        vm.stopPrank();

    }




}