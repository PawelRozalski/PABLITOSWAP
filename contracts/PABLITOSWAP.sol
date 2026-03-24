SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



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


}