// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;


// import test library from Foundry
import "forge-std/Test.sol";
import "../src/PablitoSwapLP.sol"; 


contract PablitoSwapLPTest is Test {

    // contract like a variable for calculate 
    PablitoSwapLP public calc;

        address tokenA;
        address tokenB;


    // SETUP: deploy  
    function setUp() public {

        tokenA = 0x4200000000000000000000000000000000000006;            // Base Sepolia testnet: WETH
        tokenB = 0x036CbD53842c5426634e7929541eC2318f3dCF7e;            // Base Sepolia testnet: USDC

        calc = new PablitoSwapLP(tokenA, tokenB);                       // add data from constructor for tests
        
    }
    

    function test_Constructor_SetsOwner() public {

        address actualOwner;
        address expectedOwner;


        actualOwner = calc.owner();                     // who is owner contract?                   address from this calc.owner variable
        expectedOwner = address(this);                  // implementation contract address?         this contract

        // ASSERT: checking correct of result. The comparison between the owner of the deployed contract PablitoSwapLP and address of deployed contract 
        assertEq(actualOwner, expectedOwner);

    }



}