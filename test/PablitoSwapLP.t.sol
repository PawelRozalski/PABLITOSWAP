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

        // how many give token B 
        uint256 expectedB = calc.calculateAmountOut(amountIn, address(tokenA));

        // amountWithoutFee = 2 * 997 / 1000 = 1.994 ETH
        // amountOut = (1.994 * 9000) / (6 + 1.994) = 2244.93 USDC
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

        // how many give token B 
        uint256 expectedA = calc.calculateAmountOut(amountIn, address(tokenB));

        // amountWithoutFee = 3000 * 997 / 1000 = 2991 USDC
        // amountOut = (2991 * 6) / (9000 + 2991) = 1.4969 ETH
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

        // Higher input amount should result in higher output amount
        // Both calculations include fee and price impact from AMM formula
        assertGt(amountOut2, amountOut1);

    }


    function test_CalculateAmountOut_AddedFee() public {

        vm.startPrank(address(this));

        deal(address(tokenA), address(this), 6e18);
        deal(address(tokenB), address(this), 9000e6);

        IERC20(tokenA).approve(address(calc), 6e18);
        IERC20(tokenB).approve(address(calc), 9000e6);

        // 6 * 9000 = 54000
        calc.addLiquidity(6e18, 9000e6);

        vm.stopPrank();

        uint256 amountOut = calc.calculateAmountOut(2e18, address(tokenA));

        // amountWithoutFee = 2 * 997 / 1000 = 1.994 ETH
        // amountOut = (1.994 * 9000) / (6 + 1.994) = 2244.93 USDC
        assertGt(amountOut, 2243e6);
        assertLt(amountOut, 2245e6);

    }


    function test_CalculateAmountOut_ReturnsZeroAmountOut() public {

        vm.startPrank(address(this));

        deal(address(tokenA), address(this), 6e18);
        deal(address(tokenB), address(this), 9000e6);

        IERC20(tokenA).approve(address(calc), 6e18);
        IERC20(tokenB).approve(address(calc), 9000e6);

        // 6 * 9000 = 54000
        calc.addLiquidity(6e18, 9000e6);

        vm.stopPrank();

        uint256 amountOut = calc.calculateAmountOut(0e18, address(tokenA));

        // taked zero tokens A and give for user zero tokens B 
        assertEq(amountOut, 0);

    }


    function test_CalculateAmountOut_ZeroReservesZeroAmountOut() public {

        uint256 amountOut = calc.calculateAmountOut(1e18, address(tokenA));
 
        assertEq(amountOut, 0);

    }


    function test_Swap_FromAToB() public {

        // add new pool
        vm.startPrank(address(this));

        deal(address(tokenA), address(this), 6e18);
        deal(address(tokenB), address(this), 9000e6);

        IERC20(tokenA).approve(address(calc), 6e18);
        IERC20(tokenB).approve(address(calc), 9000e6);

        // 6 * 9000 = 54000
        calc.addLiquidity(6e18, 9000e6);

        vm.stopPrank();


        // approve token A, user tries to swap
        vm.startPrank(address(this));

        deal(address(tokenA), address(this), 2e18);

        IERC20(tokenA).approve(address(calc), 2e18);

        vm.stopPrank();


        // check user token B balance before swap
        uint256 tokenBBefore = tokenB.balanceOf(address(this));

        // swap
        calc.swap(address(tokenA), 2e18, 2240e6);

        // check user token B balance after swap
        uint256 tokenBAfter = tokenB.balanceOf(address(this));

        uint256 receivedB = tokenBAfter - tokenBBefore;

        assertGt(receivedB, 2200e6);
        assertLt(receivedB, 2300e6);

    }


    function test_Swap_FromBToA() public {

        // add new pool
        vm.startPrank(address(this));

        deal(address(tokenA), address(this), 6000e15);
        deal(address(tokenB), address(this), 9000e6);

        IERC20(tokenA).approve(address(calc), 6000e15);
        IERC20(tokenB).approve(address(calc), 9000e6);

        // 6 * 9000 = 54000
        calc.addLiquidity(6000e15, 9000e6);

        vm.stopPrank();


        // approve token B, user tries to swap
        vm.startPrank(address(this));

        deal(address(tokenB), address(this), 3000e6);

        IERC20(tokenB).approve(address(calc), 3000e6);

        vm.stopPrank();

        // check user token A balance before swap
        uint256 tokenABefore = tokenA.balanceOf(address(this));

        // swap
        // amountWithoutFee = 3000 * 997 / 1000 = 2991 USDC
        // amountOut = (2991 * 6) / (9000 + 2991) = 1.4969 ETH
        calc.swap(address(tokenB), 3000e6, 1496e15);

        // check user token A balance after swap
        uint256 tokenAAfter = tokenA.balanceOf(address(this));

        uint256 receivedA = tokenAAfter - tokenABefore;

        assertGt(receivedA, 1492e15);
        assertLt(receivedA, 1499e15);

    }


    function test_Swap_RevertAmountZero() public {

        vm.startPrank(address(this));
    
        vm.expectRevert("Amount must be > 0");

        calc.swap(address(tokenA), 0, 0);
    
        vm.stopPrank();

    }


    function test_Swap_TokenARevertReserveZero() public {
    
        vm.startPrank(address(this));

        vm.expectRevert("Amount must be > 0");

        calc.swap(address(tokenA), 1496e15, 3000e6);
    
        vm.stopPrank();

    }


    function test_Swap_TokenBRevertReserveZero() public {
    
        vm.startPrank(address(this));

        vm.expectRevert("Amount must be > 0");

        calc.swap(address(tokenB), 3000e6, 1496e15);
    
        vm.stopPrank();

    }


    function test_Swap_ReservesChangeCorrectlyAB() public {

        // add new pool
        vm.startPrank(address(this));

        deal(address(tokenA), address(this), 6000e15);
        deal(address(tokenB), address(this), 9000e6);

        IERC20(tokenA).approve(address(calc), 6000e15);
        IERC20(tokenB).approve(address(calc), 9000e6);

        // 6 * 9000 = 54000
        calc.addLiquidity(6000e15, 9000e6);

        vm.stopPrank();

        // approve token A, user tries to swap
        vm.startPrank(address(this));

        deal(address(tokenA), address(this), 2000e15);

        IERC20(tokenA).approve(address(calc), 2000e15);
    
        uint256 reserveA = calc.reserveA();
        uint256 reserveB = calc.reserveB();

        // amountWithoutFee = 2 * 997 / 1000 = 1.994 ETH
        // amountOut = (1.994 * 9000) / (6 + 1.994) = 2244.93 USDC
        calc.swap(address(tokenA), 2000e15, 2240e6);

        vm.stopPrank();

        // 6000e15 + 2000e15 = 8000e15 ETH
        // 9000e6 - 2245e6 = 6755e6
        assertEq(calc.reserveA(), 8000e15);
        assertLt(calc.reserveB(), 6756e6);

    }


    function test_Swap_ReservesChangeCorrectlyBA() public {

        // add new pool
        vm.startPrank(address(this));

        deal(address(tokenA), address(this), 6000e15);
        deal(address(tokenB), address(this), 9000e6);

        IERC20(tokenA).approve(address(calc), 6000e15);
        IERC20(tokenB).approve(address(calc), 9000e6);

        // 6 * 9000 = 54000
        calc.addLiquidity(6000e15, 9000e6);

        vm.stopPrank();

        // approve token B, user tries to swap
        vm.startPrank(address(this));

        deal(address(tokenB), address(this), 3000e6);

        IERC20(tokenB).approve(address(calc), 3000e6);
    
        uint256 reserveA = calc.reserveA();
        uint256 reserveB = calc.reserveB();

        // amountWithoutFee = 3000 * 997 / 1000 = 2991 USDC
        // amountOut = (2991 * 6) / (9000 + 2991) = 1.4969 ETH
        calc.swap(address(tokenB), 3000e6, 1496e15);

        vm.stopPrank();

        // 6000e15 - 1496e15 = 4504e15 ETH
        // 9000e6 + 3000e6 = 12000e6
        assertLt(calc.reserveA(), 4505e15);
        assertEq(calc.reserveB(), 12000e6);

    }


    // next test for amountOut > 0, but for very small amountIn  
    function test_Swap_VerySmallAmountIn() public {

        // add new pool
        vm.startPrank(address(this));

        deal(address(tokenA), address(this), 6000e15);
        deal(address(tokenB), address(this), 9000e6);

        IERC20(tokenA).approve(address(calc), 6000e15);
        IERC20(tokenB).approve(address(calc), 9000e6);

        // 6 * 9000 = 54000
        calc.addLiquidity(6000e15, 9000e6);

        vm.stopPrank();

        // approve token A, user tries to swap
        vm.startPrank(address(this));

        deal(address(tokenA), address(this), 1);

        IERC20(tokenA).approve(address(calc), 1);

        vm.stopPrank();
        

        vm.expectRevert("Insufficient output");

        calc.swap(address(tokenA), 1, 0);

    }


    function test_Swap_LargeAmountInAB() public {

        // add new pool
        vm.startPrank(address(this));

        deal(address(tokenA), address(this), 1000e18);
        deal(address(tokenB), address(this), 1500000e6);

        IERC20(tokenA).approve(address(calc), 1000e18);
        IERC20(tokenB).approve(address(calc), 1500000e6);

        // 6 * 9000 = 54000
        calc.addLiquidity(1000e18, 1500000e6);

        vm.stopPrank();

        // approve token A, user tries to swap
        vm.startPrank(address(this));

        deal(address(tokenA), address(this), 600e18);

        IERC20(tokenA).approve(address(calc), 600e18);
    
        uint256 reserveA = calc.reserveA();
        uint256 reserveB = calc.reserveB();

        // amountWithoutFee = 600 * 997 / 1000 = 598.2 ETH
        // amountOut = (598,2 * 1500000) / (1000 + 598,2) = 561444.12 USDC
        calc.swap(address(tokenA), 600e18, 561444e6);

        vm.stopPrank();

        // 1000e18 + 600e18 = 1600e18 ETH
        // 1500000e6 - 561444e6 = 938556e6
        assertEq(calc.reserveA(), 1600e18);
        assertLt(calc.reserveB(), 938557e6);
        
    }


        function test_Swap_LargeAmountInBA() public {

        // add new pool
        vm.startPrank(address(this));

        deal(address(tokenA), address(this), 1000e18);
        deal(address(tokenB), address(this), 1500000e6);

        IERC20(tokenA).approve(address(calc), 1000e18);
        IERC20(tokenB).approve(address(calc), 1500000e6);

        // 6 * 9000 = 54000
        calc.addLiquidity(1000e18, 1500000e6);

        vm.stopPrank();

        // approve token A, user tries to swap
        vm.startPrank(address(this));

        deal(address(tokenB), address(this), 800000e6);

        IERC20(tokenB).approve(address(calc), 800000e6);
    
        uint256 reserveA = calc.reserveA();
        uint256 reserveB = calc.reserveB();

        // amountWithoutFee = 800000 * 997 / 1000 = 797600 USDC
        // amountOut = (797600 * 1000) / (1500000 + 797600) = 347,14 ETH
        calc.swap(address(tokenB), 800000e6, 347e18);

        vm.stopPrank();

        // 1000e18 - 347e18 = 653e18 ETH
        // 1500000e6 + 800000e6 = 2300000e6
        assertLt(calc.reserveA(), 654e18);
        assertEq(calc.reserveB(), 2300000e6);
        
    }


    function test_Swap_RevertTokenIsInvalid() public {

        vm.startPrank(address(this));
    
        vm.expectRevert("Not this token");

        calc.swap(address(0x998877), 10e18, 14500e6);
    
        vm.stopPrank();

    }




}