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






}