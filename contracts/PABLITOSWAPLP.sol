SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract PABLITOSWAPLP {

    using SafeERC20 for IERC20;

    uint256 public reserveA;                    // WETH
    uint256 public reserveB;                    // USDC
    uint256 public fee = 3;                     // 0.3%
    address public pablitoSwap;                 // main contract


    // these variables: are set once in deployment and can't be changed
    constructor (address _tokenA, address _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        pablitoSwap = msg.sender;
    }


    struct User {
        uint256 amount_tokenA;
        uint256 amount_tokenB;
    }

    // every address = quantity assigned tokens
    mapping(address => User) public users;


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
            uint256 liquidityA = (amountA * totalLiquidity) / reserveA;
            uint256 liquidityB = (amountB * totalLiquidity) / reserveB;

            // limit for user deposit  
            liquidity = min(liquidityA, liquidityB);
        }

        // limit for amount minimum  
        require(liquidity > 0, "Insufficient liquidity");

        // perfect ratio
        require(
            amountA * reserveB == amountB * reserveA,
            "Wrong token ratio"
        );


        // update in storage state for user: +LP for user
        userLiquidity[msg.sender] += liquidity;
        // total LP in pool: + for pool
        totalLiquidity += liquidity;


        // Update variables storage: how many tokens add?
        reserveA += amountA;
        reserveB += amountB;


        // What to do emit? 
        emit AddLiquidity(msg.sender, amountA, amountB, liquidity);

    }

// Save: Events = Logs on the blockchain, check by address (basescan.org)
event AddLiquidity(address indexed user, uint256 amountA, uint256 amountB, uint256 liquidity);


    // AMM: subtract reserve from LP (-) 
    function removeLiquidity(uint256 amountA, uint256 amountB) external {

        // Check amount: tokens A WETH and B USDC
        require(amountA > 0, "Amount must be > 0");  
        require(amountB > 0, "Amount must be > 0"); 

        // Check amount: too much/not enough (>= whole reserve)
        require(reserveA >= amountA, "Not enough reserveA");
        require(reserveB >= amountB, "Not enough reserveB");

        // Token transfers from my contract to user address 
        IERC20(tokenA).safeTransfer(msg.sender, amountA);
        IERC20(tokenB).safeTransfer(msg.sender, amountB);

        // Update variables storage: how many tokens subtract?
        reserveA -= amountA;
        reserveB -= amountB;

        // What to do emit? 
        emit RemoveLiquidity(msg.sender, amountA, amountB);

    }

// Save: Events = Logs on the blockchain, check by address (basescan.org)
event RemoveLiquidity(address indexed user, uint256 amountA, uint256 amountB);


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


}


