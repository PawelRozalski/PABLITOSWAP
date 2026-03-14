SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";



contract PABLITOSWAP {

    address public immutable tokenA;
    address public immutable tokenB;
    address public owner;

// these variables: are set once in deployment and can't be changed
    constructor (address _tokenA, address _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
        owner = msg.sender;
    }

// access control: only owner can starts functions below modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }
    
}