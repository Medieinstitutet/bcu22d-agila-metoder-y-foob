// SPDX-License-Identifier: CBT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.0/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts@4.8.0/access/Ownable.sol";
import {MerkleProof} from '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import "@openzeppelin/contracts@4.8.0/token/ERC1155/extensions/ERC1155Supply.sol";

contract CryptoBar is ERC1155, Ownable, ERC1155Supply {
    uint256 constant TOKEN_PRICE = 0.02 ether; //Mint price
    uint256 public constant MAX_TOKENS = 100; //Max supply

    bytes32 public immutable merkleRoot;

    mapping(address => bool) public userClaimed;

    constructor(bytes32 _merkleRoot) ERC1155("https://gateway.pinata.cloud/ipfs/QmWHBAv1eAnph3UaM5oAnyJCq2MhZcAd1EqsuM1bB8FTaG {id}") {
        merkleRoot = _merkleRoot;
        totalBalance[0] = 0;
    }

    function setURI(string memory newuri) public onlyOwner { // currently not in use
        _setURI(newuri);
    } //Lägg till metadata länk senare efter ERC1155 rad 17

    //function mint(address account, uint256 id, uint256 amount, bytes memory data) public payable { < removed parameters as they are not in use
    function mint() public payable {
        require(totalSupply(0) + 1 <= MAX_TOKENS, 'Purchase would exceed max supply of tokens');
        require(TOKEN_PRICE == msg.value, 'Ether value sent is not correct');
        _mint(msg.sender, 0, 1, '');
    }

    function onSaleMint(bytes32[] calldata proof) external payable {
        require(totalSupply(0) + 1 <= MAX_TOKENS, 'Purchase would exceed max supply of tokens');
        require(!userClaimed[msg.sender], 'Adress already claimed');

        bytes32 leaf = keccak256(abi.encodePacked(msg.sender, msg.value));
        bool isValidLeaf = MerkleProof.verify(proof, merkleRoot, leaf);
        require(isValidLeaf, 'Adress is not eligible for mint with discount');

        _mint(msg.sender, 0, 1, '');

        userClaimed[msg.sender] = true;
    }

    /* 
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        payable(msg.sender).transfer(balance);
    } 
    */

    // Withdraw: prevent withdrawal on zero balance !!

    // State variable to track if there is a security breach
    bool public emergency;

    // Emergency stop function
    function emergencyStop() public onlyOwner {
        emergency = true;
    }

    // Add a check for emergency stop before executing other functions
    function withdraw() public onlyOwner {
        require(!emergency, "Emergency stop is active, withdrawals are not allowed");
        require(address(this).balance > 0, "Contract balance is zero, nothing to withdraw");
        payable(msg.sender).transfer(address(this).balance);
    }

    // CHECK TOKEN BALANCE

    mapping(uint256 => uint256) public totalBalance;

    function getTotalBalance() public view returns (uint256[] memory) {
        uint256[] memory balanceArray = new uint256[](MAX_TOKENS);
        for (uint256 i = 0; i < MAX_TOKENS; i++) {
            balanceArray[i] = balanceOf(msg.sender, i);
        }
        return balanceArray;
    }

    // PURCHASE FOOD & DRINKS WITH TOKENS

    mapping(uint256 => bool) public productAvailability;
    mapping(uint256 => uint256) public productPrice;

    struct Product {
        string name;
        uint256 price;
        bool availability;
    }

    Product[] public products;

    function redeemProduct(uint256 productId, uint256 tokenAmount) public {
        require(productId < products.length, "Invalid product ID");
        Product storage product = products[productId];
        require(product.availability, "Product is not available for redemption");
        require(product.price <= tokenAmount, "You don't have enough tokens to redeem this product");
        require(balanceOf(msg.sender, 0) >= tokenAmount, "You don't have enough tokens to redeem this product");
        product.availability = false;
        safeTransferFrom(msg.sender, address(this), 0, tokenAmount, new bytes(0));
    }

    
    // ADD BOOKING FUNCTIONALITY

    struct TableBooking {
        uint256 bookingTime;
        uint256 tokenAmount;
    }

    struct LocationBooking {
        uint256 bookingTime;
        uint256 tokenAmount;
    }

    struct RecurringBooking {
        uint256 startDate;
        uint256 endDate;
        uint256 frequency; 
        uint256 tokenAmount;
    }

    mapping(uint256 => mapping(address => TableBooking)) public tableBookings;
    mapping(uint256 => mapping(address => LocationBooking)) public locationBookings;
    mapping(uint256 => mapping(address => RecurringBooking)) public recurringBookings;

    mapping(uint256 => bool) public tableAvailability;
    mapping(uint256 => bool) public locationAvailability;

    // Book a table
    function bookTable(uint256 tableId, uint256 tokenAmount, uint256 bookingTime) public {
        require(tableAvailability[tableId] == true, "Table is not available");
        require(balanceOf(msg.sender, 0) >= tokenAmount, "You don't have enough tokens to book this table");
        tableAvailability[tableId] = false;
        tableBookings[tableId][msg.sender] = TableBooking(bookingTime, tokenAmount);
        safeTransferFrom(msg.sender, address(this), 0, tokenAmount, new bytes(0));
    }

    // Allow to cancel table booking
    function cancelTableBooking(uint256 tableId, uint256 bookingTime) public {
        require(tableBookings[tableId][msg.sender].tokenAmount > 0, "No booking found for this table and address");
        require(tableBookings[tableId][msg.sender].bookingTime == bookingTime, "Incorrect booking time");
        require(tableBookings[tableId][msg.sender].bookingTime > block.timestamp, "Booking time has already passed, can not cancel anymore");

        tableAvailability[tableId] = true;
        uint256 tokenAmount = tableBookings[tableId][msg.sender].tokenAmount;
        tableBookings[tableId][msg.sender] = TableBooking(0, 0);
        safeTransferFrom(address(this), msg.sender, 0, tokenAmount, new bytes(0));
    }

    // Book a private room, event etc.
    function bookLocation(uint256 locationId, uint256 tokenAmount, uint256 bookingTime) public {
        require(locationAvailability[locationId] == true, "Location is not available");
        require(balanceOf(msg.sender, 0) >= tokenAmount, "You don't have enough tokens to book this location");
        locationAvailability[locationId] = false;
        locationBookings[locationId][msg.sender] = LocationBooking(bookingTime, tokenAmount);
        safeTransferFrom(msg.sender, address(this), 0, tokenAmount, new bytes(0));
    }

    // Allow to cancel location booking
    function cancelLocationBooking(uint256 locationId) public {
        require(locationBookings[locationId][msg.sender].tokenAmount > 0, "No booking found for this location and address");
        require(locationBookings[locationId][msg.sender].bookingTime > block.timestamp, "Booking time has already passed, can not cancel anymore");

        locationAvailability[locationId] = true;
        uint256 tokenAmount = locationBookings[locationId][msg.sender].tokenAmount;
        locationBookings[locationId][msg.sender] = LocationBooking(0, 0);
        safeTransferFrom(address(this), msg.sender, 0, tokenAmount, new bytes(0));
    }

    // Allow users to set up recurring bookings
    function setRecurringBooking(uint256 locationId, uint256 startDate, uint256 endDate, uint256 frequency, uint256 tokenAmount) public {
        require(locationAvailability[locationId], "Location is not available");
        require(balanceOf(msg.sender, 0) >= tokenAmount, "You don't have enough tokens to set up this booking");
        locationAvailability[locationId] = false;
        recurringBookings[locationId][msg.sender] = RecurringBooking(startDate, endDate, frequency, tokenAmount);
        safeTransferFrom(msg.sender, address(this), 0, tokenAmount, new bytes(0));
    }

        // Allow to cancel a recurring booking
    function cancelRecurringBooking(uint256 locationId) public {
        require(recurringBookings[locationId][msg.sender].tokenAmount > 0, "No recurring booking found for this location and address");
        require(recurringBookings[locationId][msg.sender].startDate > block.timestamp, "Start date of booking has already been reached, can not cancel anymore");
        locationAvailability[locationId] = true;
        uint256 tokenAmount = recurringBookings[locationId][msg.sender].tokenAmount;
        recurringBookings[locationId][msg.sender] = RecurringBooking(0, 0, 0, 0); 
        safeTransferFrom(address(this), msg.sender, 0, tokenAmount, new bytes(0));
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
