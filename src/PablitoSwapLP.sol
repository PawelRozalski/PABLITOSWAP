// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract PablitoSwapLP {

    using SafeERC20 for IERC20;

    address public immutable tokenA;
    address public immutable tokenB;
    address public immutable pablitoSwap;       // main contract
    uint256 public totalLiquidity;
    uint256 public reserveA;                    // WETH
    uint256 public reserveB;                    // USDC
    uint256 public fee = 3;                     // 0.3%


    // these variables: are set once in deployment and can't be changed
    constructor (address _tokenA, address _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;

        pablitoSwap = msg.sender;
    }


    // every address = quantity owned share tokens
    mapping(address => uint256) public userLiquidity;


    // AMM: add reserve to LP (+)
    function addLiquidity(uint256 amountA, uint256 amountB) external {

        uint256 liquidity;

        // Check amount tokens A WETH and B USDC
        require(amountA > 0, "Amount must be > 0"); 
        require(amountB > 0, "Amount must be > 0"); 

        // Token transfers from user to my contract address
        IERC20(tokenA).safeTransferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).safeTransferFrom(msg.sender, address(this), amountB);

        // first amounts in pool:
        if (totalLiquidity == 0) {
            liquidity = sqrt(amountA * amountB);
        // every amounts next in pool:
        } else {
            // perfect ratio
            require(
                amountA * reserveB == amountB * reserveA,
                "Wrong token ratio"
            );

            uint256 liquidityA = (amountA * totalLiquidity) / reserveA;
            uint256 liquidityB = (amountB * totalLiquidity) / reserveB;

            // limit for user deposit  
            liquidity = min(liquidityA, liquidityB);
        }

        // limit for amount minimum  
        require(liquidity > 0, "Insufficient liquidity");


        // update in storage state for user: +LP for user
        userLiquidity[msg.sender] += liquidity;
        // total LP in pool: + for pool
        totalLiquidity += liquidity;


        // Update variables storage: how many tokens add?
        reserveA += amountA;
        reserveB += amountB;


        // emit event for tracking liquidity add
        emit AddLiquidity(msg.sender, amountA, amountB, liquidity);

    }

// Save: Events = Logs on the blockchain, check by address (basescan.org)
event AddLiquidity(address indexed user, uint256 amountA, uint256 amountB, uint256 liquidity);


    // AMM: subtract reserve from LP (-) 
    function removeLiquidity(uint256 liquidity) external {

        // user must burn more than zero share tokens
        require(liquidity > 0);

        // pool must have liquidity 
        require(totalLiquidity > 0);

        // user can't burn more share tokens than they own
        require(liquidity <= userLiquidity[msg.sender]); 


        // calculate how many A and B tokens, user to get based on share tokens 
        uint256 amountA = (liquidity * reserveA) / totalLiquidity;
        uint256 amountB = (liquidity * reserveB) / totalLiquidity;


        // update user share tokens balance (in storage)
        userLiquidity[msg.sender] -= liquidity;	
        // update total liquidity in the pool (in storage)
        totalLiquidity -= liquidity;


        // update pool reserves
        reserveA -= amountA;
        reserveB -= amountB;


        // Token transfers from my contract to user address 
        IERC20(tokenA).safeTransfer(msg.sender, amountA);
        IERC20(tokenB).safeTransfer(msg.sender, amountB);


        // emit event for tracking liquidity remove
        emit RemoveLiquidity(msg.sender, amountA, amountB, liquidity);

    }

// Save: Events = Logs on the blockchain, check by address (basescan.org)
event RemoveLiquidity(address indexed user, uint256 amountA, uint256 amountB, uint256 liquidity);


    // AMM: x * y = k (for swap: from WETH to USDC and from USDC to WETH)
    function calculateAmountOut(uint256 amountIn, address tokenIn) external view returns (uint256) {

        uint256 reserveIn;
        uint256 reserveOut;

        // amount from user without fee
        uint256 amountWithoutFee = amountIn * (1000 - fee) / 1000;


        // when tokenA: then reserveA + amountA and reserveB - amountB 
        if (tokenIn == tokenA) {
            reserveIn = reserveA;
            reserveOut = reserveB;
        } else {
            reserveIn = reserveB;
            reserveOut = reserveA;
        }


        // formula for swap: how many token give to user? = (amount from user without fee * reserve after swap) / (reserve before swap + amount from user without fee)
        // like this: uint256 k = reserveA * reserveB (k = x * y) 
        uint256 amountOut = (amountWithoutFee * reserveOut) / (reserveIn + amountWithoutFee);
        return amountOut;

    }


    function swap(address tokenIn, uint256 amountIn, uint256 minAmountOut) external {
    

        address tokenOut;

        // variables for calculate in function 
        uint256 reserveIn;
        uint256 reserveOut;

        // amount from user without fee
        uint256 amountWithoutFee = amountIn * (1000 - fee) / 1000;


        // User must to introduce token amount high than zero 
        require(amountIn > 0, "Amount must be > 0");


        // Check tokens A = A, B = B
        require(tokenIn == tokenA || tokenIn == tokenB, "Not this token");
    
    
        // Check reserve state
        require(reserveA > 0, "Amount must be > 0");
        require(reserveB > 0, "Amount must be > 0");


        // direction swap
        if (tokenIn == tokenA) {
            tokenOut = tokenB;
            reserveIn = reserveA;
            reserveOut = reserveB;
        } else {
            tokenOut = tokenA;
            reserveIn = reserveB;
            reserveOut = reserveA;
        }


        // In this the same formula like in calculateAmountOut function
        uint256 amountOut = (amountWithoutFee * reserveOut) / (reserveIn + amountWithoutFee);


        // require for small amount to out 
        require(amountOut > 0, "Insufficient output");


        // Slippage protection = user to take minimum token amount out prom the predict value in calculateAmountOut view function
        require(amountOut >= minAmountOut);


        // Token transfers from user to my contract address
        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);


        // direction update reserves
        if (tokenIn == tokenA) {
            reserveA += amountIn;
            reserveB -= amountOut;

        } else {
            reserveB += amountIn;
            reserveA -= amountOut;
        }


        // Token transfers from my contract to user address 
        IERC20(tokenOut).safeTransfer(msg.sender, amountOut);


        // emit event for tracking liquidity remove
        emit Swap(msg.sender, tokenIn, amountIn, amountOut);


    }

// Save: Events = Logs on the blockchain, check by address (basescan.org)
event Swap(address indexed user, address tokenIn, uint256 amountIn, uint256 amountOut);


}

