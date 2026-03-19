SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

using SafeERC20 for IERC20;



contract PABLITOSWAPLP {

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


    function addLiquidity(uint256 amountA, uint256 amountB) external {

        // Check amount tokens A WETH and B USDC
        require(amountA > 0, "Amount must be > 0"); 
        require(amountB > 0, "Amount must be > 0"); 

        // Token transfers from user to my contract address
        IERC20(tokenA).safeTransferFrom(msg.sender, address(this), amountA);
        IERC20(tokenB).safeTransferFrom(msg.sender, address(this), amountB);

        // Update variables storage: how many tokens add?
        reserveA += amountA;
        reserveB += amountB;

        // What to do emit? 
        emit addLiquidity(msg.sender, amountA, amountB);

    }

// Save: Events = Logs on the blockchain, check by address (basescan.org)
event AddLiquidity(address indexed user, uint256 amountA, uint256 amountB);


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

        // Update variables storage: how many tokens subtrack?
        reserveA -= amountA;
        reserveB -= amountB;

        // What to do emit? 
        emit removeLiquidity(msg.sender, amountA, amountB);

    }

// Save: Events = Logs on the blockchain, check by address (basescan.org)
event RemoveLiquidity(address indexed user, uint256 amountA, uint256 amountB);



}