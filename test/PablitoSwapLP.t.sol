// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;


// import test library from Foundry
import "forge-std/Test.sol";

import "../src/PablitoSwapLP.sol";
import "../src/MockERC20.sol";


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

        address actualPablitoSwap;
        address expectedPablitoSwap;


        actualPablitoSwap = calc.pablitoSwap();                     // who is owner contract?                   address from this calc.owner variable
        expectedPablitoSwap = address(this);                        // implementation contract address?         this contract

        // ASSERT: checking correct of result. The comparison between the owner of the deployed contract PablitoSwapLP and address of deployed contract 
        assertEq(actualPablitoSwap, expectedPablitoSwap);

    }


    function test_Constructor_tokens() public {

        address actualTokenA;
        address expectedTokenA;
        address actualTokenB;
        address expectedTokenB;


        actualTokenA = calc.tokenA();
        expectedTokenA = tokenA;

        assertEq(actualTokenA, expectedTokenA);


        actualTokenB = calc.tokenB();
        expectedTokenB = tokenB;

        assertEq(actualTokenB, expectedTokenB);

    }


    function test_InitialState() public {
        
        uint256 actualTotalLiquidity;
        uint256 expectedTotalLiquidity;
        uint256 actualReserveA;
        uint256 expectedReserveA;
        uint256 actualReserveB;
        uint256 expectedReserveB;
        uint256 actualFee;
        uint256 expectedFee;


        actualTotalLiquidity = calc.totalLiquidity();
        expectedTotalLiquidity = 0;

        assertEq(actualTotalLiquidity, expectedTotalLiquidity);

        actualReserveA = calc.reserveA();
        expectedReserveA = 0;

        assertEq(actualReserveA, expectedReserveA);

        actualReserveB = calc.reserveB();
        expectedReserveB = 0;

        assertEq(actualReserveB, expectedReserveB);

        actualFee = calc.fee();
        expectedFee = 3;

        assertEq(actualFee, expectedFee);
        
    }


    // Whether states changed after LP add: 
    function test_AddLiquidity() public {

        uint256 amountA = 1e18;                         // ETH
        uint256 amountB = 1500e6;                       // USDC

        // taked tokens:
        deal(tokenA, address(this), amountA);
        deal(tokenB, address(this), amountB);

        // start like a user:
        vm.startPrank(address(this));

        // approval tokens:
        IERC20(tokenA).approve(address(calc), amountA);
        IERC20(tokenB).approve(address(calc), amountB);

        // stop like a user:
        vm.stopPrank();

        calc.addLiquidity(amountA, amountB);

        // did something come up in userLiquidity and totalLiquidity?
        assertGt(calc.userLiquidity(address(this)), 0);
        assertGt(calc.totalLiquidity(), 0);

        // did come up exactly how I deposit?
        assertEq(calc.reserveA(), amountA);
        assertEq(calc.reserveB(), amountB);

    }




}