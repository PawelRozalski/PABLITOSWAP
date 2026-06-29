// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract MockERC20 is ERC20 {

    // create token ERC20 with Mock name and MOCK symbol:
    constructor() ERC20("Mock", "MOCK") {}

    // create tokens and assigns them address "to"
    function mint(address to, uint256 amount) public {
        
        // perform mint
        _mint(to, amount);
    }
    
}