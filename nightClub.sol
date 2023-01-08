pragma solidity ^0.8.0;  
//SPDX-License-Identifier: MIT

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/utils/SafeERC20.sol";
import "./foobToken.sol";

contract MyNightClub is SafeERC20 {

foobToken public token;

constructor(foobToken _token) public {
token = _token;
}

// Purchase items using tokens
// --> shall we have a menu? 

function purchase(uint256 _amount) public {

require(token.balanceOf(msg.sender) >= _amount, "Insufficient balance");
token.safeTransferFrom(msg.sender, address(this), _amount);
token.transfer(address(this), _amount);

}

// Allow users to book events at the club
function bookEvent(uint256 _eventId, uint256 _amount) public {

require(token.balanceOf(msg.sender) >= _amount, "Insufficient balance");

// Check if the event is available
// ... (we need a calender)

token.safeTransferFrom(msg.sender, address(this), _amount);
token.transfer(address(this), _amount);

// Reserve the event for the user
// ... 

}
}
