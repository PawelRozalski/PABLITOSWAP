// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;


// import test library from Foundry
import "forge-std/Test.sol";

import "../src/PablitoSwapLP.sol";
import "../src/MockERC20.sol";


contract PablitoSwapLPTest is Test {

    // contract like a variable for calculate 
    PablitoSwapLP public calc;

        uint256 amountA = 1e18;                         // ETH
        uint256 amountB = 1500e6;                       // USDC

        MockERC20 public tokenA;        // fake token A
        MockERC20 public tokenB;        // fake token B


    // SETUP: deploy  
    function setUp() public {

        tokenA = new MockERC20();       // create fake token A
        tokenB = new MockERC20();       // create fake token B

        MockERC20(tokenA).mint(address(this), 1e18);        // new token mint for 1 value with e18 for ETH simulation
        MockERC20(tokenB).mint(address(this), 1500e6);      // new token mint for 1500 value with e6 for USDC simulation

        calc = new PablitoSwapLP(address(tokenA), address(tokenB));                      // add data from constructor for tests

        // taked tokens:
        deal(address(tokenA), address(this), amountA);
        deal(address(tokenB), address(this), amountB);

        // approval tokens:
        IERC20(tokenA).approve(address(calc), amountA);
        IERC20(tokenB).approve(address(calc), amountB);

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
        expectedTokenA = address(tokenA);

        assertEq(actualTokenA, expectedTokenA);


        actualTokenB = calc.tokenB();
        expectedTokenB = address(tokenB);

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

        // start like a user:
        vm.startPrank(address(this));

        calc.addLiquidity(amountA, amountB);

        // stop like a user:
        vm.stopPrank();

        // did something come up in userLiquidity and totalLiquidity?
        assertGt(calc.userLiquidity(address(this)), 0);
        assertGt(calc.totalLiquidity(), 0);

        // did come up exactly how I deposit?
        assertEq(calc.reserveA(), amountA);
        assertEq(calc.reserveB(), amountB);

    }


    function test_AddLiquidity_Revert() public {

        // uint256 amountA = 1;
        // uint256 amountB = 1500;

        calc.addLiquidity(amountA, amountB);

        uint256 amountAA = 1;
        uint256 amountBB = 6000;

        // taked tokens A and B with amount AA and BB:
        deal(address(tokenA), address(this), amountAA);
        deal(address(tokenB), address(this), amountBB);

        // approval tokens A and B with amount AA and BB:
        IERC20(tokenA).approve(address(calc), amountAA);
        IERC20(tokenB).approve(address(calc), amountBB);

        vm.expectRevert("Wrong token ratio");
        calc.addLiquidity(amountAA, amountBB);

    }


    function test_RemoveLiquidity() public {

        // Add LP:
        vm.startPrank(address(this));

        calc.addLiquidity(amountA, amountB);

        vm.stopPrank();

        // did something come up in userLiquidity and totalLiquidity?
        assertGt(calc.userLiquidity(address(this)), 0);
        assertGt(calc.totalLiquidity(), 0);

        // did come up exactly how I deposit?
        assertEq(calc.reserveA(), amountA);
        assertEq(calc.reserveB(), amountB);

        // Remove LP:
        uint256 liquidity = calc.userLiquidity(address(this));

        vm.startPrank(address(this));

        calc.removeLiquidity(liquidity);

        vm.stopPrank();

        assertEq(calc.userLiquidity(address(this)), 0);
        assertEq(calc.totalLiquidity(), 0);
        assertEq(calc.reserveA(), 0);
        assertEq(calc.reserveB(), 0);

    }


    function test_RemoveLiquidityPart() public {

        // Add LP:
        vm.startPrank(address(this));

        calc.addLiquidity(amountA, amountB);

        vm.stopPrank();

        // did something come up in userLiquidity and totalLiquidity?
        assertGt(calc.userLiquidity(address(this)), 0);
        assertGt(calc.totalLiquidity(), 0);

        // did come up exactly how I deposit?
        assertEq(calc.reserveA(), amountA);
        assertEq(calc.reserveB(), amountB);


        // Remove LP:
        // save state:
        uint256 liquidityBefore = calc.userLiquidity(address(this));
        uint256 totalLiquidityBefore = calc.totalLiquidity();

        // remove 75%:
        uint256 liquidity = liquidityBefore * 75 / 100;

        // remove 75% > expected still 25%:
        uint256 expectedReserveA = amountA * 25 / 100;
        uint256 expectedReserveB = amountB * 25 / 100;

        vm.startPrank(address(this));

        calc.removeLiquidity(liquidity);

        vm.stopPrank();

        assertLt(calc.userLiquidity(address(this)), liquidityBefore);
        // allow rounding error:
        assertApproxEqRel(calc.totalLiquidity(), totalLiquidityBefore - liquidity, 1e16);
        assertLt(calc.reserveA(), amountA);
        assertLt(calc.reserveB(), amountB);

    }


}