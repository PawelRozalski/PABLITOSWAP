SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


contract PABLITOSWAP {

    using SafeERC20 for IERC20;

    address public immutable tokenA;                // WETH
    address public immutable tokenB;                // USDC
    address public owner;
    uint256 public reward_liquidity;


    // these variables: are set once in deployment and can't be changed
    constructor (address _tokenA, address _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        owner = msg.sender;
        lpContract = PABLITOSWAPLP(_lpAddress);
    }


    // access control: only owner can starts functions below modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");                                      // Remember: change from require/revert to custom errors with "if" (after tests / optimalization gas)
        _;
    }


    // call to add LP 
    function addLiquidityToLP(uint256 amountA, uint256 amountB) external { 
        lpContract.addLiquidity(amountA, amountB); 
    } 


    // call to remove LP 
    function removeLiquidityFromLP(uint256 liquidity) external { 
        lpContract.removeLiquidity(amountA, amountB); 
    }


    // call for swap in LP (calculateAmountOut) 
    function calculateAmountInLP (uint256 amountIn, address tokenIn) external view returns (uint256) {
        return lpContract.calculateAmountOut(amountIn, tokenIn);
    }


    // call for swap in LP contract
    function swapInLP(address tokenIn, uint256 amountIn, uint256 minAmountOut) external {
        lpContract.swap(tokenIn, amountIn, minAmountOut);
    }

}