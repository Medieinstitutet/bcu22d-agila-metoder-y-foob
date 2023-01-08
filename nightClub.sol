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

require(token.balanceOf(msg.sender) >= amount, "Insufficient balance");
token.safeTransferFrom(msg.sender, address(this), amount);
token.transfer(address(this), amount);

}

// Allow users to book events at the club
function bookEvent(uint256 eventId, uint256 amount) public {

require(token.balanceOf(msg.sender) >= amount, "Insufficient balance");

// Check if the event is available
// ... (do we need a calender? Slots available?)

token.safeTransferFrom(msg.sender, address(this), amount);
token.transfer(address(this), amount);

// alternatively: deposit?

event Deposit(
        address indexed _reserve,
        address indexed _user,
        uint256 _amount,
        uint16 indexed _referral,
        uint256 _timestamp
    );


// Reserve the event for the user

event ReserveEnabled(address indexed _reserve, address indexed _user);



// refund? 
 event Refund(
        address indexed _reserve,
        address indexed _user,
        address indexed _repayer,
        uint256 _amountMinusFees,
        uint256 _fees,
        uint256 _borrowBalanceIncrease,
        uint256 _timestamp
    );

}
}
