SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract PABLITOSWAP {

    address public immutable tokenA;
    address public immutable tokenB;
    address public owner;
    uint256 public reward_liquidity;


    // these variables: are set once in deployment and can't be changed
    constructor (address _tokenA, address _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        owner = msg.sender;
    }


    // access control: only owner can starts functions below modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");                                      // Remember: change from require/revert to custom errors with "if" (after tests / optimalization gas)
        _;
    }
        
    function swap (address _tokenA, address _tokenB, uint256 amount) public { 
        require(amount > 0, "Amount must be > 0");                                      // Remember: change from require/revert to custom errors with "if" (after tests / optimalization gas)
    

        // Check tokens: what address user used = what address I implemented in code
        require(_tokenA == tokenA || _tokenA == tokenB, "Unsupported tokenA");                      
        require(_tokenB == tokenA || _tokenB == tokenB, "Unsupported tokenB");
    }   



}