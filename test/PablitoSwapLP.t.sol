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


    function test_AddLiquidity_CreateFirstLP() public {

        vm.startPrank(address(this));
        
        calc.addLiquidity(1e18, 1500e6);

        vm.stopPrank();

        // check reserves: from zero to 1 (A) and 1500 (B)
        assertGt(calc.reserveA(), 0);
        assertGt(calc.reserveB(), 0);
        
        // do user take a share tokens?
        assertGt(calc.userLiquidity(address(this)), 0);
        assertGt(calc.totalLiquidity(), 0);

    }


    function test_AddLiquidity_AddSecondLP() public {

        address first = address(0x999);

        vm.startPrank(address(first));

        // taked tokens:
        deal(address(tokenA), address(first), 1e18);
        deal(address(tokenB), address(first), 1500e6);

        // approval tokens:
        IERC20(tokenA).approve(address(calc), 1e18);
        IERC20(tokenB).approve(address(calc), 1500e6);

        calc.addLiquidity(1e18, 1500e6);

        vm.stopPrank();


        address second = address(0x777);

        vm.startPrank(address(second));

        // taked tokens:
        deal(address(tokenA), address(second), 3e18);
        deal(address(tokenB), address(second), 4500e6);

        // approval tokens:
        IERC20(tokenA).approve(address(calc), 3e18);
        IERC20(tokenB).approve(address(calc), 4500e6);

        calc.addLiquidity(3e18, 4500e6);

        vm.stopPrank();

        // check reserves
        assertGt(calc.reserveA(), 3e18);
        assertGt(calc.reserveB(), 5000e6);
        
        // do user take a share tokens?
        assertGt(calc.userLiquidity(address(first)), 0);
        assertGt(calc.userLiquidity(address(second)), 0);

        assertGt(calc.totalLiquidity(), 0);

    }


    // revert for: wrong token ratio
    function test_AddLiquidity_AddSecondLP_Revert() public {

        address first = address(0x999);

        vm.startPrank(address(first));

        // taked tokens:
        deal(address(tokenA), address(first), 1e18);
        deal(address(tokenB), address(first), 1500e6);

        // approval tokens:
        IERC20(tokenA).approve(address(calc), 1e18);
        IERC20(tokenB).approve(address(calc), 1500e6);

        calc.addLiquidity(1e18, 1500e6);

        vm.stopPrank();


        address second = address(0x777);

        vm.startPrank(address(second));

        // taked tokens:
        deal(address(tokenA), address(second), 7e18);
        deal(address(tokenB), address(second), 2500e6);

        // approval tokens:
        IERC20(tokenA).approve(address(calc), 7e18);
        IERC20(tokenB).approve(address(calc), 2500e6);

        vm.expectRevert("Wrong token ratio");

        calc.addLiquidity(7e18, 2500e6);

        vm.stopPrank();

    }


    // token A
    function test_AddLiquidity_RevertWhenAmountAIsZero() public {

        vm.startPrank(address(this));

        vm.expectRevert("Amount must be > 0"); 

        calc.addLiquidity(0, 2000);
    
        vm.stopPrank();

    }


    // token B
    function test_AddLiquidity_RevertWhenAmountBIsZero() public {

        vm.startPrank(address(this));

        vm.expectRevert("Amount must be > 0"); 

        calc.addLiquidity(2000, 0);
    
        vm.stopPrank();

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


    function test_RemoveLiquidity_Part() public {

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


    // incorrect function call for LP = 0, for: require(liquidity > 0)
    function test_RemoveLiquidity_ZeroAmountLP() public {

        vm.startPrank(address(this));

        vm.expectRevert(); 

        calc.removeLiquidity(0);

    }


    // new user with zero LP, for: require(totalLiquidity > 0)
    function test_RemoveLiquidity_YourFirstInteractionNoLP() public {

        address first = address(0x999);

        vm.startPrank(first);

        vm.expectRevert();

        calc.removeLiquidity(100);

    }


    // user can not withdraw more LP, what he have, for: require(liquidity <= userLiquidity[msg.sender])
    function test_RemoveLiquidity_TooMuchWithdrawLP() public {
        
        vm.startPrank(address(this));

        vm.expectRevert();

        calc.removeLiquidity(10000);
        
        vm.stopPrank();

    }


    // correct result for token A valuation, forntend expected Tokena B
    function test_CalculateAmountOut_FromTokenAToTokenB() public {

        vm.startPrank(address(this));

        deal(address(tokenA), address(this), 6e18);
        deal(address(tokenB), address(this), 9000e6);

        IERC20(tokenA).approve(address(calc), 6e18);
        IERC20(tokenB).approve(address(calc), 9000e6);

        // 6 * 9000 = 54000
        calc.addLiquidity(6e18, 9000e6);

        vm.stopPrank();

        uint256 amountIn = 2e18;
        address tokenIn = address(tokenA);

        // how many give token B 
        uint256 expectedB = calc.calculateAmountOut(amountIn, address(tokenA));

        // 54000 / (6+2) = 6750 and 9000 - 6750 = 2250 output is around 2250 USDC before accounting for fee and price impact
        assertGt(expectedB, 2200e6);
        assertLt(expectedB, 2300e6);

    }


    function test_CalculateAmountOut_FromTokenBToTokenA() public {

        vm.startPrank(address(this));

        deal(address(tokenA), address(this), 6e18);
        deal(address(tokenB), address(this), 9000e6);

        IERC20(tokenA).approve(address(calc), 6e18);
        IERC20(tokenB).approve(address(calc), 9000e6);

        // 6 * 9000 = 54000
        calc.addLiquidity(6e18, 9000e6);

        vm.stopPrank();

        uint256 amountIn = 3000e6;
        address tokenIn = address(tokenB);

        // how many give token B 
        uint256 expectedA = calc.calculateAmountOut(amountIn, address(tokenB));

        // 54000 / (6000+3000) = 4,5 and 6 - 4,5 = 1,5; output is around 1.5 ETH before accounting for fee and price impact
        assertGt(expectedA, 1e18);
        assertLt(expectedA, 2e18);

    }


    function test_CalculateAmountOut_HigherAmountOut() public {

        vm.startPrank(address(this));

        deal(address(tokenA), address(this), 6e18);
        deal(address(tokenB), address(this), 9000e6);

        IERC20(tokenA).approve(address(calc), 6e18);
        IERC20(tokenB).approve(address(calc), 9000e6);

        // 6 * 9000 = 54000
        calc.addLiquidity(6e18, 9000e6);

        vm.stopPrank();

        uint256 amountOut1 = calc.calculateAmountOut(1e18, address(tokenA));
        uint256 amountOut2 = calc.calculateAmountOut(2e18, address(tokenA));

        // 54000 / (6+3) = 6000 and 9000 - 6000 = 3000 output is around 3000 USDC before accounting for fee and price impact
        assertGt(amountOut2, amountOut1);

    }



}