// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;



import "forge-std/Test.sol";
// import Foundry's invariant testing utilities
import "forge-std/StdInvariant.sol";

import "../src/PablitoSwapLP.sol";
import "../src/MockERC20.sol";
import "./PablitoSwapLPHandler.sol";



// StdInvariant > its mechanics indicates which contracts go to invariant testing
contract PablitoSwapLPInvariantTest is StdInvariant, Test {


    function setUp() public {

        tokenA = new MockERC20();       // create fake token A
        tokenB = new MockERC20();       // create fake token B

        calc = new PablitoSwapLP(address(tokenA), address(tokenB));                      // add data from constructor for tests

    }





}