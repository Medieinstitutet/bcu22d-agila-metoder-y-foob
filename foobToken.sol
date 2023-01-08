pragma solidity ^0.8.0;
//SPDX-License-Identifier: MIT

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";

contract ERC20 {
    string public name = "foobToken";
    string public symbol = "FTK";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowed;

constructor() {
    totalSupply = 777; 
    balanceOf[msg.sender] = totalSupply;
}

// Transfer function
function transfer(address recipient, uint256 amount) public {
    require(balanceOf[msg.sender] >= amount, "Insufficient balance");
    balanceOf[msg.sender] -= amount; 
    balanceOf[recipient] += amount;
}

}
